import 'dart:convert';

class AdayCarilerGridModel {
  final String? Sektor;
  final String? KayID;
  final String? Grup;
  final String? Adres;
  final String Kod;
  final String? Bolge;
  final String? Yetkili;
  final String? TelBolge;
  final String? Telefon;
  final String? VergiDaireNo;
  final String? YetkiliEposta;
  final String? Temsilci;
  final String unvan;
  final String? Web;
  final String? EMAIL;
  final String? YetkiliCep;

  AdayCarilerGridModel(
      this.Sektor,
      this.Bolge,
      this.VergiDaireNo,
      this.KayID,
      this.Temsilci,
      this.unvan,
      this.Grup,
      this.Kod,
      this.Web,
      this.EMAIL,
      this.Yetkili,
      this.Telefon,
      this.TelBolge,
      this.YetkiliCep,
      this.Adres,
      this.YetkiliEposta);
}

class AlislarGridModel {
  String? stokKodu;
  String? stokAdi;
  String? birim;
  DateTime? tarih;
  double? miktar;
  double? birimFiyat;
  String? paraBirimi;
  String? dovizBirimFiyat;
  String? doviz;
  String? kur;
  String? turu;
  String? evrak;
  AlislarGridModel(
      this.stokKodu,
      this.stokAdi,
      this.tarih,
      this.miktar,
      this.birim,
      this.birimFiyat,
      this.paraBirimi,
      this.dovizBirimFiyat,
      this.doviz,
      this.kur,
      this.turu,
      this.evrak);
}

class StokKimlereSatilmisGridModel {
  String? cariKodu;
  String? cariAdi;
  String? temsilci;
  String? birim;
  DateTime? tarih;
  double? miktar;
  double? birimFiyat;
  String? paraBirimi;
  String? dovizBirimFiyat;
  String? doviz;
  String? kur;
  String? turu;
  String? evrak;
  StokKimlereSatilmisGridModel(
      this.cariKodu,
      this.cariAdi,
      this.temsilci,
      this.tarih,
      this.miktar,
      this.birim,
      this.birimFiyat,
      this.paraBirimi,
      this.dovizBirimFiyat,
      this.doviz,
      this.kur,
      this.turu,
      this.evrak);
}

class StokKimlerdenAlinmisGridModel {
  String? cariKodu;
  String? cariAdi;
  String? temsilci;
  String? birim;
  DateTime? tarih;
  double? miktar;
  double? birimFiyat;
  String? paraBirimi;
  String? dovizBirimFiyat;
  String? doviz;
  String? kur;
  String? turu;
  String? evrak;
  StokKimlerdenAlinmisGridModel(
      this.cariKodu,
      this.cariAdi,
      this.temsilci,
      this.tarih,
      this.miktar,
      this.birim,
      this.birimFiyat,
      this.paraBirimi,
      this.dovizBirimFiyat,
      this.doviz,
      this.kur,
      this.turu,
      this.evrak);
}

class CariEkstreGridModel {
  final double? bakiye;
  final DateTime? belgeTarihi;
  final String cinsi;
  final String evrakSeri;
  final String evrakSira;
  final String evrakTipi;
  final DateTime? isTarihi;
  final String kayit;
  final double? meblag;
  final String normalIade;
  final String tip;
  final DateTime? vadeTarihi;

  CariEkstreGridModel(
      this.bakiye,
      this.belgeTarihi,
      this.cinsi,
      this.evrakSeri,
      this.evrakSira,
      this.evrakTipi,
      this.isTarihi,
      this.kayit,
      this.meblag,
      this.normalIade,
      this.tip,
      this.vadeTarihi);
}

class CarilerGridModel {
  final String? Bolge;
  final double Bakiye;
  final String? Email;
  final String? Grup;
  final String? Gsm;
  final String Kod;
  final double KalanKredi;
  final double Kredi;
  final String? MusteriTipi;
  final String? Mutabakatmail;
  final double Risk;
  final String? Sektor;
  final String? Temsilci;
  final String Unvan;
  final String? VDairesi;
  final String? VNo;
  final String? Vade;

  CarilerGridModel(
      this.Bolge,
      this.KalanKredi,
      this.Risk,
      this.Bakiye,
      this.Temsilci,
      this.Unvan,
      this.Vade,
      this.Kod,
      this.VDairesi,
      this.Email,
      this.VNo,
      this.Sektor,
      this.Mutabakatmail,
      this.MusteriTipi,
      this.Kredi,
      this.Gsm,
      this.Grup);
}

