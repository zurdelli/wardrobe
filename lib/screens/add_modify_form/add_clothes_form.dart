import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes_model.dart';
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
///  Tienda/Lugar donde fue adquirida y la fecha
/// Si está en garantía actualmente
///  Lugar donde se encuentra actualmente
///  Tipo (jerséis, chaquetas, pantalones, etc)
///  Color
/// Estado ( Nuevo/ Bueno/ Regular)
/// En caso de haber sido prestada, usuario actual

class ClothesForm extends StatefulWidget {
  const ClothesForm({super.key});

  @override
  State<ClothesForm> createState() => _ClothesFormState();
}

class _ClothesFormState extends State<ClothesForm> {
  late Clothes clothes;
  String currentUser = "", currentCategory = "";
  late DatabaseReference _clothesRef;
  bool amImodifying = false;

  updateClothes(Clothes prenda) {
    context.read<ClothesProvider>().brand = prenda.brand;
    context.read<ClothesProvider>().color = stringToColor(prenda.color);
    context.read<ClothesProvider>().date = prenda.date;
    context.read<ClothesProvider>().photoAsString = prenda.image;
    context.read<ClothesProvider>().place = prenda.place;
    context.read<ClothesProvider>().size = prenda.size;
    context.read<ClothesProvider>().status = prenda.status;
    context.read<ClothesProvider>().store = prenda.store;

    if (prenda.image.isNotEmpty) amImodifying == true;
  }

  @override
  void initState() {
    currentUser = context.read<UserProvider>().currentUser;
    currentCategory = context.read<CategoryProvider>().currentCategory;
    _clothesRef =
        FirebaseDatabase.instance.ref().child('$currentUser/$currentCategory');
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateClothes(ModalRoute.of(context)!.settings.arguments as Clothes);
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
          guardarPrenda(Clothes(
              subcategory: 'camisetas deportivas',
              brand: Provider.of<ClothesProvider>(context, listen: false)
                  .brand
                  .trim(),
              color: 'black',
              status: 'new',
              size: 'L',
              place: Provider.of<ClothesProvider>(context, listen: false)
                  .place
                  .trim(),
              date: Provider.of<ClothesProvider>(context, listen: false)
                  .date
                  .trim(),
              store: Provider.of<ClothesProvider>(context, listen: false)
                  .store
                  .trim(),
              warranty: 0,
              image: context.read<ClothesProvider>().photoAsString));
          Navigator.pop(context);
        },
        label: const Text("Save"),
        icon: const Icon(Icons.save));
  }

  String? guardarPrenda(Clothes prenda) {
    if (!amImodifying) {
      DatabaseReference myRef = _clothesRef.push();
      myRef.set(prenda.toJson());
      return myRef.key;
    } else {}
    return "";
  }

  Query getClothes() => _clothesRef;
}
