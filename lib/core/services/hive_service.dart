import 'package:hive_flutter/adapters.dart';

class HiveService {

  static Future<void> initialize() async{
    await Hive.initFlutter();
    _box = await Hive.openBox('ticarium');
  }

  static late Box _box;


  static dynamic getValue(String key){
    var value = _box.get(key);
    return value;
  }

  static Future<void> setValue(String key,dynamic value) async {
    await _box.put(key, value);
  }

  static Future<void> deleteValue(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    var tempZipVersion = _box.get("zipVersion");
    var imagesPath = _box.get("imagesPath");
    var tempVolume = _box.get("soundVolume");
    var tempNotify = _box.get("allowNotify");
    await _box.clear();
    await  _box.put("zipVersion", tempZipVersion);
    await  _box.put("imagesPath", imagesPath);
    await  _box.put("soundVolume", tempVolume);
    await  _box.put("allowNotify", tempNotify);
    await  _box.put("tutorialShowed", true);
  }

}