class RiskFoyuGridModel {
  final DateTime? belgeTarihi;
  final String doviz;
  final double kullKredi;
  final String pozisyon;
  final String referans;
  final double riski;
  final String sahibi;
  final String tipi;
  final double tutar;
  final String vadeCeyrek;
  final String vadeHafta;
  final DateTime? vadeTarihi;

  RiskFoyuGridModel(
      this.belgeTarihi,
      this.doviz,
      this.kullKredi,
      this.pozisyon,
      this.referans,
      this.riski,
      this.sahibi,
      this.tipi,
      this.tutar,
      this.vadeCeyrek,
      this.vadeHafta,
      this.vadeTarihi);
}

class DonemselBakiyelerGridModel {
  final String donem;
  final double borc;
  final double alacak;
  final double bakiye;
  final int id;
  DonemselBakiyelerGridModel(
      this.id, this.donem, this.borc, this.alacak, this.bakiye);
}

class DovizKurlariGridModel {
  final String kur;
  final double alis;
  final double satis;
  final double efAlis;
  final double efSatis;
  final DateTime tarih;

  DovizKurlariGridModel(
      this.kur, this.alis, this.satis, this.efAlis, this.efSatis, this.tarih);
}

class TahsilatlarGridModel {
  final String? evrakTipi;
  final String? cari;
  final String? evrakTarihi;
  final String? vade;
  final double? tutar;
  final String? sonZiyaretTarihi;
  final String? sonZiyaretPersoneli;
  final String? notu;

  TahsilatlarGridModel(this.evrakTipi, this.cari, this.evrakTarihi, this.vade,
      this.tutar, this.sonZiyaretTarihi, this.sonZiyaretPersoneli, this.notu);
}

class TahsilatBakiyeAnaliziGridModel {
  final String? sube;
  final String? alacaklar;
  final String? nakit;
  final String? cek;
  final String? senet;
  final String? toplamTahsilat;

  TahsilatBakiyeAnaliziGridModel(this.sube, this.alacaklar, this.nakit,
      this.cek, this.senet, this.toplamTahsilat);
}

class CiroTablosuGridModel {
  final String? vtKod;
  final String? sube;
  final double? ciroGecenYil;
  final double? ciroBuAy;
  final double? ciroBuYil;
  final double? iskonto;
  final int? irsaliyeSayisi;
  final int? musteriSayisi;
  final String? irsaliyeOrtalamasi;
  final double? nakit;
  final double? cek;
  final double? senet;
  final double? toplamTahsilat;

  CiroTablosuGridModel(
      {this.vtKod,
      this.sube,
      this.ciroGecenYil,
      this.ciroBuAy,
      this.ciroBuYil,
      this.iskonto,
      this.irsaliyeSayisi,
      this.musteriSayisi,
      this.irsaliyeOrtalamasi,
      this.nakit,
      this.cek,
      this.senet,
      this.toplamTahsilat});
  factory CiroTablosuGridModel.fromMap(Map<String, dynamic> map) {
    return CiroTablosuGridModel(
      vtKod: map['VTKod'],
      sube: map['SUBE'],
      ciroGecenYil: map['CIRO GEÇEN YIL'],
      ciroBuAy: map['CIRO BU AY'],
      ciroBuYil: map['CIRO BU YIL'],
      iskonto: map['ISKONTO'],
      irsaliyeSayisi: map['IRSALIYE SAYISI'],
      musteriSayisi: map['MUSTERI SAYISI'],
      irsaliyeOrtalamasi: map['IRSALIYE ORTALAMASI'],
      nakit: map['Nakit'],
      cek: map['Cek'],
      senet: map['Senet'],
      toplamTahsilat: map['ToplamTahsilat'],
    );
  }
}

class StokSatisKarlilikRaporuGridModel {
  final String? tarih;
  final String? cariIsmi;
  final String? stokAdi;
  final double? satisMiktar;
  final String? satisBirimi;
  final double? dovizFiyati;
  final String? dovizCinsi;
  final double? dovizKuru;
  final double? satisTutari;
  final double? maliyet;
  final double? karTutar;
  final double? karYuzde;

  StokSatisKarlilikRaporuGridModel(
      this.tarih,
      this.cariIsmi,
      this.stokAdi,
      this.satisMiktar,
      this.satisBirimi,
      this.dovizFiyati,
      this.dovizCinsi,
      this.dovizKuru,
      this.satisTutari,
      this.maliyet,
      this.karTutar,
      this.karYuzde);
}

