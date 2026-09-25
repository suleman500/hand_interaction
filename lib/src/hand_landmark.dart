/// One landmark from a 21-point hand skeleton.
///
/// [x] and [y] are normalized to the input image dimensions (0.0 to 1.0).
/// [z] is passed through from the landmark source and is not interpreted by
/// this package.
class HandLandmark {
  final double x;
  final double y;
  final double z;

  const HandLandmark({
    required this.x,
    required this.y,
    required this.z,
  });
}