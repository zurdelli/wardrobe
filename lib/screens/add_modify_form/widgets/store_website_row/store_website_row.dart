import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/utilities.dart';
import 'package:toggle_switch/toggle_switch.dart';

class StoreWebsite extends StatefulWidget {
  const StoreWebsite({super.key});

  @override
  State<StatefulWidget> createState() => _StoreWebsiteState();
}

class _StoreWebsiteState extends State<StoreWebsite> {
  String store = "";
  String website = "";

  final storeController = TextEditingController();
  final websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = context.read<ClothesProvider>().store;
      website = context.read<ClothesProvider>().website;

      storeController.text = store;
      websiteController.text = website;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: storeController,
              onTapOutside: (event) => context.read<ClothesProvider>().store =
                  storeController.text.trim(),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
                labelText: 'Tienda',
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              controller: websiteController,
              onTapOutside: (event) => context.read<ClothesProvider>().website =
                  websiteController.text.trim(),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
                labelText: 'Website',
              ),
            ),
          ),
        ],
      )
    ]);
  }
}
