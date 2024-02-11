import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes_dao.dart';
import 'package:wardrobe/data/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/login.dart';
import 'package:wardrobe/utilities.dart';
import 'package:wardrobe/screens/home/widgets/clothes_widget.dart';

/// Representa la pantalla general, aqui sera un vistazo general de las prendas
/// de ropa que tenga un usuario junto a su ubicacion
class MyWardrobe extends StatefulWidget {
  MyWardrobe({Key? key}) : super(key: key);

  //final mensajeDAO = MensajeDAO();
  final clothesDAO = ClothesDAO();

  @override
  MyWardrobeState createState() => MyWardrobeState();
}

class MyWardrobeState extends State<MyWardrobe> {
  // Para saber si he llegado al final del screen
  final ScrollController _scrollController = ScrollController();

  String categoria = "",
      user = "",
      userName = "",
      place = "",
      currentPlace = "";
  var query;
  var key;

  @override
  void initState() {
    super.initState();

    categoria = "Camisetas";
    user = context.read<UserProvider>().currentUser;
    userName = context.read<UserProvider>().currentUserName;
    currentPlace = context.read<LocationProvider>().currentLocation;
    place = currentPlace;

    query = FirebaseDatabase.instance
        .ref()
        .child('$user/$categoria')
        .orderByChild('place')
        .equalTo(place);

    key = Key(DateTime.now().millisecondsSinceEpoch.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).currentCategory =
          categoria;
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
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.exit_to_app),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/formclothes",
                  arguments: Clothes(
                      subcategory: '',
                      brand: '',
                      image: '',
                      color: '',
                      date: DateTime.now().toString(),
                      place: '',
                      size: '',
                      status: '',
                      store: '',
                      warranty: 0))
              // Necesario para el reload de la listview
              .then((_) {});
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
          Expanded(
              child: Text(
                  "Hola, ${context.read<UserProvider>().currentUserName}!")),
          Text("Ubicación: $currentPlace"),
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
                addLocation();
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
        //key: key,
        //controller: _scrollController,
        query: FirebaseDatabase.instance.ref().child('$user/Ubicaciones'),
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final ubicacion = json['ubicacion'] as String;
          return TextButton(
              onPressed: () {
                //context.read<LocationProvider>().currentLocation = ubicacion;
                updateQuery(
                    categoriaLocal:
                        context.read<CategoryProvider>().currentCategory,
                    placeLocal: ubicacion);

                Navigator.of(context).pop();
              },
              child: Text(ubicacion));
        },
      ),
    );
  }

  addLocation() {
    TextEditingController locationController = TextEditingController();
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
                    child: const Text('Añadir'),
                    onPressed: () {
                      DatabaseReference myRef = FirebaseDatabase.instance
                          .ref()
                          .child('$user/Ubicaciones')
                          .push();
                      myRef.set(<String, String>{
                        'ubicacion': locationController.text
                      });
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
      query = FirebaseDatabase.instance
          .ref()
          .child('$user/$categoria')
          .orderByChild('place')
          .equalTo(place);

      key = Key(DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  Widget categoriesRow() {
    return Container(
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
          //Navigator.pushNamed(context, '/listaWardrobe', arguments: query);
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
            TextSpan(text: "$categoria en ", children: [
              TextSpan(
                text: context.read<LocationProvider>().currentLocation,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    dialogLocations();
                  },
              )
            ]),
          ),
          // Text(
          //     "${context.read<CategoryProvider>().currentCategory} en ${context.read<LocationProvider>().currentLocation}"),
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
              return ClothesWidget(clothes: prenda);
            },
          )),
        ],
      ),
    );
  }
}
