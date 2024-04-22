import 'package:flutter/material.dart';
import 'package:wardrobe/utilities.dart';

class FiltersSizeWidget extends StatefulWidget {
  const FiltersSizeWidget({Key? key}) : super(key: key);

  @override
  _FiltersSizeWidgetState createState() => _FiltersSizeWidgetState();
}

class _FiltersSizeWidgetState extends State<FiltersSizeWidget> {
  String? filterSize = "";

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        isDense: true,
        underline: SizedBox(),
        value: filterSize,
        onChanged: (String? value) {
          setState(() {
            filterSize = value;
          });
        },
        items: sizesListClothes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList());
  }
}

class FiltersStoreWidget extends StatefulWidget {
  const FiltersStoreWidget({Key? key}) : super(key: key);

  @override
  _FiltersStoreWidgetState createState() => _FiltersStoreWidgetState();
}

class _FiltersStoreWidgetState extends State<FiltersStoreWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
