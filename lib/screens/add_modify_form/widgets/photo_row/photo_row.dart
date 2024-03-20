import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
  String imageBase64 = "";
  String myBucket = FirebaseStorage.instance.bucket;

  @override
  void initState() {
    super.initState();
    imageBase64 = context.read<ClothesProvider>().image;
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
                child: imageBase64.isEmpty
                    ? const Text(
                        'No image selected',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: FadeInImage.assetNetwork(
                            //fit: BoxFit.cover,
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
          toolbarWidgetColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.white
                  : Colors.black),
      IOSUiSettings(title: 'Crop')
    ]);

    if (cropped != null) {
      setState(() {
        imageFile = File(cropped.path);
        uploadToStorage(imageFile);
        Navigator.of(context).pop();
      });
    }
  }

  uploadToStorage(File file) async {
    final storageRef = FirebaseStorage.instance.ref();
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final uniqueUploadID = DateTime.now().millisecondsSinceEpoch.toString();
    final path =
        "clothes/${context.read<UserProvider>().currentUser}/${context.read<CategoryProvider>().currentCategory}/$uniqueUploadID.jpg";
    final uploadTask = storageRef.child(path).putFile(file, metadata);

    // Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          context.read<ClothesProvider>().image =
              await storageRef.child(path).getDownloadURL();
          setState(() {
            imageBase64 = context.read<ClothesProvider>().image;
          });

          break;
      }
    });
  }
}
