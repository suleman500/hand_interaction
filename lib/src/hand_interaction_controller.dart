import 'dart:ui' show Rect;

import 'hand_gesture_math.dart';
import 'hand_landmark.dart';

/// Snapshot of the interaction state produced for one frame.
class HandInteractionResult<T> {
  final bool isFist;
  final T? touchedItem;
  final Object? touchedKey;
  final T? selectedItem;
  final Object? selectedKey;
  final List<HandLandmark> landmarks;

  const HandInteractionResult({
    required this.isFist,
    required this.touchedItem,
    required this.touchedKey,
    required this.selectedItem,
    required this.selectedKey,
    required this.landmarks,
  });

  /// True only on the frame where [selectedItem] was triggered.
  bool get selectionTriggered => selectedItem != null;
}

/// Detects a fist gesture over a touched item and invokes [onSelected].
///
/// Input landmarks use normalized coordinates (0..1); item rectangles and
/// [imageWidth]/[imageHeight] use image-pixel coordinates. Selection is
/// triggered on the transition from an open hand to a fist, with a cooldown.
/// This controller does not obtain hand landmarks; provide them from any
/// tracking or vision system.
class HandInteractionController<T> {
  final Rect Function(T item) boxOf;
  final Object? Function(T item) keyOf;
  final void Function(T item) onSelected;
  final Duration selectionCooldown;
  final double touchTolerance;
  final double fistThreshold;

  DateTime? _lastSelectionAt;
  bool _wasFistLastFrame = false;

  HandInteractionController({
    required this.boxOf,
    required this.keyOf,
    required this.onSelected,
    this.selectionCooldown = const Duration(seconds: 3),
    this.touchTolerance = 10.0,
    this.fistThreshold = 0.9,
  });

  HandInteractionResult<T> processFrame({
    required List<HandLandmark> landmarks,
    required List<T> items,
    required double imageWidth,
    required double imageHeight,
    DateTime? now,
  }) {
    final fist = isFistGesture(landmarks, fistThreshold: fistThreshold);
    final touched = findTouchedItem<T>(
      landmarks: landmarks,
      items: items,
      boxOf: boxOf,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      touchTolerance: touchTolerance,
    );

    T? selected;
    if (touched != null && fist && !_wasFistLastFrame) {
      final timestamp = now ?? DateTime.now();
      final cooldownElapsed = _lastSelectionAt == null ||
          timestamp.difference(_lastSelectionAt!) > selectionCooldown;

      if (cooldownElapsed) {
        _lastSelectionAt = timestamp;
        selected = touched;
        onSelected(touched);
      }
    }

    _wasFistLastFrame = fist;

    return HandInteractionResult<T>(
      isFist: fist,
      touchedItem: touched,
      touchedKey: touched == null ? null : keyOf(touched),
      selectedItem: selected,
      selectedKey: selected == null ? null : keyOf(selected),
      landmarks: List<HandLandmark>.unmodifiable(landmarks),
    );
  }

  /// Clears the fist-edge and cooldown state.
  void reset() {
    _lastSelectionAt = null;
    _wasFistLastFrame = false;
  }
}