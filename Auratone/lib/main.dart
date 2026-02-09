import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

import 'screens/face_analysis_screen.dart';
import 'screens/hairstyle_tryon_screen.dart';
import 'screens/makeup_simulation_screen.dart';
import 'screens/outfit_tryon_screen.dart';
import 'screens/personal_color_palette_screen.dart';

class UserProfile {
  final String faceType;
  final String skinTone;
  final String hairType;
  final String colorType;

  UserProfile({
    required this.faceType,
    required this.skinTone,
    required this.hairType,
    required this.colorType,
  });
}

// ---------------- UserProfile Storage Functions ----------------
final storage = FlutterSecureStorage();

Future<void> saveUserProfile(UserProfile profile) async {
  await storage.write(key: 'faceType', value: profile.faceType);
  await storage.write(key: 'skinTone', value: profile.skinTone);
  await storage.write(key: 'hairType', value: profile.hairType);
  await storage.write(key: 'colorType', value: profile.colorType);
}

Future<UserProfile?> loadUserProfile() async {
  final faceType = await storage.read(key: 'faceType');
  final skinTone = await storage.read(key: 'skinTone');
  final hairType = await storage.read(key: 'hairType');
  final colorType = await storage.read(key: 'colorType');

  if (faceType != null && skinTone != null && hairType != null && colorType != null) {
    return UserProfile(
      faceType: faceType,
      skinTone: skinTone,
      hairType: hairType,
      colorType: colorType,
    );
  }
  return null;
}

// ---------------- Main App ----------------
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => IntroScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'PIN App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: IntroScreen(),
    );
  }
}

// ---------------- Intro Screen ----------------
class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/Screenshot 2025-11-28 103159.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              const Text(
                'Your Personal Stylist',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => EntryGate())),
                  child: const Text('Get Started', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Entry Gate ----------------
class EntryGate extends StatelessWidget {
  final _storage = const FlutterSecureStorage();

  Future<bool> _hasPin() async {
    return await _storage.read(key: 'pin_hash') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPin(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data! ? UnlockScreen() : SetupPinScreen();
      },
    );
  }
}

// ---------------- Setup PIN ----------------
class SetupPinScreen extends StatefulWidget {
  @override
  _SetupPinScreenState createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String? _error;

  String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  Future<void> _save() async {
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    await _storage.write(key: 'pin_hash', value: _hash(_pin.text));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                obscureText: false,
                controller: _pin,
                decoration: const InputDecoration(labelText: 'PIN')),
            const SizedBox(height: 12),
            TextField(
                obscureText: true,
                controller: _confirm,
                decoration: const InputDecoration(labelText: 'Confirm PIN')),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save PIN')),
          ],
        ),
      ),
    );
  }
}

// ---------------- Unlock Screen ----------------
class UnlockScreen extends StatefulWidget {
  @override
  _UnlockScreenState createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _storage = const FlutterSecureStorage();
  final List<String> _digits = ['', '', '', ''];
  int _pos = 0;
  String? _error;

  String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  void _add(String d) {
    if (_pos >= 4) return;
    setState(() => _digits[_pos++] = d);
    if (_pos == 4) _verify();
  }

  void _del() {
    if (_pos == 0) return;
    setState(() => _digits[--_pos] = '');
  }

