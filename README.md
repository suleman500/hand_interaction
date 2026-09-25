# hand_interaction

A lightweight, source-agnostic Flutter package for turning 21-point hand landmarks into fist-gesture detection and object-touch interactions, with an optional display-only overlay widget.

The package contains a small landmark value type, reusable gesture math, a generic interaction controller, and a painter-backed overlay widget. It does not include a camera plugin, hand-tracking model, or platform channel.

## Add the dependency

Add `hand_interaction` to your Flutter application's dependencies, then import the public barrel:

```dart
import 'dart:ui' show Rect;

import 'package:hand_interaction/hand_interaction.dart';
```

## Display-only overlay

`HandOverlay` only draws the landmarks supplied to it. Put it in a `Stack` that has the same bounds as the source image or camera preview. Landmark `x` and `y` coordinates are normalized from 0.0 to 1.0.

```dart
Stack(
  children: [
    CameraPreview(cameraController),
    Positioned.fill(
      child: HandOverlay(
        landmarks: myLandmarks,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        isFist: false,
      ),
    ),
  ],
)
```

## Object-touch interaction

Provide a rectangle and stable key for your own item type. `processFrame` receives one frame's landmarks and items. The callback fires when a fist begins while the index fingertip (landmark 8) touches an item, subject to the controller's cooldown.

```dart
class MyItem {
  final String id;
  final Rect myBoundingBox;

  const MyItem(this.id, this.myBoundingBox);
}

final controller = HandInteractionController<MyItem>(
  boxOf: (item) => item.myBoundingBox,
  keyOf: (item) => item.id,
  onSelected: (item) => print('Selected: $item'),
);

final result = controller.processFrame(
  landmarks: landmarks,
  items: items,
  imageWidth: frameWidth,
  imageHeight: frameHeight,
);

if (result.isFist && result.touchedItem != null) {
  print('Touching ${result.touchedKey}');
}
```

Call `controller.reset()` when starting a new interaction session if you want to clear the fist-edge and cooldown state. Gesture thresholds and the selection cooldown can be configured in the controller constructor.

## Landmark source

This package does **not** provide hand landmarks. Your application must supply its own source, such as MediaPipe, ML Kit, or another tracker that returns 21 points in the common hand-landmark order. Landmark `x` and `y` must be normalized to the input image size; `z` is carried through but not used by the gesture math. The controller expects item rectangles in image-pixel coordinates.

## License

MIT. See [LICENSE](LICENSE).