import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Representa la pantalla para hacer login del user
/// LA PASSW ES @1234andy
class CreateUser extends StatefulWidget {
  CreateUser({Key? key}) : super(key: key);

  @override
  CreateUserState createState() => CreateUserState();
}

class CreateUserState extends State<CreateUser> {
  late String email, passw, name;
  String error = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text('wardrobe')),
        body: Stack(alignment: Alignment.center, children: [
      Container(
        alignment: Alignment.bottomLeft,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/jean2.jpg"),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Registrarse",
                  style: GoogleFonts.gluten(fontSize: 36, shadows: [
                    Shadow(
                        color: Colors.black, offset: Offset.fromDirection(1, 2))
                  ])),
              SizedBox(width: 0.0, height: 20),
              Offstage(
                  offstage: error.isEmpty,
                  child: Text(
                    error,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        backgroundColor: Colors.white),
                  )),
              SizedBox(width: 0.0, height: 20),
              formulario(),
            ],
          ),
        ),
      ),
    ]));
  }

  Widget formulario() => Form(
        key: _formKey,
        child: Column(children: [
          emailFormField(),
          const SizedBox(height: 10),
          passwFormField(),
          const SizedBox(height: 10),
          buttonCreateUser()
        ]),
      );

  Widget emailFormField() => TextFormField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            labelText: "Email",
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: new BorderRadius.circular(8))),
        keyboardType: TextInputType.emailAddress,
        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
        onSaved: (String? value) {
          email = value!;
        },
      );

  Widget passwFormField() => TextFormField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.password),
            filled: true,
            fillColor: Colors.white,
            labelText: "Password",
            border:
                OutlineInputBorder(borderRadius: new BorderRadius.circular(8))),
        obscureText: true,
        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
        onSaved: (String? value) {
          passw = value!;
        },
      );

  Widget buttonCreateUser() => FractionallySizedBox(
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
                UserCredential? credenciales = await createUser(email, passw);
                if (credenciales != null) {
                  if (credenciales.user != null) {
                    await credenciales.user!.sendEmailVerification();
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            child: Text(
              "Crear usuario",
              style: TextStyle(color: Colors.white),
            )),
      );

  Future<UserCredential?> createUser(String email, String passw) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: passw);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? "";
      });
    }
    //return null;
  }
}
