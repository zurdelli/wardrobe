import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';

/// Brand & Model
class BrandModelRow extends StatefulWidget {
  const BrandModelRow({super.key});

  @override
  State<StatefulWidget> createState() => _BrandModelRowState();
}

class _BrandModelRowState extends State<BrandModelRow> {
  String brand = "";
  String model = "";

  final brandController = TextEditingController();
  final modelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    brand = context.read<ClothesProvider>().brand;
    model = context.read<ClothesProvider>().model;
    brandController.text = brand;
    modelController.text = model;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            onTapOutside: (event) => context.read<ClothesProvider>().brand =
                brandController.text.trim(),
            controller: brandController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Marca'),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 3,
          child: TextFormField(
            onTapOutside: (event) => context.read<ClothesProvider>().model =
                modelController.text.trim(),
            controller: modelController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Modelo'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    brandController.dispose();
    modelController.dispose();
  }
}
