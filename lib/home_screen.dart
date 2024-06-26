import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rust_applications/messages/tutorial_resource.pb.dart';
import 'package:rust_applications/messages/vips_overlay.pb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: StreamBuilder(
              stream: MyTreasureOutput.rustSignalStream,
              builder: (context, snapshot) {
                final rustSignal = snapshot.data;
                if (rustSignal == null) {
                  return const Text('No value yet');
                }
                final myTreasureOutput = rustSignal.message;
                final currentNumber = myTreasureOutput.currentValue;

                return Text('Output value is $currentNumber');
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              MyTreasureInput().sendSignalToRust();
            },
            child: const Text('Send the input'),
          ),
          Center(
            child: StreamBuilder(
              stream: OverlayOutputData.rustSignalStream,
              builder: (context, snapshot) {
                final rustSignal = snapshot.data;
                if (rustSignal == null) {
                  return const Text('No value yet');
                }
                final myTreasureOutput = rustSignal.message;
                final currentNumber = myTreasureOutput.outputImage;
                // print("==treasure=======>>>>>>>>>${myTreasureOutput}");
                // print("===current======>>>>>>>>>${currentNumber}");
                // print("===rustsing======>>>>>>>>>${rustSignal}");
                // print("=======mess==>>>>>>>>>${rustSignal.message}");
                // log(Image.memory(currentNumber as Uint8List).toString());
                return Image.memory(currentNumber as Uint8List);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final watermark = await rootBundle.load('asset/image/frame_overlay.png');

            final blendImage = await rootBundle.load('asset/image/imagefream.png');
            final logoImage = await rootBundle.load('asset/image/logo.png');

            final watermarkBytes = watermark.buffer.asUint8List();
            final blendImageBytes = blendImage.buffer.asUint8List();
            final logoImageBytes = logoImage.buffer.asUint8List();

            // print('Watermark bytes length: ${watermarkBytes.length}');
            // print('BlendImage bytes length: ${blendImageBytes.length}');

            OverlayInputData data = OverlayInputData(
                inputImage: blendImageBytes, overlayImage: watermarkBytes, logoImage: logoImageBytes, logoHeight: 100
                // overlayWidth: 200,
                // overlayHeight: 200,
                // overlayX: 50,
                // overlayY: 50,
                // logoWidth: 100,
                // logoHeight: 100,
                // logoX: 10,
                // logoY: 10,
                );
            data.sendSignalToRust();
          } catch (e) {
            print('Error: $e');
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