class SatisTahsilatlarAnaliziGridModel {
  final String? cari;
  final String? unvan;
  final String? sektor;
  final String? grup;
  final String? temsilci;
  final String? bolge;
  final double? netSatis;
  final double? kdvDahil;
  final double? nakitTahsilat;
  final double? cekTah;
  final double? senetTah;
  final double? toplamTahsilat;

  SatisTahsilatlarAnaliziGridModel(
      this.cari,
      this.unvan,
      this.sektor,
      this.grup,
      this.temsilci,
      this.bolge,
      this.netSatis,
      this.kdvDahil,
      this.nakitTahsilat,
      this.cekTah,
      this.senetTah,
      this.toplamTahsilat);
}

class OrtalamaVadeHesapla {
  DateTime tarih;
  double tutar;

  OrtalamaVadeHesapla({required this.tarih, required this.tutar});
}

class SatisTahsilatTemsilciModel {
  final String? tarih;
  final String? temsilci;
  final double? iadeDahilKdvHaricNetSatis;
  final double? kdvDahilToplamCiro;
  final double? nakit;
  final double? cek;
  final double? senet;
  final double? toplamTahsilat;

  SatisTahsilatTemsilciModel(
      this.tarih,
      this.temsilci,
      this.iadeDahilKdvHaricNetSatis,
      this.kdvDahilToplamCiro,
      this.nakit,
      this.cek,
      this.senet,
      this.toplamTahsilat);

  Map<String, dynamic> toMap() {
    return {
      'tarih': this.tarih,
      'temsilci': this.temsilci,
      'iadeDahilKdvHaricNetSatis': this.iadeDahilKdvHaricNetSatis,
      'kdvDahilToplamCiro': this.kdvDahilToplamCiro,
      'nakit': this.nakit,
      'cek': this.cek,
      'senet': this.senet,
      'toplamTahsilat': this.toplamTahsilat,
    };
  }
}

class SatisTahsilatOzetGridModel {
  final String tarih;
  final String sube;
  final double iadeDahilKdvHaricNetSatis;
  final double kdvDahilToplamCiro;
  final double nakit;
  final double cek;
  final double senet;
  final double toplamTahsilat;

  SatisTahsilatOzetGridModel(
      this.tarih,
      this.sube,
      this.iadeDahilKdvHaricNetSatis,
      this.kdvDahilToplamCiro,
      this.nakit,
      this.cek,
      this.senet,
      this.toplamTahsilat);
}

class OrtalamaVadeGridModel {
  final double? bakiye;
  final DateTime? belgeTarihi;
  final String cinsi;
  final String evrakSeri;
  final String evrakSira;
  final String evrakTipi;
  final DateTime? isTarihi;
  final String kayit;
  final double? meblag;
  final String normalIade;
  final String tip;
  final DateTime? vadeTarihi;
  final double? kalanBorc;
  final String kalanGun;
  final String gecenGun;

  OrtalamaVadeGridModel(
      this.bakiye,
      this.belgeTarihi,
      this.cinsi,
      this.evrakSeri,
      this.evrakSira,
      this.evrakTipi,
      this.isTarihi,
      this.kayit,
      this.meblag,
      this.normalIade,
      this.tip,
      this.vadeTarihi,
      this.kalanBorc,
      this.gecenGun,
      this.kalanGun);
}

class PortfoydekiCeklerGridModel {
  final String subeAdi;
  final double musteriCekleri;
  final double firmaCekleri;
  final double toplamCek;
  final double musteriSenetleri;
  final double firmaSenetleri;
  final double toplamSenet;

  PortfoydekiCeklerGridModel(
      this.subeAdi,
      this.musteriCekleri,
      this.firmaCekleri,
      this.toplamCek,
      this.musteriSenetleri,
      this.firmaSenetleri,
      this.toplamSenet);
}

class SatislarGridModel {
  String stokKodu;
  String stokAdi;
  String birim;
  DateTime tarih;
  double miktar;
  double birimFiyat;
  String paraBirimi;
  String dovizBirimFiyat;
  String doviz;
  String kur;
  String turu;
  String evrak;
  SatislarGridModel(
      this.stokKodu,
      this.stokAdi,
      this.tarih,
      this.miktar,
      this.birim,
      this.birimFiyat,
      this.paraBirimi,
      this.dovizBirimFiyat,
      this.doviz,
      this.kur,
      this.turu,
      this.evrak);
}

class AcikSiparislerGridModel {
  int sipCins;
  int sipTip;
  String sipEvrakSeri;
  int sipEvrakSira;
  String sipStokKod;
  String sipStokIsim;
  String musteriIsim;
  String musteriKod;
  double? sipMiktar;
  double? sipTeslimMiktar;
  double? kalan;
  double? tutar;
  String? birim;
  double? birimFiyat;
  String? dovizCinsi;
  DateTime? sip_tarih;
  DateTime? sip_teslim_tarih;


