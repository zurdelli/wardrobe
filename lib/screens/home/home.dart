import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes_dao.dart';
import 'package:wardrobe/data/clothes_model.dart';
import 'package:wardrobe/data/mensaje_dao.dart';
import 'package:wardrobe/data/message_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/home/widgets/myWardrobe_widget.dart';
import 'package:wardrobe/screens/login.dart';
import 'package:wardrobe/screens/register.dart';
import 'package:wardrobe/utilities.dart';
import 'package:wardrobe/screens/home/widgets/categories_widget.dart';
import 'package:wardrobe/screens/home/widgets/clothes_widget.dart';
import 'package:wardrobe/screens/home/widgets/mensajewidget.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<LocationProvider>(context, listen: false).currentLocation =
          await getLocation();
      context.read<CategoryProvider>().currentCategory = "Camisetas";
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
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.exit_to_app),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/formclothes",
                  arguments: Clothes(
                      category: '',
                      subcategory: '',
                      brand: '',
                      image: '',
                      color: '',
                      date: DateTime.now().toString().substring(0, 10),
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
            const MyWardrobeWidget(),
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   Flexible(
            //       child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 12.0),
            //           child: TextField(
            //               keyboardType: TextInputType.text,
            //               controller: _mensajeController,
            //               onChanged: (text) => setState(() {}),
            //               onSubmitted: (input) {
            //                 //_enviarMensaje();
            //               },
            //               decoration: const InputDecoration(
            //                   hintText: 'Escribe un mensaje')))),
            // ]),
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
              child:
                  Text("Hola, ${context.read<UserProvider>().currentUser}!")),
          Text.rich(
            TextSpan(text: "Ubicación: ", children: [
              TextSpan(
                text: context.read<LocationProvider>().currentLocation,
                recognizer: TapGestureRecognizer()..onTap = () {},
              )
            ]),
          )
        ],
      ),
    );
  }
}
