import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Listeler.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
class StokFiyatlariSayfasi extends StatefulWidget {
  final String stokKodu;
  StokFiyatlariSayfasi({required this.stokKodu});
  @override
  _StokFiyatlariSayfasiState createState() => _StokFiyatlariSayfasiState();
}


class _StokFiyatlariSayfasiState extends State<StokFiyatlariSayfasi> {

  bool loading = false;
  bool sort = false;

  late StokFiyatlariDataSource _stokFiyatlariDataSource;
  DataGridController _dataGridController = new DataGridController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stokFiyatlariDataSource = StokFiyatlariDataSource(_dataGridController);
    _stokFiyatlariGetir();

    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stokFiyatlariGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    return ConstScreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: !loading ? DreamCogs() :
        Container(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.blue.shade900,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("SATIŞ FİYATLARI",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                      Text("${widget.stokKodu}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                    ],)
              ),
              Container(
                height: MediaQuery.of(context).size.height-188,
                margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                child: SfDataGridTheme(
                  data: myGridTheme,
                  child: SfDataGrid(
                    controller: _dataGridController,
                    selectionMode: SelectionMode.single,
                    allowSorting: true,
                    allowTriStateSorting: true,
                    columnWidthMode: ColumnWidthMode.auto,
                    columnSizer: customColumnSizer,
                    gridLinesVisibility: GridLinesVisibility.vertical,
                    headerGridLinesVisibility: GridLinesVisibility.vertical,
                    headerRowHeight: 35,
                    rowHeight: 35,
                    source: _stokFiyatlariDataSource,
                    columns: <GridColumn> [
                      dreamColumn(columnName: 'listeAdi', label: 'LİSTE ADI'),
                      dreamColumn(columnName: 'fiyat', label: 'FİYAT'),
                      dreamColumn(columnName: 'doviz', label: 'DÖVİZ'),
                    ],
                    onCellTap: (v) {
                      Future.delayed(Duration(milliseconds: 50), () async{
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );

  }

  _stokFiyatlariGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/StokSatisFiyatlari?VtIsim=${UserInfo.activeDB}&stokKodu=${widget.stokKodu}&AlisFiyatlari=${UserInfo.alisDetayYetkisi}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      var fiyatlarJson = jsonDecode(response.body);
      for(var fiyatlar in fiyatlarJson) {
        StokFiyatlariGridModel fiyat = StokFiyatlariGridModel(fiyatlar['listeAdi'], fiyatlar['fiyat'], fiyatlar['doviz']);
        stokFiyatlariGridList.add(fiyat);
      }
      setState(() {
        _stokFiyatlariDataSource = StokFiyatlariDataSource(_dataGridController);
        loading = true;
      });
    }else{
      setState(() {
        _stokFiyatlariDataSource = StokFiyatlariDataSource(_dataGridController);
        stokFiyatlariGridList.clear();
        loading = true;
      });
    }
  }
}





class StokFiyatlariDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = stokFiyatlariGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'listeAdi',value: e.listeAdi),
          DataGridCell<double>(columnName: 'fiyat',value: e.fiyat),
          DataGridCell<String>(columnName: 'doviz',value: e.doviz),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  StokFiyatlariDataSource(this.dataGridController) {
    buildDataGridRows();
  }
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
          print(e.value);
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