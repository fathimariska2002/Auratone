import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class OutfitCameraScreen extends StatefulWidget {
  const OutfitCameraScreen({super.key});

  @override
  _OutfitCameraScreenState createState() => _OutfitCameraScreenState();
}

class _OutfitCameraScreenState extends State<OutfitCameraScreen> {
  CameraController? _controller;
  bool _isCameraReady = false;

  // Selected items
  XFile? _selectedOutfit;
  XFile? _selectedHat;
  XFile? _selectedShoes;
  XFile? _selectedAccessory;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[1], ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() => _isCameraReady = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pickItem(String type) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (type == 'outfit') _selectedOutfit = picked;
        if (type == 'hat') _selectedHat = picked;
        if (type == 'shoes') _selectedShoes = picked;
        if (type == 'accessory') _selectedAccessory = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Try-On')),
      body: _isCameraReady
          ? Stack(
              children: [
                CameraPreview(_controller!),

                // Placeholder for pose detection
                // TODO: integrate MLKit Pose Detection and pass coordinates to overlays

                // Outfit overlay
                if (_selectedOutfit != null)
                  OutfitOverlay(imageFile: File(_selectedOutfit!.path), label: 'Outfit'),

                // Hat overlay
                if (_selectedHat != null)
                  OutfitOverlay(imageFile: File(_selectedHat!.path), label: 'Hat'),

                // Shoes overlay
                if (_selectedShoes != null)
                  OutfitOverlay(imageFile: File(_selectedShoes!.path), label: 'Shoes'),

                // Accessory overlay
                if (_selectedAccessory != null)
                  OutfitOverlay(imageFile: File(_selectedAccessory!.path), label: 'Accessory'),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () => _pickItem('outfit'), child: const Text('Outfit')),
            ElevatedButton(
                onPressed: () => _pickItem('hat'), child: const Text('Hat')),
            ElevatedButton(
                onPressed: () => _pickItem('shoes'), child: const Text('Shoes')),
            ElevatedButton(
                onPressed: () => _pickItem('accessory'), child: const Text('Accessory')),
          ],
        ),
      ),
    );
  }
}

// ---------------- Outfit Overlay Widget ----------------
class OutfitOverlay extends StatelessWidget {
  final File imageFile;
  final String label;
  const OutfitOverlay({required this.imageFile, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: use pose detection coordinates to position each item dynamically
    double width = 200;
    double height = 300;

    if (label == 'Hat') {
      width = 150;
      height = 100;
    } else if (label == 'Shoes') {
      width = 150;
      height = 100;
    } else if (label == 'Accessory') {
      width = 100;
      height = 100;
    }

    return Center(
      child: Opacity(
        opacity: 0.7,
        child: Image.file(
          imageFile,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
