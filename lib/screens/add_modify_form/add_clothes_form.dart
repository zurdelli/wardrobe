import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes/clothes_dao.dart';
import 'package:wardrobe/data/clothes/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/brand_model_row/brand_model.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/photo_row/photo_row.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/store_place_date/store_place_date.dart';
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
    currentUser = context.read<UserProvider>().currentUser;
    currentCategory = context.read<CategoryProvider>().currentCategory;
    _clothesRef = FirebaseDatabase.instance
        .ref()
        .child('clothes/$currentUser/$currentCategory');
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nodeKey = ModalRoute.of(context)!.settings.arguments.toString();
      print(nodeKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Add/Modify")),
        floatingActionButton: saveClothes(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
          child: Column(children: [
            categoryRow(),
            const PhotoRow(),
            const BrandModelRow(),
            const StoreDatePlace()
          ]),
        ));
  }

  Widget categoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Categoría"),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateUser())),
          child: Text(Provider.of<CategoryProvider>(context, listen: false)
              .currentCategory),
        )
      ],
    );
  }

  Widget saveClothes() {
    return FloatingActionButton.extended(
        onPressed: () {
          ClothesDAO().guardarClothes(
              Clothes(
                  subcategory: 'camisetas deportivas',
                  brand: context.read<ClothesProvider>().brand,
                  color: 'black',
                  status: 'new',
                  size: 'L',
                  place: context.read<ClothesProvider>().place,
                  date: context.read<ClothesProvider>().date,
                  store: context.read<ClothesProvider>().store,
                  warranty: 0,
                  image: context.read<ClothesProvider>().photoAsString,
                  hasBeenLent: false),
              _clothesRef,
              currentUser,
              currentCategory,
              nodeKey);
          Navigator.pop(context);
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save));
  }
}
