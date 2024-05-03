import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe/provider/category_provider.dart';

import 'package:wardrobe/provider/clothes_provider.dart';
import 'package:wardrobe/provider/user_provider.dart';

import 'widgets/select_photo_options_screen.dart';

import 'package:firebase_storage/firebase_storage.dart';

class PhotoRow extends StatefulWidget {
  const PhotoRow({super.key});

  @override
  State<StatefulWidget> createState() => _PhotoRowState();
}

class _PhotoRowState extends State<PhotoRow> {
  String imageCache = "";
  String imageFromProvider = "";

  @override
  void initState() {
    super.initState();
    imageFromProvider = context.read<ClothesProvider>().image;
    if (imageFromProvider.isNotEmpty) {
      imageCache = imageFromProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _showSelectPhotoOptions(context),
        child: Center(
          child: Container(
            height: 160.0,
            width: 160.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Center(
                child: imageCache.isEmpty
                    ? const Text(
                        'Sin imagen',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: imageFromProvider.isEmpty
                            ? Image.file(File(imageCache))
                            : FadeInImage.assetNetwork(
                                fit: BoxFit.scaleDown,
                                placeholder: "assets/images/clothes.jpg",
                                image: context.read<ClothesProvider>().image),
                      )),
          ),
        ),
      ),
    );
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  /// image picker
  Future _pickImage(ImageSource source) async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: source, imageQuality: 100);
      if (image == null) return;

      File? img = File(image.path);
      img = await _cropImage(img); // la llevo al cropper
    } on PlatformException catch (e) {
      Navigator.pop(context);
    }
  }

  /// image cropper
  Future _cropImage(File imageFile) async {
    CroppedFile? cropped = await ImageCropper()
        .cropImage(sourcePath: imageFile.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop',
        cropGridColor: Colors.black,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
      ),
      // toolbarWidgetColor:
      //     MediaQuery.of(context).platformBrightness == Brightness.light
      //         ? Colors.white
      //         : Colors.black),
      IOSUiSettings(title: 'Crop')
    ]);

    if (cropped != null) {
      //uploadToStorage(cropped.path);
      imageCache = context.read<ClothesProvider>().imageCache = cropped.path;
      setState(() {});
      Navigator.of(context).pop();
    }
  }
}

Future<String> uploadToStorage(String croppedpath, BuildContext context) async {
  String imageURL = "";
  final storageRef = FirebaseStorage.instance.ref();
  final metadata = SettableMetadata(contentType: "image/jpeg");
  final uniqueUploadID = DateTime.now().millisecondsSinceEpoch.toString();
  final databasePath =
      "clothes/${context.read<UserProvider>().currentUser}/${context.read<CategoryProvider>().currentCategory}/";

  Directory tempDir = await getApplicationDocumentsDirectory();

  final imageFile = File(croppedpath);
  final thumb2 = img.decodeImage(File(croppedpath).readAsBytesSync());
  final thumbnail = img.copyResize(thumb2!, width: 120);
  await img.encodeJpgFile("${tempDir.path}.thumb.jpg", thumbnail);

  var uploadTask = await storageRef
      .child("$databasePath/$uniqueUploadID.jpg")
      .putFile(imageFile, metadata);

  imageURL = await storageRef
      .child("$databasePath/$uniqueUploadID.jpg")
      .getDownloadURL();

  uploadTask = await storageRef
      .child("$databasePath/$uniqueUploadID.thumb.jpg")
      .putFile(File("${tempDir.path}.thumb.jpg"), metadata);

  String thumbURL = await storageRef
      .child("$databasePath/$uniqueUploadID.thumb.jpg")
      .getDownloadURL();

  return "$imageURL#$thumbURL";
}
