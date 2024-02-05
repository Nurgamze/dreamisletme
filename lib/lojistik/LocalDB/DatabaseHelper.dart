import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../../modeller/GridModeller.dart';
import '../../modeller/Modeller.dart';


class DatabaseHelper {

  static Database? _database;
  static DatabaseHelper? _databaseHelper;

  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }
  Future<Database> initializeDatabase() async {
    var dir = await getApplicationDocumentsDirectory();

    var path  = join(dir.path,"flutter.db");
    var database = await openDatabase(
      path,
      version: 3,
    );
    Sqflite.setLockWarningInfo(duration: Duration(seconds: 25),callback: (){});
    return database;
  }

  Future<List> aramaYap(String arananKelime) async {
    arananKelime = arananKelime.replaceAll("'", "''").replaceAll("*", "%").toLowerCase();
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    stokKodu, 
    stokAdi,
    BarkodTanimlari.barKodu, 
    birim, 
    anaGrup, 
    altGrup, 
    marka,                         
    reyon, 
    renk, 
    beden, 
    sezon, 
    hamMadde, 
    kategori
    FROM Stoklar 
	LEFT OUTER JOIN
	   BarkodTanimlari On BarkodTanimlari.barStokKodu = Stoklar.stokKodu
			where Stoklar.arama like '%$arananKelime%' OR barKodu = '$arananKelime'
    ''');

    return data;
  }







  Future<List<AlternatiflerGrid>> alternatifleriGetir(String stokKodu) async {
    var db = await this.database;
    List<AlternatiflerGrid> alternatiflerGridList = [];
    var data = await db.rawQuery('''
    SELECT 
    guid,
    alternatifKod
    FROM StokAlternatifleri Where stokKodu = '$stokKodu'
    ''');
    if(data.isEmpty){
      print("data empty");
      return [];
    }else{
      for(Map guid in data){
        var alternatifStoklarGuid = await db.rawQuery('''
      SELECT guid 
       From Stoklar Where stokKodu = '${guid["alternatifKod"]}'
      ''');

        if(alternatifStoklarGuid.length ==0){
          alternatiflerGridList.add(AlternatiflerGrid(guid["alternatifKod"],"TANIMSIZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",));
        }else{
          var alternatifList = await db.rawQuery('''
      SELECT 
      (select stokAdi from Stoklar WHERE stokKodu =  '${guid["alternatifKod"]}') stokAdi, *
       From StoklarUser Where guid = '${alternatifStoklarGuid[0]["guid"]}'
      ''') as Map;
          alternatiflerGridList.add(AlternatiflerGrid(guid["alternatifKod"],alternatifList[0]["stokAdi"],alternatifList[0]["urunTipi"],alternatifList[0]["ipRate"],alternatifList[0]["marka"],alternatifList[0]["kasaTipi"],
              alternatifList[0]["tip"],alternatifList[0]["ekOzellik"],alternatifList[0]["sinif"],alternatifList[0]["renk"],alternatifList[0]["levin"],alternatifList[0]["ledSayisi"],
              alternatifList[0]["lens"],alternatifList[0]["guc"],alternatifList[0]["volt"],alternatifList[0]["akim"],alternatifList[0]["ebat"],alternatifList[0]["kilo"],alternatifList[0]["recete1"],
              alternatifList[0]["koli"],alternatifList[0]["yeniAlan13"],alternatifList[0]["recete2"],alternatifList[0]["ongoruMasraf"] != null ? alternatifList[0]["ongoruMasraf"].toString() : "TANIMSIZ",alternatifList[0]["marka2"],alternatifList[0]["kilif"],alternatifList[0]["kelvin"],
              alternatifList[0]["vfBin"],alternatifList[0]["renkBin"],alternatifList[0]["lumenBin"],alternatifList[0]["satisPotansiyeli"],alternatifList[0]["aileKutugu"],alternatifList[0]["garantiSuresi"],alternatifList[0]["binKodu"]));
        }
      }

      return alternatiflerGridList;
    }
  }

  Future<List> stokDetayAra(String stokKodu) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    depoAdi,
    miktar
    FROM DeponunStoklari Where stokKodu = '$stokKodu'
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }

  Future<List> satisFiyatiAra(String stokKodu) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    aciklama,
    satisFiyati,
    paraBirimi
    FROM StokSatisFiyatListesi Where stokKodu = '$stokKodu'
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }


  Future<List<Depolar>?> depolarGetir2 () async{
    String? aktifSubeNo =UserInfo.aktifSubeNo;
    final response=await http.get(Uri.parse('http://192.168.20.52:3000/api/depo/${aktifSubeNo}'),
        headers: {"apikey" : Sabitler.apikey});
    print("response sonucu $response");
    if(response.statusCode==200){
      print(response.body);
      var depolarJson = jsonDecode(response.body.toString());
      if(depolarJson is List){
        List<Depolar> depos = depolarJson.expand((e) => e as List<dynamic>).map((e) => Depolar(
          depSubeNo: e['dep_subeno'],
          depAdi: e['dep_adi'],
          depNo: e['dep_no'],
        )).toList();
        return depos;
      }else{
        print("json veriler $depolarJson");
        return null;
      }
    }
  }

  Future<List<dynamic>?> sayimKalemiStoklariGetir(String arananKelime) async {
    arananKelime = arananKelime.replaceAll("'", "''").replaceAll("*", "%").toLowerCase();
    final response = await http.get(
        Uri.parse("http://192.168.20.52:3000/api/stoklar/$arananKelime"),
        headers: {"apikey": Sabitler.apikey});
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var data = responseData["data"];
      List<Stoklar> stoklar = List<Stoklar>.from(data.map((e) =>
          Stoklar(
            e['sto_kod'],
            e['sto_isim'],
            e['sto_max_stok'].toString(),
            e['sto_birim1_ad'],
            e['sto_anagrup_kod'],
            e['sto_altgrup_kod'],
            e['sto_marka_kodu'],
            e['sto_reyon_kodu'],
          ))).toList();
      return stoklar;
    }
  }

}