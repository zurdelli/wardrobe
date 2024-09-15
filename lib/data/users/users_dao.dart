import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'users_model.dart';

class UserDAO {
  /// Instancia de la base de datos
  //  final DatabaseReference _userRef =
  //      FirebaseDatabase.instance.ref().child('users');

  //DatabaseReference _singleuserRef(String id) =>
  //    FirebaseDatabase.instance.ref().child('users/$id');

  _singleuserRef2(String id2) => FirebaseFirestore.instance.collection("users");

  /// Add or update users
  // Future<void> guardarUser(User? user) async {
  //   // DatabaseReference myRef =
  //   //     key == "null" ? userRef.push() : userRef.child(key);
  //   var q = await _singleuserRef(user!.id)
  //       .child("email")
  //       .equalTo(user.email)
  //       .get();
  //   if (q.exists) {
  //     print(q.value);
  //   } else {
  //     _singleuserRef2(user.id).set(user.toJson());
  //   }
  //   //return myRef.key;
  // }

  /// Add or update users
  Future<void> guardarUser(User? user) async {
    // DatabaseReference myRef =
    //     key == "null" ? userRef.push() : userRef.child(key);
    var q = await _singleuserRef2(user!.id)
        .where("email", isEqualTo: user.email)
        .get();

    if (q.docs.isEmpty) {
      _singleuserRef2(user.id).add(user.toJson());
    } else {
      print("el usuario ya existe");
    }
  }

  /// Delete clothess
  deleteUser(String id) => _singleuserRef2(id).remove();
}
