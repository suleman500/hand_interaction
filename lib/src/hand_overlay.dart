import 'package:flutter/material.dart';

import 'hand_landmark.dart';

const List<List<int>> _handConnections = [
  [0, 1], [1, 2], [2, 3], [3, 4],
  [0, 5], [5, 6], [6, 7], [7, 8],
  [5, 9], [9, 10], [10, 11], [11, 12],
  [9, 13], [13, 14], [14, 15], [15, 16],
  [13, 17], [17, 18], [18, 19], [19, 20],
  [0, 17],
];

/// Draws a 21-point hand skeleton over an image or camera preview.
///
/// [landmarks] must be normalized to the image dimensions (0..1), matching
/// [HandLandmark]. Place this widget in a stack that has the same bounds as
/// the displayed image. It only draws the supplied points; it does not track
/// a hand or detect gestures.
class HandOverlay extends StatelessWidget {
  final List<HandLandmark> landmarks;
  final int imageWidth;
  final int imageHeight;
  final bool isFist;
  final Color openHandColor;
  final Color fistColor;
  final Color pointColor;

  const HandOverlay({
    super.key,
    required this.landmarks,
    required this.imageWidth,
    required this.imageHeight,
    required this.isFist,
    this.openHandColor = Colors.cyanAccent,
    this.fistColor = Colors.orangeAccent,
    this.pointColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HandOverlayPainter(
        landmarks: landmarks,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        isFist: isFist,
        lineColor: isFist ? fistColor : openHandColor,
        pointColor: pointColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _HandOverlayPainter extends CustomPainter {
  final List<HandLandmark> landmarks;
  final int imageWidth;
  final int imageHeight;
  final bool isFist;
  final Color lineColor;
  final Color pointColor;

  const _HandOverlayPainter({
    required this.landmarks,
    required this.imageWidth,
    required this.imageHeight,
    required this.isFist,
    required this.lineColor,
    required this.pointColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty ||
        imageWidth <= 0 ||
        imageHeight <= 0 ||
        size.isEmpty) {
      return;
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    Offset pointAt(int index) {
      final point = landmarks[index];
      return Offset(point.x * size.width, point.y * size.height);
    }

    for (final connection in _handConnections) {
      if (connection[0] >= landmarks.length ||
          connection[1] >= landmarks.length) {
        continue;
      }
      canvas.drawLine(pointAt(connection[0]), pointAt(connection[1]), linePaint);
    }

    for (var index = 0; index < landmarks.length; index++) {
      canvas.drawCircle(pointAt(index), 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandOverlayPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.isFist != isFist ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor;
  }
}