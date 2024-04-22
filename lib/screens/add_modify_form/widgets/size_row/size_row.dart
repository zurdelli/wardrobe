import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';

class SizeRow extends StatefulWidget {
  const SizeRow({Key? key}) : super(key: key);

  @override
  _SizeRowState createState() => _SizeRowState();
}

class _SizeRowState extends State<SizeRow> {
  List<String> tallasRopa = const ["XXS", "XS", "S", "M", "L", "XL", "XXL"];
  String categoria = "";
  double _currentSliderValue = 47;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoria = context.read<CategoryProvider>().currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      categoria == "Zapatillas"
          ? Expanded(
              child: Slider(
                value: _currentSliderValue,
                min: 34,
                max: 50,
                divisions: 32,
                label: _currentSliderValue.toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
            )
          : ToggleSwitch(
              minWidth: 90.0,
              minHeight: 50.0,
              curve: Curves.bounceInOut,
              initialLabelIndex: null,
              cornerRadius: 0.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.transparent,
              inactiveFgColor: Colors.white,
              totalSwitches: 7,
              labels: tallasRopa,
              iconSize: 15.0,
              dividerColor: Colors.transparent,
              activeBorders: [Border.all(color: Colors.blueGrey)],
              animate: true,
              onToggle: (index) {
                context.read<ClothesProvider>().size = tallasRopa[index!];
              },
            ),
    ]);
  }
}