  AcikSiparislerGridModel(
      this.sipCins,
      this.sipTip,
      this.sipEvrakSeri,
      this.sipEvrakSira,
      this.sipStokKod,
      this.sipStokIsim,
      this.musteriIsim,
      this.musteriKod,
      this.sipMiktar,
      this.sipTeslimMiktar,
      this.kalan,
      this.tutar,
      this.birim,
      this.birimFiyat,
      this.dovizCinsi,
      this.sip_tarih,
      this.sip_teslim_tarih,
      );
}

class TumAcikSiparislerGridModel{
  DateTime? sip_tarih;
  String? sip_no;
  DateTime? sip_teslim_tarih;
  String musteriKod;
  String musteriIsim;
  String? temsilci;
  String sipStokKod;
  String sipStokIsim;
  double? sipNetFiyat;
  String? dovizCinsi;
  double? tutar;
  double? TlTutar;
  double? sipMiktar;
  double? kalanMiktar;
  double? kalan2;
  double? mevcutStok;
  double? verilenSip;
  String? aciklama1;
  String? aciklama2;

  TumAcikSiparislerGridModel(
      this.sip_tarih,
      this.sip_no,
      this.sip_teslim_tarih,
      this.musteriKod,
      this.musteriIsim,
      this.temsilci,
      this.sipStokKod,
      this.sipStokIsim,
      this.sipNetFiyat,
      this.dovizCinsi,
      this.tutar,
      this.TlTutar,
      this.sipMiktar,
      this.kalanMiktar,
      this.kalan2,
      this.mevcutStok,
      this.verilenSip,
      this.aciklama1,
      this.aciklama2);
}

class DepoDetayGridModel{
   String? subeKodu;
   String? subeAdi;
   String? depoAdi;
   String? depoKodu;
   String? stokKodu;
   String? stokAdi;
   double? stokMiktar;

   DepoDetayGridModel(this.subeKodu,this.subeAdi,this.depoAdi,this.depoKodu,this.stokKodu,this.stokAdi,this.stokMiktar);
}


// class CariSektorKodu{
//   String? cari_sektor_kodu;
//   CariSektorKodu(this.cari_sektor_kodu);
// }

class ZiyaretlerGridModel {
  final String veri;
  final String refNo;
  final DateTime ziyTarihi;
  final String irtibatSekli;
  final String personel;
  final String cariYetkilisi;
  final String yer;
  final String konu;
  final String not;

  ZiyaretlerGridModel(this.veri, this.refNo, this.ziyTarihi, this.irtibatSekli,
      this.personel, this.cariYetkilisi, this.yer, this.konu, this.not);
}

class StoklarGridModel {
  String stokKodu;
  String stokIsim;
  String kisaIsim;
  String? stokAlternatifIsim;
  String? stokAlternatifKod;
  String? stokYabanciIsim;
  String anaGrup;
  String altGrup;
  String kategori;  //kategorikodu eklendi
  String? marka;
  String? reyon;
  double depo1StokMiktar;
  double depo2StokMiktar;
  double depo3StokMiktar;
  double depo4StokMiktar;
  double tumDepolarStokMiktar;
  String stokBirim;
  double fiyat;
  String doviz;
  double alinanSiparisKalan;
  double verilenSiparisKalan;
  double son30GunSatis;
  double son3AyOrtalamaSatis;
  double son6AyOrtalamaSatis;
  double sdsToplamStokMerkezDahil;
  double sdsMerkez;
  double sdsizmir;
  double sdsAdana;
  double sdsAntalya;
  double sdsSeyrantepe;
  double sdsAnkara;
  double sdsEurasia;
  double sdsBursa;
  double sdsAnadolu;
  double sdsIzmit;
  double sdsBodrum;
  double sdsKayseri;
  double sdsSivas;
  double sdsDenizli;
  double sdsManisa;
  double zenitled;
  double zenitledUretim;
  double zenitledMerkez;
  double zenitledAdana;
  double zenitledBursa;
  double zenitledAntalya;
  double zenitledAnkara;
  double zenitledKonya;
  double zenitledPerpa;
  double zenitledETicaret;
  double D1SdsToplamStokMerkezDahil;
  double D1SdsMerkez;
  double D1SdsIzmir;
  double D1SdsAdana;
  double D1SdsAntalya;
  double D1SdsSeyrantepe;
  double D1SdsAnkara;
  double D1SdsEurasia;
  double D1SdsBursa;
  double D1SdsAnadolu;
  double D1SdsIzmit;
  double D1SdsBodrum;
  double D1SdsKayseri;
  double D1SdsSivas;
  double D1SdsDenizli;
  double D1SdsManisa;
  double D1Zenitled;
  double D1ZenitledUretim;
  double D1ZenitledMerkez;
  double D1ZenitledAdana;
  double D1ZenitledBursa;
  double D1ZenitledAntalya;
  double D1ZenitledKonya;
  double D1ZenitledAnkara;
  double D1ZenitledPerpa;
  double D1ZenitledETicaret;
  String? stokAileKutugu;
  String? barKodu;

