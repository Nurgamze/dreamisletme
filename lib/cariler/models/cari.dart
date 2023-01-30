
import 'package:sdsdream_flutter/core/models/base_data_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DreamCari extends BaseDataModel{
  String? bolge;
  double? bakiye;
  String? email;
  String? grup;
  String? gsm;
  String? kod;
  double? kalanKredi;
  double? kredi;
  String? musteriTipi;
  String? mutabakatmail;
  double? risk;
  String? sektor;
  String? temsilci;
  String? unvan;
  String? vDairesi;
  String? vNo;
  String? vade;

  DreamCari({
    this.bolge,
    this.bakiye,
    this.email,
    this.grup,
    this.gsm,
    this.kod,
    this.kalanKredi,
    this.kredi,
    this.musteriTipi,
    this.mutabakatmail,
    this.risk,
    this.sektor,
    this.temsilci,
    this.unvan,
    this.vDairesi,
    this.vNo,
    this.vade,
  });

  Map<String, dynamic> toMap() {
    return {
      'bolge': this.bolge,
      'bakiye': this.bakiye,
      'email': this.email,
      'grup': this.grup,
      'gsm': this.gsm,
      'kod': this.kod,
      'kalanKredi': this.kalanKredi,
      'kredi': this.kredi,
      'musteriTipi': this.musteriTipi,
      'mutabakatmail': this.mutabakatmail,
      'risk': this.risk,
      'sektor': this.sektor,
      'temsilci': this.temsilci,
      'unvan': this.unvan,
      'vDairesi': this.vDairesi,
      'vNo': this.vNo,
      'vade': this.vade,
    };
  }

  factory DreamCari.fromMap(Map<String, dynamic> map) {
    return DreamCari(
      bolge: map['BOLGE'],
      bakiye: double.tryParse(map['Bakiye'].toString()),
      email: map['EMAIL'],
      grup: map['GRUP'],
      gsm: map['GSM'],
      kod: map['KOD'],
      kalanKredi: double.tryParse(map['KalanKredi'].toString()),
      kredi: double.tryParse(map['Kredi'].toString()),
      musteriTipi: map['MUSTERITIPI'],
      mutabakatmail: map['MUTABAKATMAIL'],
      risk: double.tryParse(map['Risk'].toString()),
      sektor: map['SEKTOR'],
      temsilci: map['TEMSILCI'],
      unvan: map['UNVAN'],
      vDairesi: map['VDAIRESI'],
      vNo: map['VNO'],
      vade: map['Vade'],
    );
  }

  @override
  fromMap(Map<String, dynamic> map) {
    return DreamCari.fromMap(map);
  }


  static List<DataGridRow> buildDataGridRows(List<DreamCari> carilerList) {
    return carilerList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'Unvan',value: e.unvan),
          DataGridCell<String>(columnName: 'KOD',value: e.kod),
          DataGridCell<double>(columnName: 'Bakiye',value: e.bakiye),
          DataGridCell<double>(columnName: 'Risk',value: e.risk),
          DataGridCell<double>(columnName: 'Kredi',value: e.kredi),
          DataGridCell<double>(columnName: 'KalanKredi',value: e.kalanKredi),
          DataGridCell<String>(columnName: 'Vade',value: e.vade),
          DataGridCell<String>(columnName: 'TEMSILCI',value: e.temsilci),
          DataGridCell<String>(columnName: 'SEKTOR',value: e.sektor),
          DataGridCell<String>(columnName: 'BOLGE',value: e.bolge),
          DataGridCell<String>(columnName: 'GRUP',value: e.grup),
          DataGridCell<String>(columnName: 'VDAIRESI',value: e.vDairesi),
          DataGridCell<String>(columnName: 'VNO',value: e.vNo),
          DataGridCell<String>(columnName: 'EMAIL',value: e.email),
          DataGridCell<String>(columnName: 'GSM',value: e.gsm),
          DataGridCell<String>(columnName: 'MUSTERITIPI',value: e.musteriTipi),
          DataGridCell<String>(columnName: 'MUTABAKATMAIL',value: e.mutabakatmail),
        ]
    )).toList();
  }
}

