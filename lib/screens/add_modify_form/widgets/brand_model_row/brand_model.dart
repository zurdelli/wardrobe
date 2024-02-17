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

  @override
  void initState() {
    super.initState();
    brand = context.read<ClothesProvider>().brand;
    brandController.text = brand;
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
            //controller: brandController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Modelo'),
          ),
        ),
      ],
    );
  }
}
