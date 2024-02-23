import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes/clothes_dao.dart';
import 'package:wardrobe/data/clothes/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/brand_model_row/brand_model.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/colors_row/colors.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/photo_row/photo_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/size_row/size_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/store_place_date_warranty/store_place_date_warranty.dart';
import 'package:wardrobe/screens/register.dart';
import 'package:wardrobe/utilities.dart';

/// Representa el formulario para agregar/modificar alguna ropa
/// Cada prenda debe tener, entre otra info:
/// Una foto
///  Tienda/Lugar donde fue adquirida y la fecha
/// Si está en garantía actualmente
/// Lugar donde se encuentra actualmente
/// Categoría (jerséis, chaquetas, pantalones, etc)
/// Color
/// Estado ( Nuevo/ Bueno/ Regular)
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
        appBar: AppBar(title: const Text("Add/Modify")),
        floatingActionButton: saveClothes(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              categoryRow(currentCategory),
              myRow(child: const PhotoRow(), titulo: "Foto"),
              myRow(child: const BrandModelRow(), titulo: "Marca"),
              myRow(child: const StoreDatePlaceWarranty(), titulo: "Tienda"),
              myRow(child: const SizeRow(), titulo: "Tamaño"),
              ColorsRow()
            ]),
          ),
        ));
  }

  Widget myRow({required Widget child, required String titulo}) {
    return Column(
      children: [
        SizedBox(width: 0.0, height: 5),
        Row(
          children: [
            const Expanded(flex: 1, child: Divider()),
            Text("  $titulo  ",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Expanded(flex: 9, child: Divider()),
          ],
        ),
        SizedBox(width: 0.0, height: 5),
        child
      ],
    );
  }

  Widget categoryRow(String categoria) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Categoría"),
        DropdownButton(
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
        )
      ],
    );
  }

  Widget saveClothes() {
    return FloatingActionButton.extended(
        onPressed: () {
          if (context.read<ClothesProvider>().place.isNotEmpty) {
            ClothesDAO().guardarClothes(
                Clothes(
                    brand: context.read<ClothesProvider>().brand,
                    color: colorToString(context.read<ClothesProvider>().color),
                    date: context.read<ClothesProvider>().date,
                    hasBeenLent: context.read<ClothesProvider>().hasBeenLent,
                    holder: context.read<UserProvider>().currentEmail,
                    image: context.read<ClothesProvider>().image,
                    owner: context.read<UserProvider>().currentEmail,
                    place: context.read<ClothesProvider>().place,
                    size: context.read<ClothesProvider>().size,
                    store: context.read<ClothesProvider>().store,
                    sublocation: context.read<ClothesProvider>().sublocation,
                    warranty: context.read<ClothesProvider>().warranty),
                _clothesRef,
                currentUser,
                currentCategory,
                nodeKey);
            Navigator.pop(context);
          } else {
            mySnackBar(
                context, "Debes decirme donde está la prenda actualmente");
          }
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save));
  }
}
