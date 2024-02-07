import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Representa la pantalla para hacer login del user
/// LA PASSW ES @1234andy
class CreateUser extends StatefulWidget {
  CreateUser({Key? key}) : super(key: key);

  @override
  CreateUserState createState() => CreateUserState();
}

class CreateUserState extends State<CreateUser> {
  late String email, passw;
  String error = "";
  final _formKey = GlobalKey<FormState>();

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
                "Create User",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
            Offstage(
                offstage: error.isEmpty,
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                )),
            Padding(padding: const EdgeInsets.all(16.0), child: formulario()),
          ],
        ));
  }

  Widget formulario() => Form(
        key: _formKey,
        child: Column(
            children: [emailFormField(), passwFormField(), buttonCreateUser()]),
      );

  Widget emailFormField() => TextFormField(
        decoration: InputDecoration(
            labelText: "Email",
            border:
                OutlineInputBorder(borderRadius: new BorderRadius.circular(8))),
        keyboardType: TextInputType.emailAddress,
        onSaved: (String? value) {
          email = value!;
        },
      );

  Widget passwFormField() => TextFormField(
        decoration: InputDecoration(
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
        widthFactor: 0.6,
        child: ElevatedButton(
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
            child: Text("Login")),
      );

  Future<UserCredential?> createUser(String email, String passw) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: passw);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          error = "Usuario no encontrado";
        });
      }
      if (e.code == 'weak-password') {
        setState(() {
          error = "Contraseña muy debil";
        });
      }
    }
    //return null;
  }
}
