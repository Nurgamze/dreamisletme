
import 'package:sdsdream_flutter/core/models/base_data_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Siparis extends BaseDataModel{

  DateTime? siparisTarihi;
  String? evrak;
  String? tip;
  String? cariKodu;
  String? unvani;
  int? miktar;
  int? teslimMiktar;
  int? kalan;
  double? tutar;
  DateTime? teslimTarihi;
  int? satirSayisi;
  String? durum;
  String? onayDurumu;

  Siparis({
    this.siparisTarihi,
    this.evrak,
    this.tip,
    this.cariKodu,
    this.unvani,
    this.miktar,
    this.teslimMiktar,
    this.kalan,
    this.tutar,
    this.teslimTarihi,
    this.satirSayisi,
    this.durum,
    this.onayDurumu,
  });
  Siparis.name({
    this.siparisTarihi,
    this.evrak,
    this.tip,
    this.cariKodu,
    this.unvani,
    this.miktar,
    this.teslimMiktar,
    this.kalan,
    this.tutar,
    this.teslimTarihi,
    this.satirSayisi,
    this.durum,
    this.onayDurumu,
  });


  Map<String, dynamic> toMap() {
    return {
      'siparisTarihi': this.siparisTarihi,
      'evrak': this.evrak,
      'tip': this.tip,
      'cariKodu': this.cariKodu,
      'unvani': this.unvani,
      'miktar': this.miktar,
      'teslimMiktar': this.teslimMiktar,
      'kalan': this.kalan,
      'tutar': this.tutar,
      'teslimTarihi': this.teslimTarihi,
      'satirSayisi': this.satirSayisi,
      'durum': this.durum,
      'onayDurumu': this.onayDurumu,
    };
  }

  factory Siparis.fromMap(Map<String, dynamic> map) {
    return Siparis(
      siparisTarihi: DateTime.tryParse(map['siparisTarihi'].toString()),
      evrak: map['evrak'],
      tip: map['tip'],
      cariKodu: map['cariKodu'],
      unvani: map['unvani'],
      miktar: int.tryParse(map['miktar'].toString()),
      teslimMiktar: int.tryParse(map['teslimMiktar'].toString()),
      kalan: int.tryParse(map['kalan'].toString()),
      tutar: double.tryParse(map['tutar'].toString()),
      teslimTarihi: DateTime.tryParse(map['teslimTarihi'].toString()),
      satirSayisi: int.tryParse(map['satirSayisi'].toString()),
      durum: map['durum'],
      onayDurumu: map['onayDurumu'],
    );
  }

  @override
  fromMap(Map<String, dynamic> map) {
    return Siparis.fromMap(map);
  }

  static List<DataGridRow> buildDataGridRows(List<Siparis> siparisList) {
    return siparisList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<DateTime>(columnName: 'siparisTarihi',value: e.siparisTarihi),
          DataGridCell<String>(columnName: 'evrak',value: e.evrak),
          DataGridCell<String>(columnName: 'tip',value: e.tip),
          DataGridCell<String>(columnName: 'cariKodu',value: e.cariKodu),
          DataGridCell<String>(columnName: 'unvani',value: e.unvani),
          DataGridCell<int>(columnName: 'miktar',value: e.miktar),
          DataGridCell<int>(columnName: 'teslimMiktar',value: e.teslimMiktar),
          DataGridCell<int>(columnName: 'kalan',value: e.kalan),
          DataGridCell<double>(columnName: 'tutar',value: e.tutar),
          DataGridCell<DateTime>(columnName: 'teslimTarihi',value: e.teslimTarihi),
          DataGridCell<int>(columnName: 'satirSayisi',value: e.satirSayisi),
          DataGridCell<String>(columnName: 'durum',value: e.durum),
          DataGridCell<String>(columnName: 'onayDurumu',value: e.onayDurumu),

        ]
    )).toList();
  }





}