  StoklarGridModel(
      this.stokKodu,
      this.stokIsim,
      this.barKodu,
      this.kisaIsim,
      this.stokAlternatifIsim,
      this.stokAlternatifKod,
      this.stokYabanciIsim,
      this.anaGrup,
      this.altGrup,
      this.kategori, //kategorikodu eklendi
      this.marka,
      this.reyon,
      this.depo1StokMiktar,
      this.depo2StokMiktar,
      this.depo3StokMiktar,
      this.depo4StokMiktar,
      this.tumDepolarStokMiktar,
      this.stokBirim,
      this.fiyat,
      this.doviz,
      this.alinanSiparisKalan,
      this.verilenSiparisKalan,
      this.son30GunSatis,
      this.son3AyOrtalamaSatis,
      this.son6AyOrtalamaSatis,
      this.sdsToplamStokMerkezDahil,
      this.sdsMerkez,
      this.sdsizmir,
      this.sdsAdana,
      this.sdsAntalya,
      this.sdsSeyrantepe,
      this.sdsAnkara,
      this.sdsEurasia,
      this.sdsBursa,
      this.sdsAnadolu,
      this.sdsIzmit,
      this.sdsBodrum,
      this.sdsKayseri,
      this.sdsSivas,
      this.sdsDenizli,
      this.sdsManisa,
      this.zenitled,
      this.zenitledUretim,
      this.zenitledMerkez,
      this.zenitledAdana,
      this.zenitledBursa,
      this.zenitledAntalya,
      this.zenitledAnkara,
      this.zenitledKonya,
      this.zenitledPerpa,
      this.zenitledETicaret,
      this.D1SdsToplamStokMerkezDahil,
      this.D1SdsMerkez,
      this.D1SdsIzmir,
      this.D1SdsAdana,
      this.D1SdsAntalya,
      this.D1SdsSeyrantepe,
      this.D1SdsAnkara,
      this.D1SdsEurasia,
      this.D1SdsBursa,
      this.D1SdsAnadolu,
      this.D1SdsIzmit,
      this.D1SdsBodrum,
      this.D1SdsKayseri,
      this.D1SdsSivas,
      this.D1SdsDenizli,
      this.D1SdsManisa,
      this.D1Zenitled,
      this.D1ZenitledUretim,
      this.D1ZenitledMerkez,
      this.D1ZenitledAdana,
      this.D1ZenitledBursa,
      this.D1ZenitledAntalya,
      this.D1ZenitledAnkara,
      this.D1ZenitledKonya,
      this.D1ZenitledPerpa,
      this.D1ZenitledETicaret,
      this.stokAileKutugu,);
}


class StokFiyatlariGridModel {
  String listeAdi;
  double fiyat;
  String doviz;

  StokFiyatlariGridModel(this.listeAdi, this.fiyat, this.doviz);
}

class StokReferanslariGridModel {
  int id;
  String cariUnvan;
  String sehir;
  String yetkili;
  String eposta;
  String telefon;
  String olusturanAdi;
  String? detay;
  int olusturan;


  StokReferanslariGridModel({
    required this.id,
    required this.cariUnvan,
    required this.sehir,
    required this.yetkili,
    required this.eposta,
    required this.telefon,
    required this.olusturanAdi,
    required this.detay,
    required this.olusturan,

  });

  factory StokReferanslariGridModel.fromMap(Map<String, dynamic> map) {
    return StokReferanslariGridModel(
      id: map['referans_id'],
      cariUnvan: map['referans_cariUnvan'],
      sehir: map['referans_sehir'],
      yetkili: map['referans_yetkili'],
      eposta: map['referans_eposta'],
      telefon: map['referans_telefon'],
      olusturanAdi: map['referans_olusturanAdi'],
      detay: map['referans_detay'],
      olusturan: map['referans_olusturan'],
    );
  }
}

class StokAlternatifleriGridModel {
  String? dep_adi;
  String? sto_kod;
  String? sto_isim;
  double? Miktar;

