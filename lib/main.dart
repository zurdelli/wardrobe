import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/category_provider.dart';
import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/add_modify_form/add_clothes_form.dart';
import 'package:wardrobe/screens/home/home.dart';
import 'package:wardrobe/screens/login.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'wardrobe',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClothesProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider())
      ],
      child: MaterialApp(
        title: 'wardrobe',
        theme: ThemeData(primarySwatch: Colors.amber),
        initialRoute:
            FirebaseAuth.instance.currentUser == null ? "/login" : "/",
        routes: {
          "/": (context) => MyWardrobe(),
          "/login": (context) => const LoginPage(),
          "/formclothes": (context) => const ClothesForm(),
        },
      ),
    );
  }
}