  Future<void> _verify() async {
    final stored = await _storage.read(key: 'pin_hash');
    if (_hash(_digits.join()) == stored) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      setState(() => _error = 'Incorrect PIN');
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _digits.fillRange(0, 4, '');
          _pos = 0;
        });
      });
    }
  }

  Widget _btn(String t, VoidCallback f) => SizedBox(
        width: 72,
        height: 64,
        child: ElevatedButton(
          onPressed: f,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200),
          child: Text(t,
              style: const TextStyle(fontSize: 20, color: Colors.black)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),

          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(4, (i) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _digits[i],
        style: const TextStyle(fontSize: 24),
      ),
    );
  }),
),
const SizedBox(height: 20),

          for (var row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9']
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _btn(e, () => _add(e)),
                        ))
                    .toList(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 84),
                _btn('0', () => _add('0')),
                const SizedBox(width: 12),
                _btn('⌫', _del),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Home Screen with User Profile ----------------
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // TEMP: Hard-coded user profile for UI testing
  _profile = UserProfile(
    faceType: 'Oval',
    skinTone: 'Medium',
    hairType: 'Wavy',
    colorType: 'Deep Winter',
  );
    // _loadProfile();
  }

  Future<void> _loadProfile() async {
    final faceType = await _storage.read(key: 'faceType');
    final skinTone = await _storage.read(key: 'skinTone');
    final hairType = await _storage.read(key: 'hairType');
    final colorType = await _storage.read(key: 'colorType');

    if (faceType != null && skinTone != null && hairType != null && colorType != null) {
      setState(() {
        _profile = UserProfile(
          faceType: faceType,
          skinTone: skinTone,
          hairType: hairType,
          colorType: colorType,
        );
      });
    }
  }

  Widget _profileItem(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$title: $value'),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext c, String t, Widget page, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.purple.shade100,
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(t, style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      appBar: AppBar(title: const Text('Home',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      ),
      backgroundColor: Colors.purple,
      iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //--------------Profile Card-------------------
            if (_profile != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)
                          ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _profileItem('Face Type', _profile!.faceType, () {}),
                          _profileItem('Skin Tone', _profile!.skinTone, () {}),
                          _profileItem('Hair Type', _profile!.hairType, () {}),
                          _profileItem('Color Type', _profile!.colorType, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PersonalColorPaletteScreen()),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 1),
                       SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FaceAnalysisScreen()),
                            );
                            _loadProfile();
                          },
                          child: const Text('Retake Selfie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_profile != null) ...[
  const SizedBox(height: 20),
  const Align(
    alignment: Alignment.centerLeft,
    child: Text(
      'Features',
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple),
    ),
  ),
  const SizedBox(height: 10),
],

            _tile(context, 'Face Analysis', FaceAnalysisScreen(), Icons.face),
            _tile(context, 'Hairstyle Try-On', HairstyleTryOnScreen(), Icons.cut),
            _tile(context, 'Makeup Simulation', MakeupSimulationScreen(), Icons.brush),
            _tile(context, 'Outfit Try-On', OutfitTryOnScreen(), Icons.checkroom),
            const SizedBox(height: 20),
         SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock, color: Colors.white),
                label: const Text(
                  'Change PIN',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ChangePinScreen())),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ---------------- Change PIN Screen ----------------
class ChangePinScreen extends StatefulWidget {
  @override
  _ChangePinScreenState createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _storage = const FlutterSecureStorage();
  String? _error;

  final _current = ['', '', '', ''];
  final _newPin = ['', '', '', ''];
  final _confirm = ['', '', '', ''];

  int _posC = 0, _posN = 0, _posF = 0;
  int _selected = 0;

  String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  List<String> _list() => _selected == 0 ? _current : _selected == 1 ? _newPin : _confirm;

  int _pos() => _selected == 0 ? _posC : _selected == 1 ? _posN : _posF;

  void _setPos(int v) {
    if (_selected == 0) _posC = v;
    if (_selected == 1) _posN = v;
    if (_selected == 2) _posF = v;
  }

  void _add(String d) {
    final l = _list();
    final p = _pos();
    if (p >= 4) return;
    setState(() {
      l[p] = d;
      _setPos(p + 1);
    });
  }

  void _del() {
    final l = _list();
    final p = _pos();
    if (p == 0) return;
    setState(() {
      l[p - 1] = '';
      _setPos(p - 1);
    });
  }

  Future<void> _change() async {
    final stored = await _storage.read(key: 'pin_hash');
    if (_hash(_current.join()) != stored) {
      setState(() => _error = 'Current PIN incorrect');
      return;
    }
    if (_newPin.join() != _confirm.join()) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    await _storage.write(key: 'pin_hash', value: _hash(_newPin.join()));
    Navigator.pop(context);
  }

  Widget _buildBoxList(String label, List<String> list, int index) {
    final isSelected = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final has = list[i].isNotEmpty;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: isSelected ? Colors.purple : Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(has ? list[i] : '', style: const TextStyle(fontSize: 24)),
              );
            }),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _numButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: 72,
      height: 64,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
        child: Text(label, style: const TextStyle(fontSize: 20, color: Colors.black)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildBoxList('Current PIN', _current, 0),
              _buildBoxList('New PIN', _newPin, 1),
              _buildBoxList('Confirm PIN', _confirm, 2),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9']
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row
                              .map((e) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 6),
                                    child: _numButton(e, () => _add(e)),
                                  ))
                              .toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 84),
                          _numButton('0', () => _add('0')),
                          const SizedBox(width: 12),
                          _numButton('⌫', _del),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _change, child: const Text('Change PIN')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}