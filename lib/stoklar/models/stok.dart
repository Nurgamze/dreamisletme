import '../../core/models/base_data_model.dart';


class Stok extends BaseDataModel {
  String? stokKodu;
  String? stokIsim;
  String? kisaIsim;
  String? stokAlternatifIsim;
  String? stokAlternatifKod;
  String? stokYabanciIsim;
  String? anaGrup;
  String? altGrup;
  String? marka;
  String? reyon;
  double? depo1StokMiktar;
  double? depo2StokMiktar;
  double? depo3StokMiktar;
  double? depo4StokMiktar;
  double? tumDepolarStokMiktar;
  String? stokBirim;
  double? fiyat;
  String? doviz;
  double? alinanSiparisKalan;
  double? verilenSiparisKalan;
  double? son30GunSatis;
  double? son3AyOrtalamaSatis;
  double? son6AyOrtalamaSatis;
  double? sdsToplamStokMerkezDahil;
  double? sdsMerkez;
  double? sdsizmir;
  double? sdsAdana;
  double? sdsAntalya;
  double? sdsSeyrantepe;
  double? sdsAnkara;
  double? sdsEurasia;
  double? sdsBursa;
  double? sdsAnadolu;
  double? sdsIzmit;
  double? sdsBodrum;
  double? sdsKayseri;
  double? sdsSivas;
  double? sdsDenizli;
  double? sdsManisa;
  double? zenitled;
  double? zenitledUretim;
  double? zenitledMerkez;
  double? zenitledAdana;
  double? zenitledBursa;
  double? zenitledAntalya;
  double? zenitledAnkara;
  double? zenitledKonya;
  double? zenitledETicaret;
  double? zenitledPerpa;
  double? d1SdsToplamStokMerkezDahil;
  double? d1SdsMerkez;
  double? d1SdsIzmir;
  double? d1SdsAdana;
  double? d1SdsAntalya;
  double? d1SdsSeyrantepe;
  double? d1SdsAnkara;
  double? d1SdsEurasia;
  double? d1SdsBursa;
  double? d1SdsAnadolu;
  double? d1SdsIzmit;
  double? d1SdsBodrum;
  double? d1SdsKayseri;
  double? d1SdsSivas;
  double? d1SdsDenizli;
  double? d1SdsManisa;
  double? d1Zenitled;
  double? d1ZenitledUretim;
  double? d1ZenitledMerkez;
  double? d1ZenitledAdana;
  double? d1ZenitledBursa;
  double? d1ZenitledAntalya;
  double? d1ZenitledKonya;
  double? d1ZenitledAnkara;
  double? d1ZenitledPerpa;
  double? d1ZenitledETicaret;
  String? stokAileKutugu;
  String? barKodu;

  Stok({
    this.stokKodu,
    this.stokIsim,
    this.kisaIsim,
    this.stokAlternatifIsim,
    this.stokAlternatifKod,
    this.stokYabanciIsim,
    this.anaGrup,
    this.altGrup,
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
    this.zenitled,
    this.zenitledUretim,
    this.zenitledMerkez,
    this.zenitledAdana,
    this.zenitledBursa,
    this.zenitledAntalya,
    this.zenitledAnkara,
    this.zenitledKonya,
    this.zenitledETicaret,
    this.zenitledPerpa,
    this.d1SdsToplamStokMerkezDahil,
    this.d1SdsMerkez,
    this.d1SdsIzmir,
    this.d1SdsAdana,
    this.d1SdsAntalya,
    this.d1SdsSeyrantepe,
    this.d1SdsAnkara,
    this.d1SdsEurasia,
    this.d1SdsBursa,
    this.d1SdsAnadolu,
    this.d1SdsIzmit,
    this.d1SdsBodrum,
    this.d1SdsKayseri,
    this.d1SdsSivas,
    this.d1Zenitled,
    this.d1ZenitledUretim,
    this.d1ZenitledMerkez,
    this.d1ZenitledAdana,
    this.d1ZenitledBursa,
    this.d1ZenitledAntalya,
    this.d1ZenitledKonya,
    this.d1ZenitledAnkara,
    this.d1ZenitledPerpa,
    this.d1ZenitledETicaret,
    this.stokAileKutugu,
    this.barKodu,
  });

