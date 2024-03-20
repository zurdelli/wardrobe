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

  // final TextEditingController _userController = TextEditingController();
  // final TextEditingController _passwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('wardrobe')),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "wardrobe",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            Offstage(
                offstage: error.isEmpty,
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                )),
            Padding(padding: const EdgeInsets.all(16.0), child: formulario()),
          ],
        ));
  }

  Widget formulario() => Form(
        key: _formKey,
        child: Column(children: [
          emailFormField(),
          const SizedBox(height: 10),
          passwFormField(),
          const SizedBox(height: 10),
          buttonLogin(),
          buttonCreateUser(),
          orLine(),
          botonesGoogleApple()
        ]),
      );

  Widget emailFormField() => TextFormField(
        decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        keyboardType: TextInputType.emailAddress,
        onSaved: (String? value) {
          email = value!;
        },
      );

  Widget passwFormField() => TextFormField(
        decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        obscureText: true,
        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
        onSaved: (String? value) {
          passw = value!;
        },
      );

  Widget buttonLogin() => FractionallySizedBox(
        widthFactor: 1,
        child: ElevatedButton(
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
                    error = "Debes verificar tu correo antes de acceder";
                  });
                }
              }
            },
            child: const Text("Login")),
      );

  Widget buttonCreateUser() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => CreateUser())),
            child: const Text("Registrarse"),
          )
        ],
      );

  Widget orLine() => const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: Divider()),
          Text(" o "),
          Expanded(child: Divider())
        ],
      );

  Widget botonesGoogleApple() => Column(
        children: [
          SignInButton(Buttons.Google, onPressed: () async {
            await entrarConGoogle();
            if (FirebaseAuth.instance.currentUser != null) {
              logueaYGuardaUsuario(FirebaseAuth.instance.currentUser);
            }
          }),
        ],
      );

  logueaYGuardaUsuario(User? usuario) async {
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
        MaterialPageRoute(builder: (context) => MyWardrobe()),
        (route) => false);
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
        email: firestoreUser!.email ?? "",
        id: firestoreUser.uid,
        image: "");
  }
}
