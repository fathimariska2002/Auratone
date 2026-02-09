import 'package:flutter/material.dart';

class FaceAnalysisScreen extends StatelessWidget {
  const FaceAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Analysis')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Capture your face to analyze features like face shape, skin tone, and hair type.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: integrate camera + Mediapipe/OpenCV later
                },
                child: Text('Analyze Face'),
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
