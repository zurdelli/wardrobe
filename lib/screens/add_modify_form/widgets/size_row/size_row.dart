import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wardrobe/provider/clothes_provider.dart';

class SizeRow extends StatefulWidget {
  const SizeRow({Key? key}) : super(key: key);

  @override
  _SizeRowState createState() => _SizeRowState();
}

class _SizeRowState extends State<SizeRow> {
  List<String> labels = const ["XXS", "XS", "S", "M", "L", "XL", "XXL"];

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ToggleSwitch(
        minWidth: 90.0,
        minHeight: 50.0,
        curve: Curves.bounceInOut,

        initialLabelIndex: 4,
        cornerRadius: 0.0,
        activeFgColor: Colors.white,
        inactiveBgColor: Colors.transparent,
        inactiveFgColor: Colors.white,
        totalSwitches: 7,
        labels: labels,
        iconSize: 15.0,
        dividerColor: Colors.transparent,

        //borderWidth: 1.0,
        activeBorders: [Border.all(color: Colors.blueGrey)],
        animate: true,
        //borderColor: [Colors.blueGrey],
        // activeBgColors: const [
        //   [Colors.cyan],
        //   [Colors.blue],
        //   [Colors.green],
        //   [Colors.lime],
        //   [Colors.orange],
        //   [Colors.red],
        //   [Colors.purple]
        // ],
        onToggle: (index) {
          context.read<ClothesProvider>().size = labels[index!];
        },
      ),
    ]);
  }
}
