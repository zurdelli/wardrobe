import 'dart:ui';

import 'package:flutter/material.dart';

class ModalBottomSheet extends StatefulWidget {
  _ModalBottomSheetState createState() => _ModalBottomSheetState();

  Widget child;
  String title;
  ModalBottomSheet({super.key, required this.child, required this.title});
}

class _ModalBottomSheetState extends State<ModalBottomSheet>
    with SingleTickerProviderStateMixin {
  double height = 0.0;
  double width = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    height = 300.0;
    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
    // Dimensions in physical pixels (px)
    Size size = view.physicalSize;
    width = size.width;
    //double height = size.height;
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        children: [
          Text(widget.title),
          widget.child,
        ],
      ),
    );
  }
}
