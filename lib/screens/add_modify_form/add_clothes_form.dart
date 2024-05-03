// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes/clothes_dao.dart';
import 'package:wardrobe/data/clothes/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/brand_model_row/brand_model.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/colors_row/colors.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/location_sublocation_row/location_sublocation_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/photo_row/photo_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/place_date_row/place_date_warranty_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/size_row/size_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/store_website_row/store_website_row.dart';
import 'package:wardrobe/utilities.dart';

/// Representa el formulario para agregar/modificar alguna ropa
/// Cada prenda debe tener, entre otra info:
/// Una foto
///  Tienda y página web
/// Lugar donde fue adquirida y la fecha
/// Si está en garantía actualmente
/// Lugar donde se encuentra actualmente
/// Categoría (jerséis, chaquetas, pantalones, etc)
/// Color
/// Si ha sido prestada y el usuario actual que la tiene

class ClothesForm extends StatefulWidget {
  const ClothesForm({super.key});

  @override
  State<ClothesForm> createState() => _ClothesFormState();
}

class _ClothesFormState extends State<ClothesForm> {
  String currentUser = "", currentCategory = "";
  late DatabaseReference _clothesRef;
  String nodeKey = "";
  bool estaAbierto = false;

  @override
  void initState() {
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    currentCategory = context.read<CategoryProvider>().currentCategory;
    _clothesRef = FirebaseDatabase.instance
        .ref()
        .child('clothes/$currentUser/$currentCategory');
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nodeKey = ModalRoute.of(context)!.settings.arguments.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Agregar/modificar")),
        floatingActionButton: saveClothes(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              const PhotoRow(),
              myRow(
                  child: categoryRow(currentCategory),
                  titulo: "Categoría y color"),
              myRow(child: const SublocationRow(), titulo: "Ubicación "),
              myRow(child: const BrandModelRow(), titulo: "Marca"),
              myRow(child: const SizeRow(), titulo: "Tamaño"),
              //myRow(child: ColorsRow(), titulo: "Color"),
              ExpansionPanelList(
                expansionCallback: (panelIndex, isExpanded) => setState(() {
                  estaAbierto = !estaAbierto;
                }),
                children: [
                  ExpansionPanel(
                      canTapOnHeader: true,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text("¿Es nuevo?"),
                          titleTextStyle: TextStyle(
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white),
                        );
                      },
                      body: Column(
                        children: [
                          myRow(child: const StoreWebsite(), titulo: "Tienda"),
                          myRow(
                              child: const PlaceDateWarranty(),
                              titulo: "Lugar y fecha"),
                          SizedBox(height: 80)
                        ],
                      ),
                      isExpanded: estaAbierto)
                ],
              ),
            ]),
          ),
        ));
  }

  Widget myRow({required Widget child, required String titulo}) {
    return Column(
      children: [
        const SizedBox(width: 0.0, height: 10),
        Row(
          children: [
            const Expanded(
                flex: 1,
                child: Divider(
                  thickness: 0.5,
                )),
            Text("  $titulo  ",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Expanded(flex: 9, child: Divider()),
          ],
        ),
        const SizedBox(width: 0.0, height: 10),
        child
      ],
    );
  }

  Widget categoryRow(String categoria) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownButton(
          isDense: true,
          underline: SizedBox(),
          value: categoria,
          onChanged: (String? value) {
            setState(() {
              currentCategory = value!;
              _clothesRef = FirebaseDatabase.instance
                  .ref()
                  .child('clothes/$currentUser/$currentCategory');
            });
          },
          items:
              categoriesListTipos.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        ColorsRow()
      ],
    );
  }

  Widget saveClothes() {
    return FloatingActionButton.extended(
        onPressed: () async {
          if (context.read<ClothesProvider>().place.isNotEmpty) {
            if (context.read<ClothesProvider>().image.isEmpty) {
              if (context.read<ClothesProvider>().imageCache.isNotEmpty) {
                await uploadToStorage(
                        context.read<ClothesProvider>().imageCache, context)
                    .then(
                  (value) {
                    final divider = value.indexOf('#');
                    context.read<ClothesProvider>().image =
                        value.substring(0, divider);
                    context.read<ClothesProvider>().thumbnail =
                        value.substring(divider + 1, value.length);
                  },
                );
              }
            }

            ClothesDAO().guardarClothes(
                Clothes(
                    brand: context.read<ClothesProvider>().brand,
                    color: colorToString(context.read<ClothesProvider>().color),
                    date: context.read<ClothesProvider>().date,
                    hasBeenLent: context.read<ClothesProvider>().hasBeenLent,
                    holder: context.read<ClothesProvider>().holder.isEmpty
                        ? FirebaseAuth.instance.currentUser!.email ?? ""
                        : context.read<ClothesProvider>().holder,
                    image: context.read<ClothesProvider>().image,
                    thumbnail: context.read<ClothesProvider>().thumbnail,
                    model: context.read<ClothesProvider>().model,
                    owner: context.read<ClothesProvider>().owner.isEmpty
                        ? FirebaseAuth.instance.currentUser!.email ?? ""
                        : context.read<ClothesProvider>().owner,
                    place: context.read<ClothesProvider>().place,
                    storePlace: context.read<ClothesProvider>().storePlace,
                    size: context.read<ClothesProvider>().size,
                    store: context.read<ClothesProvider>().store,
                    sublocation: context.read<ClothesProvider>().sublocation,
                    warranty: context.read<ClothesProvider>().warranty,
                    website: context.read<ClothesProvider>().website),
                _clothesRef,
                nodeKey);
            Navigator.pop(context);
          } else {
            mySnackBar(
                context, "Debes decirme donde está la prenda actualmente");
          }
        },
        label: const Text("Guardar"),
        icon: const Icon(Icons.save));
  }
}
