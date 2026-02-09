import 'package:flutter/material.dart';

class MakeupSimulationScreen extends StatelessWidget {
  const MakeupSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Makeup Simulation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Try different lipstick and makeup shades based on your skin tone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: integrate AR makeup filters
                },
                child: Text('Try Makeup'),
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
