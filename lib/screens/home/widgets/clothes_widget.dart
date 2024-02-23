import 'dart:convert';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/clothes/clothes_dao.dart';
import 'package:wardrobe/data/clothes/clothes_model.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/utilities.dart';

/// Representa al widget mostrado en la home donde se visualiza cada clothes por
/// separado
class ClothesWidget extends StatelessWidget {
  final Clothes clothes;
  final String? nodeKey;

  const ClothesWidget(
      {super.key, required this.clothes, required this.nodeKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.grey[350]!,
            blurRadius: 2.0,
            offset: const Offset(0, 1.0))
      ], borderRadius: BorderRadius.circular(5.0), color: Colors.white),
      child: MaterialButton(
        disabledTextColor: Colors.black87,
        padding: const EdgeInsets.all(10),
        onPressed: () {
          //todo abrir un dialog con más información
          openDialogMoreInfo(context);
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: MemoryImage(base64Decode(clothes.image)),
                  radius: 30.0,
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          clothes.date,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text.rich(
                          TextSpan(
                            text: "${clothes.brand} ",
                            style: const TextStyle(color: Colors.black),
                            children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: CircleAvatar(
                                      maxRadius: 5,
                                      backgroundColor:
                                          stringToColor(clothes.color))),
                            ],
                          ),
                        ),
                      ),
                      Align(alignment: Alignment.topLeft, child: Text("")),
                      Offstage(
                        offstage: clothes.warranty.isEmpty,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                                "Con garantía hasta el ${clothes.warranty}")),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  openDialogMoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
              child: Column(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
                child:
                    // FadeInImage.assetNetwork(
                    //     placeholder: 'assets/clothes.jpg', image: clothes.image)

                    Image.memory(
                  base64Decode(clothes.image),
                  //radius: 250,
                ),
              ),
              Row(
                children: [
                  Text.rich(TextSpan(text: "${clothes.brand} ", children: [
                    TextSpan(text: clothes.date),
                  ]))
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () => modifyClothes(context),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => deleteClothes(context),
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () => modalToBorrowClothes(context),
                    icon: const Icon(Icons.swap_horizontal_circle_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.abc),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }

  modifyClothes(BuildContext context) {
    context.read<ClothesProvider>().brand = clothes.brand;
    context.read<ClothesProvider>().color = stringToColor(clothes.color);
    context.read<ClothesProvider>().date = clothes.date;
    context.read<ClothesProvider>().hasBeenLent = clothes.hasBeenLent;
    context.read<ClothesProvider>().holder = clothes.holder;
    context.read<ClothesProvider>().image = clothes.image;
    context.read<ClothesProvider>().owner = clothes.owner;
    context.read<ClothesProvider>().place = clothes.place;
    context.read<ClothesProvider>().size = clothes.size;
    //context.read<ClothesProvider>().status = clothes.status;
    context.read<ClothesProvider>().store = clothes.store;
    context.read<ClothesProvider>().sublocation = clothes.sublocation;
    context.read<ClothesProvider>().warranty = clothes.warranty;

    Navigator.popAndPushNamed(context, "/formclothes", arguments: nodeKey)
        .then((_) {});
  }

  deleteClothes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        // ignore: prefer_const_constructors
        child: AlertDialog(
          title: const Text("¿Eliminar?"),
          shape: LinearBorder(),
          actions: <Widget>[
            TextButton(
                child: const Text('Eliminar'),
                onPressed: () {
                  ClothesDAO().deleteClothes(
                      userid: context.read<UserProvider>().currentUser,
                      category:
                          context.read<CategoryProvider>().currentCategory,
                      clothesid: nodeKey ?? "");
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  modalToBorrowClothes(BuildContext context) {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        //isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 1,
            minChildSize: 0.28,
            expand: false,
            builder: ((context, scrollController) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("A un usuario de la app"),
                    FirebaseAnimatedList(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      query: FirebaseDatabase.instance.ref().child('users'),
                      itemBuilder: (context, snapshot, animation, index) {
                        final json = snapshot.value as Map<dynamic, dynamic>;
                        final email = json['email'] as String;
                        final userID = json['id'] as String;
                        // Verifica si el id del nodo al que está accediendo en la
                        //base de datos es el mismo que está en la aplicacion actualmente
                        //entonces no lo muestra ya que no se puede prestar la ropa a uno
                        //mismo. Tambien recupera el email que será la forma de mostrar el
                        //usuario a quien se prestará la ropa
                        return userID !=
                                context.read<UserProvider>().currentUser
                            ? TextButton(
                                onPressed: () {
                                  dialogToConfirmBorrowClothes(
                                      context, userID, email);
                                },
                                child: Text(email))
                            : Container(
                                height: 0,
                              );
                      },
                    ),
                    Divider(),
                    TextButton(
                        onPressed: () {
                          dialogToConfirmBorrowClothes(
                              context, "", "otra persona");
                        },
                        //helperPrestarClothes(context, "otra persona"),
                        child: const Text("Otra persona"))
                  ],
                )))));
  }

  dialogToConfirmBorrowClothes(
      BuildContext context, String userID, String userEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        // ignore: prefer_const_constructors
        child: AlertDialog(
          title: const Text("Prestar"),
          shape: LinearBorder(),
          content: Text("¿Está seguro de querer prestar esto a $userEmail"),
          actions: <Widget>[
            TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  ClothesDAO().lentToFromSomeFriend(
                      borrowed: true,
                      category:
                          context.read<CategoryProvider>().currentCategory,
                      clothesid: nodeKey ?? "",
                      toWhomeID: userID,
                      userid: context.read<UserProvider>().currentUser,
                      toWhomeEmail: userEmail);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
    );
  }
}
