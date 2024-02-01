import 'package:firebase_database/firebase_database.dart';
import 'clothes_detailed.dart';

/// clothes DATA ACCESS OBJECT. Aqui se hace el CRUD de la base de datos
class ClothesDAO {
  /// Instancia de la base de datos
  final DatabaseReference _clothesRef =
      FirebaseDatabase.instance.ref().child('clothes');

  DatabaseReference _singleClothesRef(String id) =>
      FirebaseDatabase.instance.ref().child('clothes/$id');

  /// Save clothes
  String? guardarclothes(Clothes clothes) {
    DatabaseReference myRef = _clothesRef.push();
    myRef.set(clothes.toJson());
    return myRef.key;
  }

  /// Read clothess
  Query getclothess() => _clothesRef;

  /// Delete clothess
  deleteclothes(String id) => _singleClothesRef(id).remove();

  /// Update clothes
}
