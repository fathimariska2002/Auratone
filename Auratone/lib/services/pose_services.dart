import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseService {
  final PoseDetector _detector =
      PoseDetector(options: PoseDetectorOptions());

  Future<Pose?> detectPose(InputImage image) async {
    final poses = await _detector.processImage(image);
    return poses.isNotEmpty ? poses.first : null;
  }

  void dispose() {
    _detector.close();
  }
}
