import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/category_provider.dart';

/// Representa al widget mostrado en la home donde se visualiza cada categoria
class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget(
      {super.key, required this.nombre, required this.image});

  final String nombre;
  final String image;
  final bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Provider.of<CategoryProvider>(context, listen: false)
              .currentCategory = nombre;
          print(Provider.of<CategoryProvider>(context, listen: false)
              .currentCategory = nombre);
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
}
