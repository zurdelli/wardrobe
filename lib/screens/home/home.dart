import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/colors_row/colors.dart';
import 'package:wardrobe/screens/add_modify_form/widgets/size_row/size_row.dart';
import 'package:wardrobe/screens/home/widgets/filters_widgets.dart';
import 'package:wardrobe/screens/login.dart';
import 'package:wardrobe/utilities.dart';
import 'package:wardrobe/screens/home/widgets/clothes_widget.dart';
import 'package:wardrobe/utils/modal_bottom_sheet.dart';

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
  final filtersBrandController = TextEditingController();
  int cantidad = 0;

  String categoria = "",
      user = "",
      userName = "",
      currentPlace = "",
      selectedPlace = "";
  bool showFilters = false;
  String? filterSize = "";
  var query;
  var dbReference;
  var key;

  @override
  void initState() {
    super.initState();
    cantidad = 0;
    key = Key(DateTime.now().millisecondsSinceEpoch.toString());
    categoria = "Camisetas";
    user = FirebaseAuth.instance.currentUser?.uid ?? "";
    userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
    dbReference =
        FirebaseDatabase.instance.ref().child('clothes/$user/$categoria');
    query = dbReference.orderByChild('place').equalTo(currentPlace);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentPlace = await getLocation();
      setState(() {
        selectedPlace = currentPlace;
        context.read<UserProvider>().currentUser = user;
        context.read<LocationProvider>().currentLocation = currentPlace;
        context.read<CategoryProvider>().currentCategory = categoria;
        updateQuery(categoriaLocal: categoria, placeLocal: currentPlace);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('WARDROBE', style: GoogleFonts.gluten()),
          actions: [
            Builder(
              builder: (context) => InkWell(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.person),
                ),
              ),
            )
          ]),
      endDrawer: NavigationDrawer(
        children: [profileDrawer(context)],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.read<ClothesProvider>().brand = "";
          context.read<ClothesProvider>().color = stringToColor("Transparent");
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
      body: Column(
        children: [
          //userAndLocationRow(),
          categoriesRow(),
          _getMyWardrobe(),
        ],
      ),
    );
  }

  Widget userAndLocationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("¡Hola, $userName!", textScaleFactor: 1.3),
            ],
          ),
          Text("Ubicación actual: $currentPlace"),
        ],
      ),
    );
  }

  Widget categoriesRow() {
    return SizedBox(
      height: 110,
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

  ///Widget que representa cada círculo que corresponde a una categoría
  Widget categoriesWidget({required String nombre, required String image}) {
    return GestureDetector(
        onTap: () {
          updateQuery(categoriaLocal: nombre, placeLocal: selectedPlace);
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    context.read<CategoryProvider>().currentCategory == nombre
                        ? const Border.fromBorderSide(
                            BorderSide(color: Colors.amber))
                        : const Border.fromBorderSide(
                            BorderSide(color: Colors.transparent)),
                color: Colors.transparent,
              ),
              child: AnimatedContainer(
                margin: const EdgeInsets.all(3),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCirc,
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                alignment: Alignment.center,
                height: 60.0,
                width: 60.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber,
                ),
                child: Image.asset(image),
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              width: 60,
              child: Text(
                textScaleFactor: 0.8,
                nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => myModal(context, gimmeLocations()),
                    child: Text.rich(
                      textScaleFactor: 1.1,
                      TextSpan(
                          text: selectedPlace.isNotEmpty
                              ? "$cantidad $categoria en $selectedPlace"
                              : "$cantidad $categoria en total",
                          children: const [
                            WidgetSpan(
                                child: Icon(Icons.arrow_drop_down_outlined))
                          ]),
                    ),
                  ),
                ),
              ),
              // IconButton(
              //     onPressed: () {
              //       setState(() {
              //         showFilters = !showFilters;
              //       });
              //     },
              //     icon: const Icon(Icons.filter_list))
            ],
          ),
          //const SizedBox(height: 15),
          Offstage(
            offstage: !showFilters,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => myModal(context, gimmeFilters()),
              child: const Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                            text: "FILTROS",
                            style: TextStyle(fontSize: 16),
                            children: [
                              WidgetSpan(
                                  child: Icon(Icons.arrow_drop_down_outlined))
                            ]),
                      ),
                    ],
                  ),
                  SizedBox(width: 0.0, height: 10)
                ],
              ),
            ),
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

  Widget gimmeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("Filtrar", style: TextStyle(fontSize: 20)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Color", style: TextStyle(fontSize: 18)),
            ColorsRow(),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Talla", style: TextStyle(fontSize: 18)),
            FiltersSizeWidget(),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Marca", style: TextStyle(fontSize: 18)),
            SizedBox(
              width: 100,
              child: TextField(
                controller: filtersBrandController,
              ),
            ),
          ],
        ),
        ElevatedButton(onPressed: () {}, child: Text("Aceptar"))
      ],
    );
  }

  Widget gimmeLocations() {
    Offset _tapPosition = Offset.zero;
    void _getTapPosition(TapDownDetails tapPosition) {
      final RenderBox referenceBox = context.findRenderObject() as RenderBox;
      setState(() => _tapPosition =
          referenceBox.globalToLocal(tapPosition.globalPosition));
    }

    void _showContextMenu(
        BuildContext context, String location, String key) async {
      final RenderObject? overlay =
          Overlay.of(context).context.findRenderObject();

      final result = await showMenu(
          context: context,
          position: RelativeRect.fromRect(
              Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 100, 100),
              Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                  overlay.paintBounds.size.height)),
          items: [
            const PopupMenuItem(
              value: "editar",
              child: Text('Editar'),
            ),
            const PopupMenuItem(
              value: "borrar",
              child: Text('Borrar'),
            )
          ]);
      // perform action on selected menu item
      switch (result) {
        case 'editar':
          locationCRUD(location, key);
          break;
        case 'borrar':
          setState(() {
            FirebaseDatabase.instance
                .ref()
                .child('clothes/$user/Ubicaciones/$key')
                .remove();
          });

          break;
      }
    }

    return Column(
      children: [
        TextButton(
            onPressed: () => updateQuery(
                categoriaLocal:
                    context.read<CategoryProvider>().currentCategory,
                placeLocal: ""),
            child: Text(
              "Todas las ubicaciones",
              style: TextStyle(fontSize: 18, color: Colors.amber[700]),
            )),
        Container(
          height: 220,
          child: FirebaseAnimatedList(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            query: FirebaseDatabase.instance
                .ref()
                .child('clothes/$user/Ubicaciones'),
            itemBuilder: (context, snapshot, animation, index) {
              final json = snapshot.value as Map<dynamic, dynamic>;
              final ubicacion = json['ubicacion'] as String;
              final key = snapshot.key;
              return GestureDetector(
                onTapDown: (position) => {_getTapPosition(position)},
                onTap: () {
                  updateQuery(
                      categoriaLocal:
                          context.read<CategoryProvider>().currentCategory,
                      placeLocal: ubicacion);
                  Navigator.of(context).pop();
                },
                onLongPress: () => {_showContextMenu(context, ubicacion, key!)},
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    ubicacion,
                    style: TextStyle(fontSize: 18, color: Colors.amber[700]),
                  ),
                )),
              );
            },
          ),
        ),
        const Divider(),
        TextButton(
            onPressed: () => locationCRUD("", ""),
            child: const Text(
              "Añadir",
              textScaleFactor: 1.1,
            ))
      ],
    );
  }

  locationCRUD(String location, String key) {
    TextEditingController locationController = TextEditingController();
    locationController.text = location;
    showDialog(
        context: context,
        builder: (BuildContext context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              // ignore: prefer_const_constructors
              child: AlertDialog(
                title: const Text("Añadir ubicación favorita"),
                shape: const LinearBorder(),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () async => locationController.text =
                                    await getLocation(),
                                icon: const Icon(Icons.gps_fixed)),
                            border: const OutlineInputBorder(),
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
                        // Crea una nueva ubicacion
                        myRef = FirebaseDatabase.instance
                            .ref()
                            .child('clothes/$user/Ubicaciones')
                            .push();
                      } else {
                        // edita una ubicacion
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
                      locationController.dispose();
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
      selectedPlace = placeLocal;
      dbReference =
          FirebaseDatabase.instance.ref().child('clothes/$user/$categoria');
      query = selectedPlace.isNotEmpty
          ? dbReference.orderByChild('place').equalTo(selectedPlace)
          : dbReference;
      //if (FirebaseAuth.instance.currentUser != null) {
      countChildren(dbReference);
      //}
      key = Key(DateTime.now().millisecondsSinceEpoch.toString());
    });
  }

  /// Cuenta el numero de hijos de un nodo, para contar la cantidad de ropa
  countChildren(DatabaseReference fromPath) async {
    final event = selectedPlace.isNotEmpty
        ? await fromPath
            .orderByChild('place')
            .equalTo(selectedPlace)
            .once(DatabaseEventType.value)
        : await fromPath.once(DatabaseEventType.value);
    int length = event.snapshot.children.length;
    setState(() => cantidad = length);
  }

// El drawer que se visualiza al pulsar el icon del perfil, o al deslizar desde el lat der
  Widget profileDrawer(BuildContext context) {
    return Column(
      children: [
        SizedBox(width: 0.0, height: 50),
        SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(FirebaseAuth
                          .instance.currentUser!.photoURL ??
                      "https://firebasestorage.googleapis.com/v0/b/wardrobe-f8e31.appspot.com/o/clothes%2Fprofile.jpg?alt=media&token=df19f92a-3819-4823-82b0-778fcac56f54")),
              Text(FirebaseAuth.instance.currentUser!.displayName ?? "",
                  style: GoogleFonts.gluten(fontSize: 20)),
              //Text(FirebaseAuth.instance.currentUser!. ?? ""),
              Text(FirebaseAuth.instance.currentUser!.email ?? ""),
              ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false);
                  },
                  child: const Text("Cerrar sesión"))
            ],
          ),
        ),
      ],
    );
  }
}
