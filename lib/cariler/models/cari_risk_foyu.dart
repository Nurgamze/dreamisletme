import 'package:sdsdream_flutter/core/models/base_data_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CariRiskFoyu extends BaseDataModel {
  DateTime? belgeTarihi;
  String? doviz;
  double? kullKredi;
  String? pozisyon;
  String? referans;
  double? riski;
  String? sahibi;
  String? tipi;
  double? tutar;
  String? vadeCeyrek;
  String? vadeHafta;
  DateTime? vadeTarihi;

  @override
  fromMap(Map<String, dynamic> map) {
    return CariRiskFoyu.fromMap(map);
  }
  

  CariRiskFoyu({
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
    this.vadeTarihi,
  });

  Map<String, dynamic> toMap() {
    return {
      'belgeTarihi': this.belgeTarihi,
      'doviz': this.doviz,
      'kullKredi': this.kullKredi,
      'pozisyon': this.pozisyon,
      'referans': this.referans,
      'riski': this.riski,
      'sahibi': this.sahibi,
      'tipi': this.tipi,
      'tutar': this.tutar,
      'vadeCeyrek': this.vadeCeyrek,
      'vadeHafta': this.vadeHafta,
      'vadeTarihi': this.vadeTarihi,
    };
  }

  factory CariRiskFoyu.fromMap(Map<String, dynamic> map) {
    return CariRiskFoyu(
      belgeTarihi: DateTime.tryParse(map['belgeTarihi'].toString()),
      doviz: map['doviz'],
      kullKredi: double.tryParse(map['kullKredi'].toString()),
      pozisyon: map['pozisyon'],
      referans: map['referans'],
      riski: double.tryParse(map['riski'].toString()),
      sahibi: map['sahibi'],
      tipi: map['tipi'],
      tutar: double.tryParse(map['tutar'].toString()),
      vadeCeyrek: map['vadeCeyrek'],
      vadeHafta: map['vadeHafta'],
      vadeTarihi: DateTime.tryParse(map['vadeTarihi'].toString()),
    );
  }


  static List<DataGridRow> buildDataGridRows(List<CariRiskFoyu> CariRiskFoyuList) {
    return CariRiskFoyuList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'tipi',value: e.tipi),
          DataGridCell<String>(columnName: 'sahibi',value: e.sahibi),
          DataGridCell<String>(columnName: 'referans',value: e.referans),
          DataGridCell<String>(columnName: 'pozisyon',value: e.pozisyon),
          DataGridCell<DateTime>(columnName: 'belgeTarihi',value: e.belgeTarihi),
          DataGridCell<DateTime>(columnName: 'vadeTarihi',value: e.vadeTarihi),
          DataGridCell<double>(columnName: 'tutar',value: e.tutar),
          DataGridCell<String>(columnName: 'vadeHafta',value: e.vadeHafta),
          DataGridCell<String>(columnName: 'vadeCeyrek',value: e.vadeCeyrek),
          DataGridCell<String>(columnName: 'doviz',value: e.doviz),
          DataGridCell<double>(columnName: 'riski',value: e.riski),
          DataGridCell<double>(columnName: 'kullKredi',value: e.kullKredi),
        ]
    )).toList();
  }
  
  
}