import 'package:sdsdream_flutter/core/models/base_data_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CariEkstre extends BaseDataModel {
  double? bakiye;
  DateTime? belgeTarihi;
  String? cinsi;
  String? evrakSeri;
  String? evrakSira;
  String? evrakTipi;
  DateTime? isTarihi;
  String? kayit;
  double? meblag;
  String? normalIade;
  String? tip;
  DateTime? vadeTarihi;

  CariEkstre({
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
  });

  CariEkstre.name(
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

  Map<String, dynamic> toMap() {
    return {
      'bakiye': this.bakiye,
      'belgeTarihi': this.belgeTarihi,
      'cinsi': this.cinsi,
      'evrakSeri': this.evrakSeri,
      'evrakSira': this.evrakSira,
      'evrakTipi': this.evrakTipi,
      'isTarihi': this.isTarihi,
      'kayit': this.kayit,
      'meblag': this.meblag,
      'normalIade': this.normalIade,
      'tip': this.tip,
      'vadeTarihi': this.vadeTarihi,
    };
  }

  factory CariEkstre.fromMap(Map<String, dynamic> map) {
    return CariEkstre(
      bakiye: double.tryParse(map['bakiye'].toString()),
      belgeTarihi: DateTime.tryParse(map['belgeTarihi'].toString()),
      cinsi: map['cinsi'],
      evrakSeri: map['evrakSeri'],
      evrakSira: map['evrakSira'],
      evrakTipi: map['evrakTipi'],
      isTarihi: DateTime.tryParse(map['isTarihi'].toString()),
      kayit: map['kayit'],
      meblag: double.tryParse(map['meblag'].toString()),
      normalIade: map['normalIade'],
      tip: map['tip'],
      vadeTarihi: DateTime.tryParse(map['vadeTarihi'].toString()),
    );
  }

  @override
  fromMap(Map<String, dynamic> map) {
    return CariEkstre.fromMap(map);
  }

  static List<DataGridRow> buildDataGridRows(List<CariEkstre> cariEkstreList) {
    return cariEkstreList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName:'tip',value: e.tip),
          DataGridCell<DateTime>(columnName:'isTarihi',value: e.isTarihi),
          DataGridCell<double>(columnName:'meblag',value: e.meblag),
          DataGridCell<double>(columnName:'bakiye',value: e.bakiye),
          DataGridCell<String>(columnName:'cinsi',value: e.cinsi),
          DataGridCell<String>(columnName:'normalIade',value: e.normalIade),
          DataGridCell<String>(columnName:'evrakSeri',value: e.evrakSeri),
          DataGridCell<String>(columnName:'evrakSira',value: e.evrakSira),
          DataGridCell<DateTime>(columnName:'belgeTarihi',value: e.belgeTarihi),
          DataGridCell<DateTime>(columnName:'vadeTarihi',value: e.vadeTarihi),
          DataGridCell<String>(columnName:'evrakTipi',value: e.evrakTipi),
          DataGridCell<String>(columnName:'kayit',value: e.kayit),
        ]
    )).toList();
  }



}