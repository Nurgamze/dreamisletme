import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sdsdream_flutter/GirisYapYeni.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/modeller/ProviderHelper.dart';
import 'modeller/SplashScreen.dart';
import 'core/services/api_service.dart';
import 'core/services/hive_service.dart';




Future<void> init() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid || Platform.isIOS){
    await Firebase.initializeApp();
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission(sound: true, badge: true, alert: true, provisional: false);
    await Permission.bluetoothConnect.request();
  }
  await HiveService.initialize();
  await APIService.initialize("http://api.sds.com.tr/api/");
}

Future<void> main() async {
   await init();
   return runApp(
    MultiProvider(
      providers: [
         ChangeNotifierProvider(create: (context) => StateHelper())
        ],
      child: MaterialApp(
       localizationsDelegates: const [
         GlobalMaterialLocalizations.delegate,
         GlobalCupertinoLocalizations.delegate,
         GlobalWidgetsLocalizations.delegate,
       ],
       supportedLocales: const [
         Locale('en', ''),Locale('tr', '')
       ],
       debugShowCheckedModeBanner: false,
        title: "Dream İşletme",
        theme: ThemeData(brightness: Brightness.light),
        home: SafeArea(
         child: MyApp(),
       ),
      ),
    )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    if(Device.get().isTablet ){
      TelefonBilgiler.isTablet = true;
    }else{
      AutoOrientation.portraitAutoMode();
    }
    _getVersion();
  }
  @override
  Widget build(BuildContext context) {
    return  SplashScreen(
      seconds: 2,
      navigateAfterSeconds:  GirisYapSayfasi(),
      title:  const Text('Hoşgeldiniz',
        style:  TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0
        ),
      ),
      image:  Image.asset('assets/images/b2b_isletme_v3.png',),
      backgroundColor: Colors.blue.shade900,
      styleTextUnderTheLoader:  TextStyle(),
      photoSize: 100.0,
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.white,
    );
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    TelefonBilgiler.appVersion = packageInfo.version;
  }
}




