 // String? urunTipi;
 // String? ipRate;
 //  String? marka;
 //  String? kasaTipi;
 // String? tip;
 // String? ekOzellik;
 // String? sinifi;
 // String? renk;
 // String? ledSayisi;
 // String? volt;
 // String? guc;
 //  String? kelvin;
 // String? akim;
 // String? garantiSuresi;
 // String? satisPotansiyeli;
 //  String? aileKutugu;

  StokAlternatifleriGridModel(
      this.dep_adi,
      this.sto_kod,
      this.sto_isim,
      this.Miktar,

      // this.urunTipi,
      // this.ipRate,
      // this.marka,
      // this.kasaTipi,
      // this.tip,
      // this.ekOzellik,
      // this.sinifi,
      // this.renk,
      // this.ledSayisi,
      // this.volt,
      // this.guc,
      // this.kelvin,
      // this.akim,
      // this.garantiSuresi,
      // this.satisPotansiyeli,
      // this.aileKutugu
      );
}

class PortalTalepleriGridModel {
  String talepUuid;
  int talepNo;
  String atanan;
  String durumu;
  DateTime olusturmaTarihi;
  int yuzde;
  DateTime? kapanisTarihi;
  String talepBasligi;
  String aciklama;
  PortalTalepleriGridModel(
      this.talepUuid,
      this.talepNo,
      this.atanan,
      this.durumu,
      this.olusturmaTarihi,
      this.yuzde,
      this.kapanisTarihi,
      this.talepBasligi,
      this.aciklama);
}

class OnlineHesabimGridModel {
  double? tutar;
  double? bakiye;
  String? aciklama;
  String? transferTipi;
  String? gonderenIban;
  String? gonderenVkn;
  DateTime? islemTarihi;
  String? cariKodu;
  String? cariUnvan;
  OnlineHesabimGridModel(
      this.tutar,
      this.bakiye,
      this.aciklama,
      this.transferTipi,
      this.gonderenIban,
      this.gonderenVkn,
      this.islemTarihi,
      this.cariKodu,
      this.cariUnvan);
}

class ZiyaretPlaniGridModel {
  final int id;
  final String? durum;
  final String? planli;
  final DateTime? tarih;
  final DateTime? planTarih;
  final String cariKod;
  final String cariAd;
  final String? irtibatSekli;
  final int? ilgiliId;
  final String? ilgili;
  final String? ziyaretNotu;
  final String? planNotu;
  final String? atayan;
  final DateTime? atamaTarih;
  final String? sehir;

  ZiyaretPlaniGridModel(
      this.id,
      this.durum,
      this.planli,
      this.tarih,
      this.planTarih,
      this.cariKod,
      this.cariAd,
      this.irtibatSekli,
      this.ilgiliId,
      this.ilgili,
      this.ziyaretNotu,
      this.planNotu,
      this.atayan,
      this.atamaTarih,
      this.sehir);
}

class SatisCiroKaybiGridModel {
  String cariKod;
  String cariUnvan;
  String cariTemsilci;
  String sektor;
  double ciro;
  int hareketliAySayisi;
  double hareketliAylarOrt;
  double hareketBagimsiz12AyOrt;
  double agirlikliOrtCiroBeklentisi;
  double son3AylikOrtCiro;
  double son3AylikCiroKaybi;
  double son6AylikOrtCiro;
  double son6AylikCiroKaybi;

  SatisCiroKaybiGridModel(
      this.cariKod,
      this.cariUnvan,
      this.cariTemsilci,
      this.sektor,
      this.ciro,
      this.hareketliAySayisi,
      this.hareketliAylarOrt,
      this.hareketBagimsiz12AyOrt,
      this.agirlikliOrtCiroBeklentisi,
      this.son3AylikOrtCiro,
      this.son3AylikCiroKaybi,
      this.son6AylikOrtCiro,
      this.son6AylikCiroKaybi);
}



class ButceGerceklesenRapor {
  final int? sira;
  final String? donem;
  final String? stokHizmetDetayKodu;
  final double? hedeflenenTlSatis;
  final double? gerceklesenTlSatis;
  final double? tlSatisFarki;
  final double? hedeflenenAltDovizSatis;
  final double? gerceklesenAltDovizSatis;
  final double? altDovizSatisFarki;

  const ButceGerceklesenRapor({
    this.sira,
    this.donem,
    this.stokHizmetDetayKodu,
    this.hedeflenenTlSatis,
    this.gerceklesenTlSatis,
    this.tlSatisFarki,
    this.hedeflenenAltDovizSatis,
    this.gerceklesenAltDovizSatis,
    this.altDovizSatisFarki,
  });



