import 'package:firebase_database/firebase_database.dart';
import 'clothes_model.dart';

/// clothes DATA ACCESS OBJECT. Aqui se hace el CRUD de la base de datos
class ClothesDAO {
  /// Instancia de la base de datos
  // final DatabaseReference _clothesRef =
  //     FirebaseDatabase.instance.ref().child('clothes');

  DatabaseReference _singleClothesRef(String userid, String category) =>
      FirebaseDatabase.instance.ref().child('clothes/$userid/$category');

  /// Add or update clothes
  String? guardarClothes(Clothes clothes, DatabaseReference clothesRef,
      String user, String category, String key) {
    DatabaseReference myRef =
        key == "null" ? clothesRef.push() : clothesRef.child(key);

    myRef.set(clothes.toJson());
    return myRef.key;
  }

  /// Si una prenda es prestada a un amigo
  lentToFromSomeFriend(
      {required String toWhomeID,
      required bool borrowed,
      required String userid,
      required String clothesid,
      required String category}) {
    // hasbeenLent: true
    FirebaseDatabase.instance
        .ref()
        .child('clothes/$userid/$category/$clothesid')
        .update({"hasBeenLent": borrowed});

    /// Si el usuario de destino es un usuario de la app, copia el nodo de esa prenda
    /// al otro usuario
    if (toWhomeID.isNotEmpty) {
      DatabaseReference fromPath = FirebaseDatabase.instance
          .ref()
          .child('clothes/$userid/$category/$clothesid');
      DatabaseReference toPath =
          FirebaseDatabase.instance.ref().child('clothes/$toWhomeID/$category');
      copyRecord(fromPath, toPath);
    }
  }

  /// Copia un valor de un nodo original a otro
  copyRecord(DatabaseReference fromPath, final DatabaseReference toPath) async {
    final event = await fromPath.once(DatabaseEventType.value);
    final data = event.snapshot.value ?? "";
    if (data.toString().isNotEmpty) {
      DatabaseReference myKey = toPath.push();
      myKey.set(data);
    }
  }

  /// Delete clothess
  deleteClothes(
          {required String category,
          required String userid,
          required String clothesid}) =>
      _singleClothesRef(userid, category).child(clothesid).remove();
}
