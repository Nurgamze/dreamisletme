import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class HorizontalPage extends StatefulWidget {
  final Widget showWidget;
  const HorizontalPage(this.showWidget,{Key? key}) : super(key: key);

  @override
  _HorizontalPageState createState() => _HorizontalPageState();
}

class _HorizontalPageState extends State<HorizontalPage> {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: widget.showWidget,
    );
  }
}



