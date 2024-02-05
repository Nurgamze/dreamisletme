/*
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

import '../Modeller/GridModeller.dart';


class KullanicilarDBHelper {

  static Database _database;
  static KullanicilarDBHelper _kullanicilarDBHelper;

  KullanicilarDBHelper._createInstance();
  factory KullanicilarDBHelper() {
    if(_kullanicilarDBHelper == null) {
      _kullanicilarDBHelper = KullanicilarDBHelper._createInstance();
    }
    return _kullanicilarDBHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }
  Future<Database> initializeDatabase() async {
    var dir = await getApplicationDocumentsDirectory();

    var path  = join(dir.path,"users.db");
    var database = await openDatabase(
      path,
      version: 3,
    );
    Sqflite.setLockWarningInfo(duration: Duration(seconds: 25),callback: (){});
    return database;
  }

  Future<int> girisKontrol(String kullaniciAdi,String password) async {
    var db = await this.database;
    var user = await db.rawQuery('''
    SELECT 
    id
    FROM Kullanicilar
    WHERE ldap_user = '$kullaniciAdi' AND password = '$password'
    ''');
    if(user.length <= 0)
      return -1;
    var yetki = await db.rawQuery('''
    SELECT 
    lojistik_yetkisi
    FROM RLKullanicilarVeriTabanlari
    WHERE id_kullanicilar = '${user[0]['id']}'
    ''');

    return yetki[0]['lojistik_yetkisi'];
  }


}
*/