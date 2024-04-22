import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/data/users/users_model.dart' as usermodel;
import 'package:wardrobe/data/users/users_dao.dart';
import 'package:wardrobe/provider/location_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';
import 'package:wardrobe/screens/home/home.dart';
import 'package:wardrobe/screens/register.dart';
import 'package:wardrobe/utilities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// Representa la pantalla para hacer login del user
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late String email, passw;
  String error = "";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailResetPasswordController =
      TextEditingController();
  // final TextEditingController _passwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(),
        body: Stack(alignment: Alignment.center, children: [
      Container(
        alignment: Alignment.bottomLeft,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/jean2.jpg"),
                fit: BoxFit.cover)),
        //height: 600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("WARDROBE",
                  style: GoogleFonts.gluten(fontSize: 48, shadows: [
                    Shadow(
                        color: Colors.black, offset: Offset.fromDirection(1, 2))
                  ])),
              formulario()
            ],
          ),
        ),
      ),
    ]));
  }

  Widget formulario() => Form(
        key: _formKey,
        child: Column(children: [
          Offstage(
              offstage: error.isEmpty,
              child: Text(
                error,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    backgroundColor: Colors.white),
              )),
          const SizedBox(height: 10),
          emailFormField(),
          const SizedBox(height: 10),
          passwFormField(),
          Offstage(
            offstage: error.isEmpty,
            child: TextButton(
                onPressed: () => forgotPasswordDialog(context),
                child: const Text("¿Has olvidado tu contraseña?",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        backgroundColor: Colors.white))),
          ),
          const SizedBox(height: 50),
          buttonLogin(),
          const SizedBox(height: 10),
          botonGoogle(),
          createUser(),
        ]),
      );

  Widget emailFormField() => TextFormField(
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email),
          filled: true,
          fillColor: Colors.white,
          label: Text("Email"),
          border: UnderlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
        onSaved: (String? value) {
          email = value!;
        },
      );

  Widget passwFormField() => TextFormField(
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.password),
          filled: true,
          fillColor: Colors.white,
          label: Text("Password"),
          border: UnderlineInputBorder(),
        ),
        obscureText: true,
        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
        onSaved: (String? value) {
          passw = value!;
        },
      );

  Widget buttonLogin() => FractionallySizedBox(
        widthFactor: 1,
        child: ElevatedButton(
            style: const ButtonStyle(
                minimumSize: MaterialStatePropertyAll(Size.fromHeight(60)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
                backgroundColor: MaterialStatePropertyAll(Colors.amber)),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                UserCredential? credenciales = await login(email, passw);
                if (credenciales != null) {
                  if (credenciales.user != null) {
                    if (credenciales.user!.emailVerified) {
                      logueaYGuardaUsuario(credenciales.user);
                    }
                  }
                } else {
                  setState(() {
                    error = "Usuario o contraseña incorrectos";
                  });
                }
              }
            },
            child: const Text(
              "Ingresar",
              style: TextStyle(color: Colors.white),
            )),
      );

  Widget createUser() => FractionallySizedBox(
      widthFactor: 1,
      child: OutlinedButton(
        style: const ButtonStyle(
          minimumSize: MaterialStatePropertyAll(Size.fromHeight(60)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
          side: MaterialStatePropertyAll(BorderSide(color: Colors.transparent)),
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateUser())),
        child: Text(
          "¿Nuevo? Registrarse",
          style: TextStyle(fontSize: 18, color: Colors.amber, shadows: [
            Shadow(color: Colors.black, offset: Offset.fromDirection(1, 2))
          ]),
        ),
      ));

  Widget orLine() => const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: Divider()),
          Text(" o "),
          Expanded(child: Divider())
        ],
      );

  Widget botonGoogle() => FractionallySizedBox(
        widthFactor: 1,
        child: SignInButton(Buttons.Google,
            padding: const EdgeInsets.all(10),
            text: "Entrar con Google",
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            onPressed: () async {
          await entrarConGoogle();
          if (FirebaseAuth.instance.currentUser != null) {
            logueaYGuardaUsuario(FirebaseAuth.instance.currentUser);
          }
        }),
      );

  logueaYGuardaUsuario(User? usuario) async {
    String displayName = context.read<UserProvider>().currentUserName =
        FirebaseAuth.instance.currentUser?.displayName ?? "";

    if (displayName.isEmpty) {
      TextEditingController nameController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          // ignore: prefer_const_constructors
          child: AlertDialog(
            title: Text("Dime tu nombre"),
            shape: LinearBorder(),
            content: TextField(controller: nameController),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop()),
              TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () async {
                    FirebaseAuth.instance.currentUser
                        ?.updateDisplayName(nameController.text);
                    // Se guarda el UID que es una clave que genera Firebase auth automáticamente
                    // Se usará luego para proteger sus datos en la base de datos
                    context.read<UserProvider>().currentUser =
                        FirebaseAuth.instance.currentUser?.uid ?? "";
                    context.read<UserProvider>().currentUserName =
                        FirebaseAuth.instance.currentUser?.displayName ?? "";
                    context.read<UserProvider>().currentEmail =
                        FirebaseAuth.instance.currentUser?.email ?? "";
                    UserDAO().guardarUser(
                        userFromFirestoreToUserFromUsersModel(usuario));
                    context.read<LocationProvider>().currentLocation =
                        await getLocation();
                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyWardrobe()),
                        (route) => false);
                  }),
            ],
          ),
        ),
      );
    } else {
      // Se guarda el UID que es una clave que genera Firebase auth automáticamente
      // Se usará luego para proteger sus datos en la base de datos
      context.read<UserProvider>().currentUser =
          FirebaseAuth.instance.currentUser?.uid ?? "";
      context.read<UserProvider>().currentUserName =
          FirebaseAuth.instance.currentUser?.displayName ?? "";
      context.read<UserProvider>().currentEmail =
          FirebaseAuth.instance.currentUser?.email ?? "";
      UserDAO().guardarUser(userFromFirestoreToUserFromUsersModel(usuario));
      context.read<LocationProvider>().currentLocation = await getLocation();
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyWardrobe()),
          (route) => false);
    }
  }

  Future<UserCredential?> login(String email, String passw) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: passw);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          error = "Usuario no encontrado";
        });
      }
      if (e.code == 'wrong-password') {
        setState(() {
          error = "Contraseña errónea";
        });
      }
    }
    //return null;
  }

  Future<UserCredential> entrarConGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? authentication =
        await googleUser?.authentication;
    final credentials = GoogleAuthProvider.credential(
        accessToken: authentication?.accessToken,
        idToken: authentication?.idToken);

    return await FirebaseAuth.instance.signInWithCredential(credentials);
  }

  userFromFirestoreToUserFromUsersModel(User? firestoreUser) {
    return usermodel.User(
        name: firestoreUser!.displayName ?? "",
        email: firestoreUser.email ?? "",
        id: firestoreUser.uid,
        image: "");
  }

  forgotPasswordDialog(BuildContext context) {
    String alertError = "";
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(builder:
          (BuildContext context, void Function(void Function()) setState) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            content: SingleChildScrollView(
                child: SizedBox(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Restaurar contraseña",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text("Introduce tu correo electrónico:"),
                  Offstage(
                    offstage: alertError.isEmpty,
                    child: Text(
                      alertError,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextFormField(
                    controller: emailResetPasswordController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                      label: Text("Email"),
                      border: UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                        style: const ButtonStyle(
                            minimumSize:
                                MaterialStatePropertyAll(Size.fromHeight(60)),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.amber)),
                        onPressed: () async {
                          if (emailResetPasswordController.text.contains('@')) {
                            try {
                              FirebaseAuth.instance.sendPasswordResetEmail(
                                  email: emailResetPasswordController.text);

                              Navigator.of(context).pop();
                              mySnackBar(context,
                                  "Se ha enviado un correo de recuperación");
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'auth/invalid-email') {
                                setState(() {
                                  alertError = "email invalido";
                                });
                              }
                              if (e.code == 'auth/user-not-found') {
                                setState(() {
                                  alertError = "usuario no encontrado";
                                });
                              }
                            }
                          } else {
                            setState(() {
                              alertError = "Debes introducir un correo válido";
                            });
                          }
                        },
                        child: const Text(
                          "Enviar correo",
                          style: TextStyle(color: Colors.white),
                        )),
                  )
                ],
              ),
            )),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    emailResetPasswordController.dispose();
    super.dispose();
  }
}
