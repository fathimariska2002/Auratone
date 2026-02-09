import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class OutfitOverlay extends StatelessWidget {
  final Pose pose;

  const OutfitOverlay({super.key, required this.pose});

  @override
  Widget build(BuildContext context) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftShoulder == null || rightShoulder == null) {
      return const SizedBox();
    }

    final width =
        (rightShoulder.x - leftShoulder.x).abs() * 1.5;

    return Positioned(
      top: leftShoulder.y,
      left: leftShoulder.x - width / 4,
      child: Image.asset(
        'assets/outfits/dress.png',
        width: width,
      ),
    );
  }
}
