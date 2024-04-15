import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/utilities.dart';

class ColorsRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ColorsRowState();
}

class _ColorsRowState extends State<ColorsRow> {
  Color _color = Colors.transparent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _color = context.read<ClothesProvider>().color;
    });
  }

  void setcolor(Color newColor) => setState(() {
        _color = newColor;
        context.read<ClothesProvider>().color = _color;
      });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          //minimumSize: Size(160, 60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          side: BorderSide(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
              width: 0.5),
          backgroundColor: _color,
          foregroundColor: _color == Colors.white ||
                  MediaQuery.of(context).platformBrightness == Brightness.light
              ? Colors.black
              : Colors.white),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Pick a color"),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: _color,
                  onColorChanged: (value) => setcolor(value),
                  availableColors: colors,
                  layoutBuilder: pickerLayoutBuilder,
                  itemBuilder: pickerItemBuilder,
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Text.rich(
        TextSpan(
          children: [
            const WidgetSpan(child: Icon(Icons.color_lens)),
            TextSpan(
                text: colorToString(_color).isEmpty
                    ? 'Color'
                    : colorToString(_color))
          ],
        ),
      ),
    );
  }
}
