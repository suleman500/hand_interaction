import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'hand_landmark.dart';

/// Returns true when the mean wrist-to-fingertip distance is small relative
/// to the wrist-to-middle-MCP distance.
///
/// The expected landmark order is the common 21-point hand layout: wrist at
/// index 0, middle MCP at 9, and fingertips at 4, 8, 12, 16, and 20.
bool isFistGesture(
  List<HandLandmark> landmarks, {
  double fistThreshold = 0.9,
}) {
  if (landmarks.length < 21) return false;

  final wrist = landmarks[0];
  final middleMcp = landmarks[9];
  final handSize = _distance(wrist, middleMcp);
  if (handSize < 1e-6) return false;

  const fingertipIndices = [4, 8, 12, 16, 20];
  final averageDistance = fingertipIndices
          .map((index) => _distance(wrist, landmarks[index]))
          .reduce((total, value) => total + value) /
      fingertipIndices.length;

  return averageDistance / handSize < fistThreshold;
}

/// Returns the hand's axis-aligned bounding box in image-pixel coordinates.
Rect? handBounds(
  List<HandLandmark> landmarks, {
  required double imageWidth,
  required double imageHeight,
}) {
  if (landmarks.isEmpty || imageWidth <= 0 || imageHeight <= 0) return null;

  var minX = landmarks.first.x;
  var minY = landmarks.first.y;
  var maxX = landmarks.first.x;
  var maxY = landmarks.first.y;

  for (final point in landmarks.skip(1)) {
    minX = math.min(minX, point.x);
    minY = math.min(minY, point.y);
    maxX = math.max(maxX, point.x);
    maxY = math.max(maxY, point.y);
  }

  return Rect.fromLTRB(
    minX * imageWidth,
    minY * imageHeight,
    maxX * imageWidth,
    maxY * imageHeight,
  );
}

/// Finds the first item whose [boxOf] rectangle contains the index-8
/// fingertip. Rectangles and image dimensions use image-pixel coordinates;
/// landmarks use normalized coordinates.
T? findTouchedItem<T>({
  required List<HandLandmark> landmarks,
  required List<T> items,
  required Rect Function(T item) boxOf,
  required double imageWidth,
  required double imageHeight,
  double touchTolerance = 10.0,
}) {
  if (landmarks.length <= 8 || imageWidth <= 0 || imageHeight <= 0) {
    return null;
  }

  final fingertip = landmarks[8];
  final point = Offset(fingertip.x * imageWidth, fingertip.y * imageHeight);

  for (final item in items) {
    if (boxOf(item).inflate(touchTolerance).contains(point)) return item;
  }

  return null;
}

double _distance(HandLandmark first, HandLandmark second) {
  final dx = first.x - second.x;
  final dy = first.y - second.y;
  return math.sqrt(dx * dx + dy * dy);
}