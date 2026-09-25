import 'package:flutter/material.dart';
import 'package:hand_interaction/hand_interaction.dart';

void main() => runApp(const HandInteractionExampleApp());

class HandInteractionExampleApp extends StatelessWidget {
  const HandInteractionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Interaction Example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HandInteractionExamplePage(),
    );
  }
}

class HandInteractionExamplePage extends StatefulWidget {
  const HandInteractionExamplePage({super.key});

  @override
  State<HandInteractionExamplePage> createState() =>
      _HandInteractionExamplePageState();
}

class _HandInteractionExamplePageState
    extends State<HandInteractionExamplePage> {
  static const double _imageWidth = 320;
  static const double _imageHeight = 440;

  final List<DemoItem> _items = const [
    DemoItem(
      id: 'cup',
      label: 'Cup',
      box: Rect.fromLTWH(96, 250, 128, 112),
    ),
  ];

  late final HandInteractionController<DemoItem> _controller =
      HandInteractionController<DemoItem>(
    boxOf: (item) => item.box,
    keyOf: (item) => item.id,
    onSelected: (item) => setState(() => _selectedLabel = item.label),
  );

  String _selectedLabel = 'Nothing selected yet';
  bool _showFist = false;

  List<HandLandmark> get _landmarks =>
      _showFist ? _fistLandmarks : _openHandLandmarks;

  void _setGesture(bool fist) {
    setState(() => _showFist = fist);
    _controller.processFrame(
      landmarks: _landmarks,
      items: _items,
      imageWidth: _imageWidth,
      imageHeight: _imageHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('hand_interaction'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overlay'),
              Tab(text: 'Interaction'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverlayTab(),
            _buildInteractionTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayTab() {
    return Center(
      child: SizedBox(
        width: _imageWidth,
        height: _imageHeight,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: Color(0xffe8f1ef)),
            ),
            const Positioned(
              left: 96,
              top: 250,
              width: 128,
              height: 112,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.teal, width: 2),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(child: Text('Example object')),
              ),
            ),
            Positioned.fill(
              child: HandOverlay(
                landmarks: _openHandLandmarks,
                imageWidth: _imageWidth.toInt(),
                imageHeight: _imageHeight.toInt(),
                isFist: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SizedBox(
          height: 320,
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xffe8f1ef)),
              ),
              for (final item in _items)
                Positioned.fromRect(
                  rect: item.box,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(item.label)),
                  ),
                ),
              Positioned.fill(
                child: HandOverlay(
                  landmarks: _landmarks,
                  imageWidth: _imageWidth.toInt(),
                  imageHeight: _imageHeight.toInt(),
                  isFist: _showFist,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Selection: $_selectedLabel'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton(
              onPressed: () => _setGesture(false),
              child: const Text('Open hand'),
            ),
            FilledButton(
              onPressed: () => _setGesture(true),
              child: const Text('Close fist over object'),
            ),
          ],
        ),
      ],
    );
  }
}

class DemoItem {
  final String id;
  final String label;
  final Rect box;

  const DemoItem({required this.id, required this.label, required this.box});
}

const List<HandLandmark> _openHandLandmarks = [
  HandLandmark(x: .50, y: .88, z: 0),
  HandLandmark(x: .40, y: .75, z: 0),
  HandLandmark(x: .34, y: .68, z: 0),
  HandLandmark(x: .29, y: .60, z: 0),
  HandLandmark(x: .25, y: .52, z: 0),
  HandLandmark(x: .40, y: .57, z: 0),
  HandLandmark(x: .38, y: .48, z: 0),
  HandLandmark(x: .37, y: .39, z: 0),
  HandLandmark(x: .36, y: .30, z: 0),
  HandLandmark(x: .49, y: .55, z: 0),
  HandLandmark(x: .49, y: .44, z: 0),
  HandLandmark(x: .49, y: .33, z: 0),
  HandLandmark(x: .49, y: .22, z: 0),
  HandLandmark(x: .58, y: .57, z: 0),
  HandLandmark(x: .60, y: .47, z: 0),
  HandLandmark(x: .61, y: .38, z: 0),
  HandLandmark(x: .62, y: .30, z: 0),
  HandLandmark(x: .66, y: .62, z: 0),
  HandLandmark(x: .70, y: .55, z: 0),
  HandLandmark(x: .73, y: .48, z: 0),
  HandLandmark(x: .75, y: .41, z: 0),
];

final List<HandLandmark> _fistLandmarks = List.generate(21, (index) {
  if (index == 0) return const HandLandmark(x: .50, y: .84, z: 0);
  if (index == 9) return const HandLandmark(x: .50, y: .55, z: 0);
  if ([4, 8, 12, 16, 20].contains(index)) {
    return const HandLandmark(x: .52, y: .68, z: 0);
  }
  if ([1, 5, 6, 7, 10, 11, 13, 14, 15, 17, 18, 19].contains(index)) {
    return const HandLandmark(x: .50, y: .62, z: 0);
  }
  return const HandLandmark(x: .50, y: .70, z: 0);
});