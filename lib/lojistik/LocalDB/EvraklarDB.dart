import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class SayimDBHelper {

  static Database? _sayimDB;
  static SayimDBHelper? _sayimDBHelper;

  SayimDBHelper._createInstance();
  factory SayimDBHelper() {
    if(_sayimDBHelper == null) {
      _sayimDBHelper = SayimDBHelper._createInstance();
    }
    return _sayimDBHelper!;
  }

  Future<Database> get database async {
    if (_sayimDB == null) {
      _sayimDB = await initializeDatabase();
    }
    return _sayimDB!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    var path  = join(dir.path,"sayimsm.db");
    var database = await openDatabase(
      path, version: 3,
      onOpen: (db) async {
        await db.execute('''
        Create table if not exists DepolarArasiSiparisFisi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cikisDepoNo int,
            girisDepoNo int,
            cikisDepoAdi text,
            girisDepoAdi text,
            tarih text,
            seri text,
            aciklama text,
            aktarildiMi int,
            userId  text)
        ''');

        await db.execute('''
        Create table if not exists DepolarArasiSiparisFisiDetay (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            evrakId int,
            miktar text,
            stokKodu text,
            stokAdi text,
            birim text)
        ''');
      },
      onCreate: (db,version) async{
        await db.execute('''
        Create table if not exists SayimEvraklari (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            evrakAdi text,
            depNo int,
            depoAdi text,
            baslangicTarihi text,
            sonIslemTarihi text,
            aktarildiMi int,
            userId  text)
        ''');

        await db.execute('''
        Create table if not exists SayimKalemleri (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            evrakId int,
            raf text,
            miktar text,
            stokKodu text,
            stokAdi text,
            birim text)
        ''');

        await db.execute('''
        Create table if not exists PlansizNakliyeEvraklari (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cikisDepoNo int,
            girisDepoNo int,
            cikisDepoAdi text,
            girisDepoAdi text,
            tarih text,
            seri text,
            aciklama text,
            satir int,
            aktarildiMi int,
            userId  text)
        ''');

        await db.execute('''
        Create table if not exists PlansizNakliyeEvrakDetay (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            evrakId int,
            miktar text,
            stokKodu text,
            stokAdi text,
            birim text)
        ''');

      }
    );
    Sqflite.setLockWarningInfo(duration: Duration(seconds: 25),callback: (){});
    return database;
  }

  //SAYIM EVRAKLARI DATABASE İŞLEMLERİ////////////////////////////////////////
  Future<int> sayimEvrakEkle(String evrakAdi,int depNo,String depoAdi,String basTarih,String sonTarih,String userId) async {
    var db = await this.database;

    var check = await db.rawQuery('''
    SELECT *
    FROM SayimEvraklari WHERE evrakAdi = '$evrakAdi' and depoAdi = '$depoAdi' and depNo='$depNo'
    ''');
    if(check.length > 0){
      return -1;
    }else{

      var data = await db.rawInsert('''
    Insert Into SayimEvraklari(evrakAdi,depNo,depoAdi,baslangicTarihi,sonIslemTarihi,aktarildiMi,userID) 
    VALUES
    ('$evrakAdi',$depNo,'$depoAdi','$basTarih','$sonTarih',0,'$userId');Select last_insert_rowid();
    ''');
      return data;
    }
  }

  Future<List> sayimEvrakGetir() async {
    var db = await this.database;
    var data = await db.rawQuery('''   SELECT * FROM SayimEvraklari  ''');
    if(data.isEmpty){

      return [];
    }else{
      print("sayim evrak getir fonk $data");
      return data;
    }
  }

  Future<List> sayimEvrakAra(String aranacakKelime) async {
    var db = await this.database;
    var data = await db.rawQuery(''' SELECT *  FROM SayimEvraklari WHERE evrakAdi like '%$aranacakKelime%'; ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }

  Future<int> sayimEvrakTarihGuncelle(String sonTarih,int evrakId) async {
    var db = await this.database;
    var data = await db.rawUpdate('''UPDATE SayimEvraklariSET sonIslemTarihi = '$sonTarih' WHERE id = $evrakId''');
    return data;
  }
  Future<int> sayimEvrakAktarGuncelle(int evrakId) async {
    var db = await this.database;
    var data = await db.rawUpdate('''
    UPDATE SayimEvraklari
    SET aktarildiMi = '1' WHERE id = $evrakId
    ''');
    return data;
  }
  Future<int> sayimEvrakSil(String evrakAdi) async {
    var db = await this.database;
    var data = await db.rawDelete('''
    DELETE FROM SayimEvraklari
    WHERE evrakAdi = '$evrakAdi'
    ''');
    return data;
  }

  //SAYIM KALEMLERİ DATABASE İŞLEMLERİ

  Future<int> sayimKalemEkle(String raf,String stokKodu,String stokAdi,int evrakId,String miktar,String birim) async {
    var db = await this.database;
    stokKodu = stokKodu.replaceAll("'", "''");
    stokAdi = stokAdi.replaceAll("'", "''");
    raf = raf.replaceAll("'", "''");


    var data = await db.rawInsert('''
    Insert Into SayimKalemleri(raf,stokKodu,stokAdi,evrakId,miktar,birim) 
    VALUES
    ('$raf',$stokKodu,'$stokAdi',$evrakId,'$miktar','$birim');Select last_insert_rowid();
    ''');
    return data;
  }




  Future<int> sayimKalemVarMi(String raf,String stokKodu,int evrakID) async {
    stokKodu = stokKodu.replaceAll("'", "''");
    raf = raf.toLowerCase();
    var db = await this.database;
    var check = await db.rawQuery('''
    SELECT id
    FROM SayimKalemleri WHERE stokKodu = '$stokKodu' and lower(raf) = '$raf'  AND evrakId = $evrakID 
    ''');
    if(check.length > 0){
      return int.parse(check[0]['id'].toString());
    }else{
      return -1;
    }
  }




  Future<List> sayimKalemleriGetir(int evrakId) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM SayimKalemleri where evrakId = $evrakId
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }



  Future<List> sayimKalemiBul(int kalemId) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM SayimKalemleri where id = $kalemId
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }
  Future<int> sayimKalemiUpdate(int id,String miktar) async {
    var db = await this.database;
    var data = await db.rawUpdate('''  UPDATE SayimKalemleri  SET miktar = '$miktar' WHERE id = $id  ''');
    return data;
  }
  Future<int> sayimKalemiSil(int kalemId) async {
    var db = await this.database;
    var data = await db.rawDelete('''   DELETE FROM SayimKalemleri WHERE id = '$kalemId' ''');
    return data;
  }


  // PLANSIZ NAKLİYE EVRAK İŞLEMLERİ

  Future<int> plansizNakliyeEvrakAktarGuncelle(int evrakId) async {
    var db = await this.database;
    var data = await db.rawUpdate('''
    UPDATE PlansizNakliyeEvraklari
    SET aktarildiMi = '1' WHERE id = $evrakId
    ''');
    return data;
  }
  Future<int> plansizNakliyeEvrakSil(int evrakId) async {
    var db = await this.database;
    var data = await db.rawDelete('''
    DELETE FROM PlansizNakliyeEvraklari
    WHERE id = $evrakId
    ''');
    return data;
  }

  Future<int> plansizNakliyeEvrakEkle(int cikisDepono,int girisDepono,String cikisDepoAdi,String girisDepoAdi,String aciklama) async {
    var db = await this.database;
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    var data = await db.rawInsert('''
    Insert Into PlansizNakliyeEvraklari(cikisDepono,girisDepono,cikisDepoAdi,girisDepoAdi,aciklama,seri,aktarildiMi,userId,satir,tarih) 
    VALUES
    ($cikisDepono,$girisDepono,'$cikisDepoAdi','$girisDepoAdi','$aciklama','dr',0,94,0,'$formattedDate');Select last_insert_rowid();
    ''');
    return data;
  }

  Future<List> plansizNakliyeEvrakGetir() async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT * FROM PlansizNakliyeEvraklari
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }

  Future<int> plansizNakliyeEvrakDetayEkle(String stokKodu,String stokAdi,int evrakId,String miktar,String birim) async {
    var db = await this.database;
    var data = await db.rawInsert('''
    Insert Into PlansizNakliyeEvrakDetay(stokKodu,stokAdi,evrakId,miktar,birim) 
    VALUES
    ($stokKodu,'$stokAdi',$evrakId,'$miktar','$birim');Select last_insert_rowid();
    ''');
    return data;
  }

  Future<int> plansizNakliyeEvrakDetayVarMi(String stokKodu) async {
    var db = await this.database;
    var check = await db.rawQuery('''
    SELECT id
    FROM PlansizNakliyeEvrakDetay WHERE stokKodu = '$stokKodu'
    ''');
    if(check.length > 0){
      return int.parse(check[0]['id'].toString());
    }else{
      return -1;
    }
  }
  Future<List> plansizNakliyeEvrakDetayGetir(int evrakId) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM PlansizNakliyeEvrakDetay where evrakId = $evrakId
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }
  Future<List> plansizNakliyeEvrakDetayBul(int detayId) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM PlansizNakliyeEvrakDetay where id = $detayId
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }
  Future<int> plansizNakliyeEvrakDetayUpdate(int id,String miktar) async {
    var db = await this.database;
    var data = await db.rawUpdate('''
    UPDATE PlansizNakliyeEvrakDetay
    SET miktar = '$miktar' WHERE id = $id
    ''');
    return data;
  }
  Future<int> plansizNakliyeEvrakDetaySil(int detayId) async {
    var db = await this.database;
    var data = await db.rawDelete('''
    DELETE FROM PlansizNakliyeEvrakDetay
    WHERE id = '$detayId'
    ''');
    return data;
  }


  // PLANSIZ NAKLİYE EVRAK İŞLEMLERİ

  Future<int> depolarArasiSiparisFisiAktarGuncelle(int evrakId) async {
    var db = await this.database;
    var data = await db.rawUpdate('''
    UPDATE DepolarArasiSiparisFisi
    SET aktarildiMi = '1' WHERE id = $evrakId
    ''');
    return data;
  }
  Future<int> depolarArasiSiparisFisiSil(int evrakId) async {
    var db = await this.database;
    var data = await db.rawDelete('''
    DELETE FROM DepolarArasiSiparisFisi
    WHERE id = $evrakId
    ''');
    return data;
  }

  Future<int> depolarArasiSiparisFisiEkle(int cikisDepono,int girisDepono,String cikisDepoAdi,String girisDepoAdi,String aciklama) async {
    var db = await this.database;
    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(DateTime.now());
    var data = await db.rawInsert('''
    Insert Into DepolarArasiSiparisFisi(cikisDepono,girisDepono,cikisDepoAdi,girisDepoAdi,aciklama,seri,aktarildiMi,userId,satir,tarih) 
    VALUES
    ($cikisDepono,$girisDepono,'$cikisDepoAdi','$girisDepoAdi','$aciklama','dr',0,94,0,'$formattedDate');Select last_insert_rowid();
    ''');
    return data;
  }

  Future<List> depolarArasiSiparisFisiGetir() async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM DepolarArasiSiparisFisi
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }

  Future<int> depolarArasiSiparisFisiDetayEkle(String stokKodu,String stokAdi,int evrakId,String miktar,String birim) async {
    var db = await this.database;
    var data = await db.rawInsert('''
    Insert Into DepolarArasiSiparisFisiDetay(stokKodu,stokAdi,evrakId,miktar,birim) 
    VALUES
    ($stokKodu,'$stokAdi',$evrakId,'$miktar','$birim');Select last_insert_rowid();
    ''');
    return data;
  }

  Future<int> depolarArasiSiparisFisiDetayVarMi(String stokKodu,int evrakId) async {
    var db = await this.database;
    var check = await db.rawQuery('''
    SELECT id
    FROM DepolarArasiSiparisFisiDetay WHERE stokKodu = '$stokKodu' and evrakId = $evrakId
    ''');
    if(check.length > 0){
      return int.parse(check[0]['id'].toString());
    }else{
      return -1;
    }
  }
  Future<List> depolarArasiSiparisFisiDetayGetir(int evrakId) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM DepolarArasiSiparisFisiDetay where evrakId = $evrakId
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }
  Future<List> depolarArasiSiparisFisiDetayBul(int detayId) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT *
    FROM DepolarArasiSiparisFisiDetay where id = $detayId
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }
  Future<int> depolarArasiSiparisFisiDetayUpdate(int id,String miktar) async {
    var db = await this.database;
    var data = await db.rawUpdate('''
    UPDATE DepolarArasiSiparisFisiDetay
    SET miktar = '$miktar' WHERE id = $id
    ''');
    return data;
  }
  Future<int> depolarArasiSiparisFisiDetaySil(int detayId) async {
    var db = await this.database;
    var data = await db.rawDelete('''
    DELETE FROM DepolarArasiSiparisFisiDetay
    WHERE id = '$detayId'
    ''');
    return data;
  }

}
