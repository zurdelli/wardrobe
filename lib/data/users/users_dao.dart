import 'package:firebase_database/firebase_database.dart';
import 'users_model.dart';

class UserDAO {
  /// Instancia de la base de datos
  //  final DatabaseReference _userRef =
  //      FirebaseDatabase.instance.ref().child('users');

  DatabaseReference _singleuserRef(String id) =>
      FirebaseDatabase.instance.ref().child('users/$id');

  /// Add or update clothes
  Future<void> guardarUser(User? user) async {
    // DatabaseReference myRef =
    //     key == "null" ? userRef.push() : userRef.child(key);
    var q =
        await _singleuserRef(user!.id).child("email").equalTo(user.email).get();
    if (q.exists) {
      print(q.value);
    } else {
      _singleuserRef(user.id).set(user.toJson());
    }
    //return myRef.key;
  }

  /// Delete clothess
  deleteUser(String id) => _singleuserRef(id).remove();
}
