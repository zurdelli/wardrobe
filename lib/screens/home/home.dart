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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).currentLocation =
          "Nava";
      Provider.of<CategoryProvider>(context, listen: false).currentCategory =
          "Camisetas";
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
            return CategoriesWidget(
              nombre: categoriesListTipos[index],
              image: categoriesListImages[index],
            );
          }),
    );
  }

  // Widget _getMyWardrobe() {
  //   return Expanded(
  //       child: FirebaseAnimatedList(
  //     controller: _scrollController,
  //     query: widget.mensajeDAO.getMensajes(),
  //     itemBuilder: (context, snapshot, animation, index) {
  //       final json = snapshot.value as Map<dynamic, dynamic>;
  //       final mensaje = Mensaje.fromJson(json);
  //       return MensajeWidget(mensaje.texto, mensaje.fecha, snapshot.key);
  //     },
  //   ));
  // }

  Widget _getMyWardrobe() {
    return Expanded(
      child: Column(
        children: [
          Text(
              "${context.watch<CategoryProvider>().currentCategory} en ${context.watch<LocationProvider>().currentLocation}"),
          SizedBox(
            height: 15,
          ),
          Expanded(
              child: FirebaseAnimatedList(
            controller: _scrollController,
            query: FirebaseDatabase.instance.ref().child(
                '${context.read<UserProvider>().currentUser}/${context.watch<CategoryProvider>().currentCategory}'),
            itemBuilder: (context, snapshot, animation, index) {
              final json = snapshot.value as Map<dynamic, dynamic>;
              final prenda = Clothes.fromJson(json);
              return ClothesWidget(prenda.brand, prenda.date, snapshot.key);
            },
          )),
        ],
      ),
    );
  }
}