  factory ButceGerceklesenRapor.fromMap(Map<String, dynamic> map) {
    return ButceGerceklesenRapor(
      sira: map['sira'],
      donem: map['donem'],
      stokHizmetDetayKodu: map['stokHizmetDetayKodu'],
      hedeflenenTlSatis: double.tryParse(map['hedeflenenTlSatis'].toString()),
      gerceklesenTlSatis: double.tryParse(map['gerceklesenTlSatis'].toString()),
      tlSatisFarki: double.tryParse(map['tlSatisFarki'].toString()),
      hedeflenenAltDovizSatis: double.tryParse(map['hedeflenenAltDovizSatis'].toString()),
      gerceklesenAltDovizSatis: double.tryParse(map['gerceklesenAltDovizSatis'].toString()),
      altDovizSatisFarki: double.tryParse(map['altDovizSatisFarki'].toString()),
    );
  }

}


class StokMiktarPopUpGrid{
  String depoAdi;
  double miktar;

  StokMiktarPopUpGrid(this.depoAdi,this.miktar);
}

class StokFiyatPopUpGrid{
  String aciklama;
  String fiyat;

  StokFiyatPopUpGrid(this.aciklama,this.fiyat);
}

class SayimlarSayfasiDataGrid{
  int? id;
  String? evrakAdi;
  int? depoKod;
  String? depoAdi;
  String? basTarihi;
  String? sonIslemTarihi;
  int? aktarildiMi;
  String? userId;

  SayimlarSayfasiDataGrid(this.id,this.evrakAdi,this.depoKod,this.depoAdi,this.basTarihi,this.sonIslemTarihi,this.userId);
}

class SayimEvrakSayfasiDataGrid{
  int id;
  int evrakId;
  String raf;
  String miktar;
  String stokKodu;
  String stokAdi;
  String birim;

  SayimEvrakSayfasiDataGrid(this.id,this.evrakId,this.raf,this.miktar,this.stokKodu,this.stokAdi,this.birim);
}

class PlansizNakliyeDataGrid{
  int? id;
  int? cikisDepoNo;
  int? girisDepoNo;
  int? satir;
  String? seri;
  String? cikisDepoAdi;
  String? girisDepoAdi;
  String? tarih;
  String? aciklama;
  int? aktarildiMi;
  PlansizNakliyeDataGrid(this.id,this.cikisDepoNo,this.girisDepoNo,this.satir,this.seri,this.cikisDepoAdi,this.girisDepoAdi,this.tarih,this.aciklama);
}
class PlansizNakliyeEvrakDataGrid{
  int id;
  int evrakId;
  String miktar;
  String stokKodu;
  String stokAdi;
  String birim;

  PlansizNakliyeEvrakDataGrid(this.id,this.evrakId,this.miktar,this.stokKodu,this.stokAdi,this.birim);
}


class DepolarArasiSiparisFisiDataGrid{
  int? id;
  int? cikisDepoNo;
  int? girisDepoNo;
  int? satir;
  String? seri;
  String? cikisDepoAdi;
  String? girisDepoAdi;
  String? tarih;
  String? aciklama;
  int? aktarildiMi;
  DepolarArasiSiparisFisiDataGrid(this.id,this.cikisDepoNo,this.girisDepoNo,this.satir,this.seri,this.cikisDepoAdi,this.girisDepoAdi,this.tarih,this.aciklama);
}
class DepolarArasiSiparisFisiDetayDataGrid{
  int id;
  int evrakId;
  String miktar;
  String stokKodu;
  String stokAdi;
  String birim;

  DepolarArasiSiparisFisiDetayDataGrid(this.id,this.evrakId,this.miktar,this.stokKodu,this.stokAdi,this.birim);
}

class AlternatiflerGrid{
  String kodu;
  String stokAdi;
  String urunTipi;
  String ipRate;
  String marka;
  String kasaTipi;
  String tip;
  String ekOzellik;
  String sinif;
  String renk;
  String levin;
  String ledSayisi;
  String lens;
  String guc;
  String volt;
  String akim;
  String ebat;
  String kilo;
  String recete1;
  String koli;
  String yeniAlan13;
  String recete2;
  String ongoruMasraf;
  String marka2;
  String kilif;
  String kelvin;
  String vfBin;
  String renkBin;
  String lumenBin;
  String satisPotansiyeli;
  String aileKutugu;
  String garantiSuresi;
  String binKodu;

