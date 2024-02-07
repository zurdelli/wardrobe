import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:wardrobe/provider/clothes_provider.dart';

import 'select_photo_options_screen.dart';

class PhotoRow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PhotoRowState();
}

class _PhotoRowState extends State<PhotoRow> {
  String tapaAsStringBase64 = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tapaAsStringBase64 =
          Provider.of<ClothesProvider>(context, listen: false).photoAsString;
    });
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
              child: tapaAsStringBase64.isEmpty
                  ? const Text(
                      'No image selected',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    )
                  : CircleAvatar(
                      backgroundImage:
                          MemoryImage(base64Decode(tapaAsStringBase64)),
                      radius: 200.0,
                    ),
            ),
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
      print("exception: $e");
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
                  ? Colors.black
                  : Colors.white),
      IOSUiSettings(title: 'Crop')
    ]);

    if (cropped != null) {
      setState(() {
        imageFile = File(cropped.path);

        tapaAsStringBase64 = base64Encode(imageFile.readAsBytesSync());
        Provider.of<ClothesProvider>(context, listen: false).photoAsString =
            tapaAsStringBase64;
        //print("tapaAsStringBase64: $tapaAsStringBase64");
        Navigator.of(context).pop();
      });
    }
  }
}
