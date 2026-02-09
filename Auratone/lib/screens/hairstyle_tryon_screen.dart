import 'package:flutter/material.dart';

class HairstyleTryOnScreen extends StatelessWidget {
  const HairstyleTryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hairstyle Try-On')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Try different hairstyles virtually using AR.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: integrate ARCore/ARKit hairstyle overlay
                },
                child: Text('Try Hairstyles'),
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
