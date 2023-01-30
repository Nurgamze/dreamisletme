

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

class ConstScreen extends StatelessWidget {
  final Widget child;
  const ConstScreen({Key? key,required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: MediaQuery.of(context).orientation == Orientation.landscape ?
        child :
        SafeArea(
          top: false,
          bottom: Device.get().isIphoneX ? false : true,
          child: child,
        ),
    );
  }
}
