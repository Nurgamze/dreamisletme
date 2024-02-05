import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

import '../modeller/Modeller.dart';

TextStyle headerStyle = TextStyle(color: Colors.white,fontSize: 12);
CustomColumnSizer customColumnSizer2 = CustomColumnSizer();

SfDataGridThemeData myGridTheme2 = SfDataGridThemeData(
  headerColor: Color.fromRGBO(235, 90, 12, 1),
  selectionColor:  Colors.blue,
  sortIconColor: Colors.white,
);



GridColumn dreamColumn2({required columnName,required label,Alignment alignment = Alignment.center,double minWidth = double.nan,bool visible = true}) {
  return GridColumn(columnName: columnName, label: Container(child: Text( label,style: headerStyle,),padding : EdgeInsets.only(left:10,right: 10),alignment: alignment),minimumWidth: minWidth,visible: visible);
}



class CustomColumnSizer2 extends ColumnSizer {
  @override
  double computeCellWidth(GridColumn column,DataGridRow row, Object? cellValue,TextStyle style){
    cellValue = formatValue(cellValue);
    return super.computeCellWidth(column,row,cellValue,style);
  }

}










class GeneralGridDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;


  final DataGridController dataGridController;
  GeneralGridDataSource(this.dataGridController,this.dataGridRows);


  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    TextStyle getSelectionStyle() {
      if(dataGridController.selectedRows.contains(row)){
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }else{
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black));
      }
    }
    Color getRowBackGroundColor() {
      final int index = effectiveRows.indexOf(row);
      if(index %2 != 0){
        return Colors.grey.shade300;
      }else {
        return Colors.white;
      }
    }
    return DataGridRowAdapter(
        color: getRowBackGroundColor(),
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: alignValue(e.value),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(e.value == null ? "": formatValue(e.value,formatDort: true).toString(),maxLines: 1,overflow: TextOverflow.ellipsis,style: getSelectionStyle(),),
          );
        }).toList()
    );


  }

  void updateDataGridSource() {
    notifyListeners();
  }
}

