import 'package:sdsdream_flutter/core/models/base_data_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CariSatislar extends BaseDataModel {
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


  @override
  fromMap(Map<String, dynamic> map) {
    return CariSatislar.fromMap(map);
  }


  CariSatislar({
    this.stokKodu,
    this.stokAdi,
    this.birim,
    this.tarih,
    this.miktar,
    this.birimFiyat,
    this.paraBirimi,
    this.dovizBirimFiyat,
    this.doviz,
    this.kur,
    this.turu,
    this.evrak,
  });

  Map<String, dynamic> toMap() {
    return {
      'stokKodu': this.stokKodu,
      'stokAdi': this.stokAdi,
      'birim': this.birim,
      'tarih': this.tarih,
      'miktar': this.miktar,
      'birimFiyat': this.birimFiyat,
      'paraBirimi': this.paraBirimi,
      'dovizBirimFiyat': this.dovizBirimFiyat,
      'doviz': this.doviz,
      'kur': this.kur,
      'turu': this.turu,
      'evrak': this.evrak,
    };
  }

  factory CariSatislar.fromMap(Map<String, dynamic> map) {
    return CariSatislar(
      stokKodu: map['stokKodu'] as String,
      stokAdi: map['stokAdi'] as String,
      birim: map['birim'] as String,
      tarih: DateTime.tryParse(map['tarih'].toString()),
      miktar: double.tryParse(map['miktar'].toString()),
      birimFiyat: double.tryParse(map['birimFiyat'].toString()),
      paraBirimi: map['paraBirimi'] as String,
      dovizBirimFiyat: map['dovizBirimFiyat'] as String,
      doviz: map['doviz'] as String,
      kur: map['kur'] as String,
      turu: map['turu'] as String,
      evrak: map['evrak'] as String,
    );
  }

  static List<DataGridRow> buildDataGridRows(List<CariSatislar> CariSatislarList) {
    return CariSatislarList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'stokKodu',value: e.stokKodu),
          DataGridCell<String>(columnName: 'stokAdi',value: e.stokAdi),
          DataGridCell<DateTime>(columnName: 'tarih',value: e.tarih),
          DataGridCell<double>(columnName: 'miktar',value: e.miktar),
          DataGridCell<String>(columnName: 'birim',value: e.birim),
          DataGridCell<double>(columnName: 'birimFiyat',value: e.birimFiyat),
          DataGridCell<String>(columnName: 'paraBirimi',value: e.paraBirimi),
          DataGridCell<String>(columnName: 'dovizBirimFiyat',value: e.dovizBirimFiyat),
          DataGridCell<String>(columnName: 'doviz',value: e.doviz),
          DataGridCell<String>(columnName: 'kur',value: e.kur),
          DataGridCell<String>(columnName: 'turu',value: e.turu),
          DataGridCell<String>(columnName: 'evrak',value: e.evrak)
        ]
    )).toList();
  }
}