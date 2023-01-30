import 'package:sdsdream_flutter/core/models/base_data_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CariDonemselBakiye extends BaseDataModel {
  String? donem;
  double? borc;
  double? alacak;
  double? bakiye;
  int? id;


  CariDonemselBakiye({
    this.donem,
    this.borc,
    this.alacak,
    this.bakiye,
    this.id,
  });


  @override
  fromMap(Map<String, dynamic> map) {
    return CariDonemselBakiye.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'donem': this.donem,
      'borc': this.borc,
      'alacak': this.alacak,
      'bakiye': this.bakiye,
      'id': this.id,
    };
  }

  factory CariDonemselBakiye.fromMap(Map<String, dynamic> map) {
    return CariDonemselBakiye(
      donem: map['donem'] as String,
      borc: double.tryParse(map['borc'].toString()),
      alacak: double.tryParse(map['alacak'].toString()),
      bakiye: double.tryParse(map['bakiye'].toString()),
      id: int.tryParse(map['id'].toString()),
    );
  }

  static List<DataGridRow> buildDataGridRows(List<CariDonemselBakiye> CariDonemselBakiyeList) {
    return CariDonemselBakiyeList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id', value: e.id),
          DataGridCell<String>(columnName: 'donem', value: e.donem),
          DataGridCell<double>(columnName: 'borc', value: e.borc),
          DataGridCell<double>(columnName: 'alacak', value: e.alacak),
          DataGridCell<double>(columnName: 'bakiye', value: e.bakiye),
        ]
    )).toList();
  }



}