  AlternatiflerGrid(this.kodu,this.stokAdi,this.urunTipi,this.ipRate,this.marka,this.kasaTipi,this.tip,this.ekOzellik,this.sinif,this.renk,this.levin,this.ledSayisi,this.lens,this.guc,this.volt,this.akim,this.ebat,this.kilo,this.recete1,this.koli,this.yeniAlan13,this.recete2,this.ongoruMasraf,this.marka2,this.kilif,this.kelvin,this.vfBin,this.renkBin,this.lumenBin,this.satisPotansiyeli,this.aileKutugu,this.garantiSuresi,this.binKodu);
}


//VERİ TABANI MODELLERİ

class StokSatisFiyatListesiInfo{
  String? stokKodu;
  String? aciklama;
  double? satisFiyati;
  String? paraBirimi;
  StokSatisFiyatListesiInfo({this.stokKodu,this.aciklama,this.satisFiyati,this.paraBirimi});
}

class DepolarInfo{
  int? depNo;
  String? depoAdi;
  DepolarInfo({this.depNo,this.depoAdi});
}

class BarkodTanimlariInfo{
  String? barStokKodu;
  String? barKodu;
  BarkodTanimlariInfo({this.barStokKodu,this.barKodu});
}

class DeponunStoklariInfo{
  int? depNo;
  String? depoAdi;
  String? stokKodu;
  double? miktar;
  DeponunStoklariInfo({this.depNo,this.depoAdi,this.stokKodu,this.miktar});
}




class Stoklar{
  String? sto_kod;
  String? sto_isim;
  String? sto_max_stok;
  String? sto_birim1_ad;
  String? sto_anagrup_kod;
  String? sto_altgrup_kod;
  String? sto_marka_kodu;
  String? sto_reyon_kodu;
  Stoklar(this.sto_kod,this.sto_isim,this.sto_max_stok,this.sto_birim1_ad,this.sto_anagrup_kod,this.sto_altgrup_kod,this.sto_marka_kodu,this.sto_reyon_kodu);

  dynamic operator [](String key) {
    switch (key) {
      case "sto_kod":
        return sto_kod;
      case "sto_isim":
        return sto_isim;
      case "sto_max_stok":
        return sto_max_stok;
      case "sto_birim1_ad":
        return sto_birim1_ad;
      case "sto_anagrup_kod":
        return sto_anagrup_kod;
      case "sto_altgrup_kod":
        return sto_altgrup_kod;
      case "sto_marka_kodu":
        return sto_marka_kodu;
      case "sto_reyon_kodu":
        return sto_reyon_kodu;
      default:
        throw Exception("Bilinmeyen özellik");
    }
  }

}


//benim eklediklerim
class Depolar{
  int? depSubeNo;
  String? depAdi;
  int? depNo;
  Depolar({this.depSubeNo,this.depAdi,this.depNo});

  factory Depolar.fromJson(Map<String, dynamic> json) {
    return Depolar(
      depSubeNo: json['dep_subeno'],
      depAdi: json['dep_adi'],
      depNo: json['dep_no'],
    );
  }

}


class GonderilecekVeriModel {
  String evrakId;
  String evrakAdi;
  String depoKodu;
  String basTarih;
  String sonTarih;
  String stokKodu;
  String miktar;
  String raf;

  GonderilecekVeriModel(this.evrakId, this.evrakAdi, this.depoKodu, this.basTarih, this.sonTarih, this.stokKodu, this.miktar, this.raf);
}




// class ZenitStoklar{
//   String? stokKodu;
//   String? stokAdi;
//   String? listeAdi;
//   String? fiyat;
//   String? birim;
//   String? anaGrup;
//   String? altGrup;
//   String? marka;
//   String? reyon;
//   String? kisaIsmi;
//   String? paraBirimi;
//   String? miktar;
//
//   ZenitStoklar(this.stokKodu,this.stokAdi,this.miktar,this.birim,this.anaGrup,this.altGrup,this.marka,this.reyon,this.listeAdi,this.fiyat,this.paraBirimi,this.kisaIsmi);
//
// }

//
// class DataGridModel{
//   String stokKodu;
//   String stokAdi;
//   String barKodu;
//   String birim;
//   String anaGrup;
//   String altGrup;
//   String marka;
//   String reyon;
//   String renk;
//   String beden;
//   String sezon;
//   String hamMadde;
//   String kategori;
//
//   DataGridModel(this.stokKodu,this.stokAdi,this.barKodu,this.birim,this.anaGrup,this.altGrup,this.marka,this.reyon,this.renk,this.beden,this.sezon,this.hamMadde,this.kategori);
// }