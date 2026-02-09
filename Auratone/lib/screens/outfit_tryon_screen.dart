import 'package:flutter/material.dart';
import 'outfit_camera_screen.dart';

class OutfitTryOnScreen extends StatelessWidget {
  const OutfitTryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outfit Try-On')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Upload and preview outfits, shoes, and accessories on a virtual model.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 12),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OutfitCameraScreen()),
    );
  },
  child: Text('Live Camera Try-On'),
),

SizedBox(height: 12),

ElevatedButton(
  onPressed: () {
    // Will open gallery later
  },
  child: Text('Upload Outfit Image'),
),

SizedBox(height: 12),

ElevatedButton(
  onPressed: () {
    // Accessories try-on (hat, shoes, glasses)
  },
  child: Text('Try Accessories'),
),

              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
