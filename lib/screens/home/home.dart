import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes/clothes_dao.dart';
import 'package:wardrobe/data/clothes/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/login.dart';
import 'package:wardrobe/utilities.dart';
import 'package:wardrobe/screens/home/widgets/clothes_widget.dart';

/// Representa la pantalla general, aqui sera un vistazo general de las prendas
/// de ropa que tenga un usuario junto a su ubicacion
class MyWardrobe extends StatefulWidget {
  const MyWardrobe({Key? key}) : super(key: key);

  @override
  MyWardrobeState createState() => MyWardrobeState();
}

class MyWardrobeState extends State<MyWardrobe> {
  // Para saber si he llegado al final del screen
  final ScrollController _scrollController = ScrollController();
  int cantidad = 0;

  String categoria = "", user = "", userName = "", place = "";
  var query;
  var dbReference;
  var key;

  @override
  void initState() {
    super.initState();

    categoria = "Camisetas";
    user = FirebaseAuth.instance.currentUser?.uid ?? "";
    userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
    cantidad = 0;
    key = Key(DateTime.now().millisecondsSinceEpoch.toString());
    dbReference =
        FirebaseDatabase.instance.ref().child('clothes/$user/$categoria');
    query = dbReference.orderByChild('place').equalTo(place);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var myPlace = await getLocation();
      setState(() {
        place = myPlace;
        context.read<LocationProvider>().currentLocation = place;
        context.read<CategoryProvider>().currentCategory = categoria;
        updateQuery(categoriaLocal: categoria, placeLocal: place);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('wardrobe'), actions: [
        InkWell(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false);
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.exit_to_app),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.read<ClothesProvider>().brand = "";
          context.read<ClothesProvider>().color = stringToColor("Red");
          context.read<ClothesProvider>().date =
              DateFormat('dd-MM-yyyy').format(DateTime.now());
          context.read<ClothesProvider>().hasBeenLent = false;
          context.read<ClothesProvider>().holder = "";
          context.read<ClothesProvider>().image = "";
          context.read<ClothesProvider>().owner = "";
          context.read<ClothesProvider>().place = "";
          context.read<ClothesProvider>().size = "";
          //context.read<ClothesProvider>().status = "";
          context.read<ClothesProvider>().store = "";
          context.read<ClothesProvider>().sublocation = "";
          context.read<ClothesProvider>().warranty = "";
          Navigator.pushNamed(context, "/formclothes").then((_) {});
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            userAndLocationRow(),
            categoriesRow(),
            _getMyWardrobe(),
          ],
        ),
      ),
    );
  }

  Widget userAndLocationRow() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Hola, $userName!"),
          Text(" estás en: $place"),
        ],
      ),
    );
  }

  dialogLocations() {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        // ignore: prefer_const_constructors
        child: AlertDialog(
          title: const Text("Ubicaciones favoritas"),
          shape: LinearBorder(),
          content: SingleChildScrollView(child: gimmeLocations()),
          actions: <Widget>[
            TextButton(
              child: const Text('Añadir'),
              onPressed: () {
                addOrEditLocation("", "");
              },
            ),
            TextButton(
              child: const Text('Salir'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget gimmeLocations() {
    return SizedBox(
      width: 150,
      height: 150,
      child: FirebaseAnimatedList(
        query:
            FirebaseDatabase.instance.ref().child('clothes/$user/Ubicaciones'),
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final ubicacion = json['ubicacion'] as String;
          final key = snapshot.key;
          return SubmenuButton(menuChildren: [
            TextButton(
                onPressed: () {
                  updateQuery(
                      categoriaLocal:
                          context.read<CategoryProvider>().currentCategory,
                      placeLocal: ubicacion);
                  Navigator.of(context).pop();
                },
                child: Text("Seleccionar")),
            TextButton(
                onPressed: () => addOrEditLocation(ubicacion, key!),
                child: Text("Editar")),
            TextButton(onPressed: () {}, child: Text("Borrar")),
          ], child: Text(ubicacion));
        },
      ),
    );
  }

  addOrEditLocation(String location, String key) {
    TextEditingController locationController = TextEditingController();
    locationController.text = location;
    showDialog(
        context: context,
        builder: (BuildContext context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              // ignore: prefer_const_constructors
              child: AlertDialog(
                title: const Text("Ubicaciones favoritas"),
                shape: LinearBorder(),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ubicación'),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      DatabaseReference myRef;
                      if (location.isEmpty) {
                        myRef = FirebaseDatabase.instance
                            .ref()
                            .child('clothes/$user/Ubicaciones')
                            .push();
                      } else {
                        myRef = FirebaseDatabase.instance
                            .ref()
                            .child('clothes/$user/Ubicaciones/$key');
                      }
                      myRef.set(<String, String>{
                        'ubicacion': locationController.text
                      });
                      updateQuery(
                          categoriaLocal:
                              context.read<CategoryProvider>().currentCategory,
                          placeLocal: locationController.text);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ));
  }

  updateQuery({required String categoriaLocal, required String placeLocal}) {
    setState(() {
      categoria =
          context.read<CategoryProvider>().currentCategory = categoriaLocal;
      place = context.read<LocationProvider>().currentLocation = placeLocal;
      dbReference =
          FirebaseDatabase.instance.ref().child('clothes/$user/$categoria');
      query = dbReference.orderByChild('place').equalTo(place);
      countChildren(dbReference);
      key = Key(DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  Widget categoriesRow() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: categoriesListTipos.length,
          separatorBuilder: (_, __) => const SizedBox(
                width: 16,
              ),
          itemBuilder: (context, index) {
            return categoriesWidget(
              nombre: categoriesListTipos[index],
              image: categoriesListImages[index],
            );
          }),
    );
  }

  Widget categoriesWidget({required String nombre, required String image}) {
    return GestureDetector(
        onTap: () {
          updateQuery(
              categoriaLocal: nombre,
              placeLocal: context.read<LocationProvider>().currentLocation);
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCirc,
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              alignment: Alignment.center,
              height: 60.0,
              width: 60.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amberAccent,
              ),
              child: Image.asset(image),
            ),
            SizedBox(height: 4.0),
            Container(
              width: 60,
              child: Text(
                nombre,
                style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ));
  }

  Widget _getMyWardrobe() {
    return Expanded(
      child: Column(
        children: [
          Text.rich(
            TextSpan(text: "$cantidad $categoria en ", children: [
              TextSpan(
                text: context.read<LocationProvider>().currentLocation,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    dialogLocations();
                  },
              )
            ]),
          ),
          const SizedBox(height: 15),
          Expanded(
              child: FirebaseAnimatedList(
            key: key,
            controller: _scrollController,
            query: query,
            itemBuilder: (context, snapshot, animation, index) {
              final json = snapshot.value as Map<dynamic, dynamic>;
              final prenda = Clothes.fromJson(json);
              final nodeKey = snapshot.key;
              return ClothesWidget(clothes: prenda, nodeKey: nodeKey);
            },
          )),
        ],
      ),
    );
  }

  /// Cuenta el numero de hijos de un nodo, para contar la cantidad de ropa
  countChildren(DatabaseReference fromPath) async {
    final event = await fromPath.once(DatabaseEventType.value);
    int length = event.snapshot.children.length;
    setState(() => cantidad = length);
  }
}
