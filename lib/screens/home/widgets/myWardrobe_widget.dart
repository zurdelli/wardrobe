//import 'dart:html';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/home/home.dart';
import 'package:wardrobe/screens/home/widgets/clothes_widget.dart';
import 'package:wardrobe/utilities.dart';

class MyWardrobeWidget extends StatefulWidget {
  const MyWardrobeWidget({super.key});

  // final String nombre;
  // final String image;
  final bool isSelected = false;

  @override
  State<StatefulWidget> createState() => MyWardrobeWidgetState();
}

class MyWardrobeWidgetState extends State<MyWardrobeWidget> {
  final ScrollController _scrollController = ScrollController();

  String categoria = "";
  String user = "";
  String place = "";
  var dbRef;
  var query;

  @override
  void initState() {
    super.initState();
    categoria = context.read<CategoryProvider>().currentCategory;
    user = context.read<UserProvider>().currentUser;
    place = context.read<LocationProvider>().currentLocation;
    // dbRef = FirebaseDatabase.instance.ref().child('$user/$categoria');
    // query = FirebaseDatabase.instance
    //     .ref()
    //     .child('$user/$categoria')
    //     .orderByChild('place')
    //     .equalTo(place);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
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
          ),
          Text.rich(
            TextSpan(text: '$categoria en ', children: [
              TextSpan(
                text: context.read<LocationProvider>().currentLocation,
                recognizer: TapGestureRecognizer()..onTap = () {},
              )
            ]),
          ),
          const SizedBox(height: 15),
          getMyWardobeList(categoria),
        ],
      ),
    );
  }

  Widget getMyWardobeList(String categoria) {
    return Expanded(
        child: FirebaseAnimatedList(
      controller: _scrollController,
      query: FirebaseDatabase.instance
          .ref()
          .child(user)
          .orderByChild('place')
          .equalTo(place),
      itemBuilder: (context, snapshot, animation, index) {
        print(index);
        final json = snapshot.value as Map<dynamic, dynamic>;
        final prenda = Clothes.fromJson(json);
        if (prenda.category == categoria) {
          return ClothesWidget(prenda.brand, prenda.date, snapshot.key);
        } else {
          return Text("");
        }
        //return ClothesWidget(prenda.brand, prenda.date, snapshot.key);
      },
    ));
  }

  Widget getMyWardobeList2(String categoria) {
    dbRef = FirebaseDatabase.instance
        .ref()
        .child('$user/$categoria')
        .orderByChild('place')
        .equalTo(place);

    // Get the Stream
    Stream<DatabaseEvent> stream = dbRef.onValue;

    // Subscribe to the stream!
    stream.listen((DatabaseEvent event) {
      print('Event Type: ${event.type}'); // DatabaseEventType.value;
      print('Snapshot: ${event.snapshot}'); // Dat
    });

    return getMyWardobeList(dbRef);
  }

  Widget categoriesWidget({required String nombre, required String image}) {
    return GestureDetector(
        onTap: () {
          setState(() {
            categoria = nombre;
            context.read<CategoryProvider>().currentCategory = nombre;
            query = FirebaseDatabase.instance
                .ref()
                .child('$user/$categoria')
                .orderByChild('place')
                .equalTo(place);
          });
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
}
