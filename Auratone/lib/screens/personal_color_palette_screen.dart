import 'package:flutter/material.dart';

class PersonalColorPaletteScreen extends StatelessWidget {
  const PersonalColorPaletteScreen({super.key});

  // Sample colors for each palette type (you can expand later)
  final Map<String, List<Color>> palettes = const {
    'Deep Winter': [
      Color(0xFF1B1F3B),
      Color(0xFF3C2F63),
      Color(0xFF5A4A8B),
      Color(0xFF7D6FC0),
    ],
    'Light Spring': [
      Color(0xFFFFF1E0),
      Color(0xFFFFD9B3),
      Color(0xFFFFC37F),
      Color(0xFFFFAD4C),
    ],
    // Add more types as needed
  };

  @override
  Widget build(BuildContext context) {
    // For demo, we'll assume 'Deep Winter'; in real app, load from storage
    final paletteName = 'Deep Winter';
    final colors = palettes[paletteName] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Your Personal Color Palette')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paletteName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: colors
                  .map((c) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
