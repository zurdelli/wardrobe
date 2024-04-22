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

class ClothesWidget extends StatefulWidget {
  final Clothes clothes;
  final String? nodeKey;

  const ClothesWidget(
      {super.key, required this.clothes, required this.nodeKey});
  @override
  _ClothesWidgetState createState() => _ClothesWidgetState();
}

class _ClothesWidgetState extends State<ClothesWidget> {
  @override
  void initState() {
    super.initState();
    checkAndUpdateWarranty(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openDialogMoreInfo(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: widget.clothes.hasBeenLent
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.grey,
                              BlendMode.saturation,
                            ),
                            child: FadeInImage.assetNetwork(
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: "assets/images/clothes.jpg",
                              image: widget.clothes.image,
                            ))
                        : FadeInImage.assetNetwork(
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: "assets/images/clothes.jpg",
                            image: widget.clothes.image)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "${widget.clothes.date} - ${widget.clothes.store}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text.rich(
                          TextSpan(
                            text: "${widget.clothes.brand} ",
                            //style: const TextStyle(color: Colors.black),
                            children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: CircleAvatar(
                                      maxRadius: 5,
                                      backgroundColor:
                                          stringToColor(widget.clothes.color))),
                              TextSpan(text: " ${widget.clothes.size}"),
                            ],
                          ),
                        ),
                      ),
                      const Align(
                          alignment: Alignment.topLeft, child: Text("")),
                      Offstage(
                        offstage: widget.clothes.holder == widget.clothes.owner,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                                "Prestada actualmente a ${widget.clothes.holder}")),
                      ),
                      Offstage(
                        offstage: widget.clothes.warranty.isEmpty,
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                                "Con garantía hasta el ${widget.clothes.warranty}")),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 20,
            )
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
              Stack(alignment: Alignment.bottomLeft, children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Color.fromARGB(0, 255, 255, 255)],
                    ).createShader(Rect.fromLTRB(
                        0, rect.height / 2, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: FadeInImage.assetNetwork(
                      placeholder: 'assets/clothes.jpg',
                      image: widget.clothes.image),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.clothes.sublocation.isNotEmpty
                        ? "${widget.clothes.place} - ${widget.clothes.sublocation}"
                        : widget.clothes.place),
                    Text(widget.clothes.brand,
                        style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ]),
              Container(
                alignment: Alignment.bottomLeft,
                height: 20,
                child: Text.rich(
                  TextSpan(
                      text: "Comprado el ${widget.clothes.date}",
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                            text: widget.clothes.store.isNotEmpty
                                ? " en ${widget.clothes.store}"
                                : ""),
                        TextSpan(
                            text: widget.clothes.storePlace.isNotEmpty
                                ? " en ${widget.clothes.storePlace}"
                                : ""),
                      ]),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                height: 20,
                child: Text.rich(
                  TextSpan(
                      text: "Talla: ${widget.clothes.size}",
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                            text: widget.clothes.color.isNotEmpty
                                ? " Color: ${widget.clothes.color}"
                                : ""),
                      ]),
                ),
              ),
              Offstage(
                offstage: widget.clothes.warranty.isEmpty,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  height: 20,
                  child: Text.rich(
                    TextSpan(
                        text: widget.clothes.warranty.isNotEmpty
                            ? "Garantía: hasta ${widget.clothes.warranty}"
                            : "Sin garantía",
                        style: const TextStyle(fontSize: 16),
                        children: []),
                  ),
                ),
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
                    icon: const Icon(Icons.diversity_3),
                  ),
                  IconButton(
                    onPressed: () => copyClothes(context),
                    icon: const Icon(Icons.web_stories),
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }

  // copia una prenda a un mismo usuario en una misma categoria
  copyClothes(BuildContext context) {
    final userid = context.read<UserProvider>().currentUser;
    final category = context.read<CategoryProvider>().currentCategory;
    final clothesid = widget.nodeKey ?? "";
    DatabaseReference path =
        FirebaseDatabase.instance.ref().child('clothes/$userid/$category');

    ClothesDAO().copyRecord(path.child(clothesid), path);
    Navigator.of(context).pop();
  }

  modifyClothes(BuildContext context) {
    context.read<ClothesProvider>().brand = widget.clothes.brand;
    context.read<ClothesProvider>().color = stringToColor(widget.clothes.color);
    context.read<ClothesProvider>().date = widget.clothes.date;
    context.read<ClothesProvider>().hasBeenLent = widget.clothes.hasBeenLent;
    context.read<ClothesProvider>().holder = widget.clothes.holder;
    context.read<ClothesProvider>().image = widget.clothes.image;
    context.read<ClothesProvider>().owner = widget.clothes.owner;
    context.read<ClothesProvider>().place = widget.clothes.place;
    context.read<ClothesProvider>().size = widget.clothes.size;
    //context.read<ClothesProvider>().status =widget.clothes.status;
    context.read<ClothesProvider>().store = widget.clothes.store;
    context.read<ClothesProvider>().sublocation = widget.clothes.sublocation;
    context.read<ClothesProvider>().warranty = widget.clothes.warranty;
    context.read<ClothesProvider>().website = widget.clothes.website;

    Navigator.popAndPushNamed(context, "/formclothes",
            arguments: widget.nodeKey)
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
          shape: const LinearBorder(),
          actions: <Widget>[
            TextButton(
                child: const Text('Eliminar'),
                onPressed: () {
                  ClothesDAO().deleteClothes(
                      userid: context.read<UserProvider>().currentUser,
                      category:
                          context.read<CategoryProvider>().currentCategory,
                      clothesid: widget.nodeKey ?? "");
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
                    const Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          "Prestar",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                    const Divider(),
                    TextButton(
                        onPressed: () {
                          dialogToConfirmBorrowClothes(
                              context, "", "otra persona");
                        },

                        //helperPrestarClothes(context, "otra persona"),
                        child: const Text("Otra persona")),
                    const Divider(),
                    TextButton(
                      onPressed: () => clothesBack(context),
                      child: const Text("Me la ha devuelsto"),
                    )
                  ],
                )))));
  }

  // Cuando vuelve la prenda desde un amigo
  clothesBack(BuildContext context) {
    ClothesDAO().backFromFriend(
        borrowed: false,
        userid: context.read<UserProvider>().currentUser,
        clothesid: widget.nodeKey ?? "",
        category: context.read<CategoryProvider>().currentCategory,
        toWhomeEmail: widget.clothes.holder);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
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
          shape: const LinearBorder(),
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
                      clothesid: widget.nodeKey ?? "",
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

  checkAndUpdateWarranty(BuildContext context) {
    if (widget.clothes.warranty.isNotEmpty) {
      if (DateTime.now()
          .isAfter(DateTime.parse(toEnglishDate(widget.clothes.warranty)))) {
        String userid = context.read<UserProvider>().currentUser;
        String category = context.read<CategoryProvider>().currentCategory;
        DatabaseReference myRef = FirebaseDatabase.instance
            .ref()
            .child('clothes/$userid/$category/${widget.nodeKey}');
        ClothesDAO().updateWarranty(myRef, "");
      }
    }
  }
}