  factory Stok.fromMap(Map<String, dynamic> map) {
    return Stok(
      stokKodu: map['stokKodu'],
      stokIsim: map['stokIsim'],
      kisaIsim: map['kisaIsim'],
      stokAlternatifIsim: map['stokAlternatifIsim'],
      stokAlternatifKod: map['stokAlternatifKod'],
      stokYabanciIsim: map['stokYabanciIsim'],
      anaGrup: map['anaGrup'],
      altGrup: map['altGrup'],
      marka: map['marka'],
      reyon: map['reyon'],
      depo1StokMiktar: double.tryParse(map['depo1StokMiktar'].toString()),
      depo2StokMiktar: double.tryParse(map['depo2StokMiktar'].toString()),
      depo3StokMiktar: double.tryParse(map['depo3StokMiktar'].toString()),
      depo4StokMiktar: double.tryParse(map['depo4StokMiktar'].toString()),
      tumDepolarStokMiktar: double.tryParse(map['tumDepolarStokMiktar'].toString()),
      stokBirim: map['stokBirim'],
      fiyat: double.tryParse(map['fiyat'].toString()),
      doviz: map['doviz'],
      alinanSiparisKalan: double.tryParse(map['alinanSiparisKalan'].toString()),
      verilenSiparisKalan: double.tryParse(map['verilenSiparisKalan'].toString()),
      son30GunSatis: double.tryParse(map['son30GunSatis'].toString()),
      son3AyOrtalamaSatis: double.tryParse(map['son3AyOrtalamaSatis'].toString()),
      son6AyOrtalamaSatis: double.tryParse(map['son6AyOrtalamaSatis'].toString()),
      sdsToplamStokMerkezDahil: double.tryParse(map['sdsToplamStokMerkezDahil'].toString()),
      sdsMerkez: double.tryParse(map['sdsMerkez'].toString()),
      sdsizmir: double.tryParse(map['sdsizmir'].toString()),
      sdsAdana: double.tryParse(map['sdsAdana'].toString()),
      sdsAntalya: double.tryParse(map['sdsAntalya'].toString()),
      sdsSeyrantepe: double.tryParse(map['sdsSeyrantepe'].toString()),
      sdsAnkara: double.tryParse(map['sdsAnkara'].toString()),
      sdsEurasia: double.tryParse(map['sdsEurasia'].toString()),
      sdsBursa: double.tryParse(map['sdsBursa'].toString()),
      sdsAnadolu: double.tryParse(map['sdsAnadolu'].toString()),
      sdsIzmit: double.tryParse(map['sdsIzmit'].toString()),
      sdsBodrum: double.tryParse(map['sdsBodrum'].toString()),
      sdsKayseri: double.tryParse(map['sdsKayseri'].toString()),
      sdsSivas: double.tryParse(map['sdsSivas'].toString()),
      zenitled: double.tryParse(map['zenitled'].toString()),
      zenitledUretim: double.tryParse(map['zenitledUretim'].toString()),
      zenitledMerkez: double.tryParse(map['zenitledMerkez'].toString()),
      zenitledAdana: double.tryParse(map['zenitledAdana'].toString()),
      zenitledBursa: double.tryParse(map['zenitledBursa'].toString()),
      zenitledAntalya: double.tryParse(map['zenitledAntalya'].toString()),
      zenitledAnkara: double.tryParse(map['zenitledAnkara'].toString()),
      zenitledKonya: double.tryParse(map['zenitledKonya'].toString()),
      zenitledPerpa: double.tryParse(map['zenitledPerpa'].toString()),
      zenitledETicaret: double.tryParse(map['zenitledETicaret'].toString()),
      d1SdsToplamStokMerkezDahil: double.tryParse(map['D1SdsToplamStokMerkezDahil'].toString()),
      d1SdsMerkez: double.tryParse(map['D1SdsMerkez'].toString()),
      d1SdsIzmir: double.tryParse(map['D1SdsIzmir'].toString()),
      d1SdsAdana: double.tryParse(map['D1SdsAdana'].toString()),
      d1SdsAntalya: double.tryParse(map['D1SdsAntalya'].toString()),
      d1SdsSeyrantepe: double.tryParse(map['D1SdsSeyrantepe'].toString()),
      d1SdsAnkara: double.tryParse(map['D1SdsAnkara'].toString()),
      d1SdsEurasia: double.tryParse(map['D1SdsEurasia'].toString()),
      d1SdsBursa: double.tryParse(map['D1SdsBursa'].toString()),
      d1SdsAnadolu: double.tryParse(map['D1SdsAnadolu'].toString()),
      d1SdsIzmit: double.tryParse(map['D1SdsIzmit'].toString()),
      d1SdsBodrum: double.tryParse(map['D1SdsBodrum'].toString()),
      d1SdsKayseri: double.tryParse(map['D1SdsKayseri'].toString()),
      d1Zenitled: double.tryParse(map['D1Zenitled'].toString()),
      d1ZenitledUretim: double.tryParse(map['D1ZenitledUretim'].toString()),
      d1ZenitledMerkez: double.tryParse(map['D1ZenitledMerkez'].toString()),
      d1ZenitledAdana: double.tryParse(map['D1ZenitledAdana'].toString()),
      d1ZenitledBursa: double.tryParse(map['D1ZenitledBursa'].toString()),
      d1ZenitledAntalya: double.tryParse(map['D1ZenitledAntalya'].toString()),
      d1ZenitledKonya: double.tryParse(map['D1ZenitledKonya'].toString()),
      d1ZenitledAnkara: double.tryParse(map['D1ZenitledAnkara'].toString()),
      d1ZenitledPerpa: double.tryParse(map['D1ZenitledPerpa'].toString()),
      d1ZenitledETicaret: double.tryParse(map['D1ZenitledETicaret'].toString()),
      stokAileKutugu: map['stokAileKutugu'],
      barKodu: map['barKodu'],
    );
  }

  @override
  fromMap(Map<String, dynamic> map) {
    return Stok.fromMap(map);
  }
}