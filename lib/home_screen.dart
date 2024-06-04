import 'package:flutter/material.dart';
import 'package:rust_applications/messages/tutorial_resource.pb.dart';

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
        ],
      ),
    );
  }
}
