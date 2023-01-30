import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../modeller/GridModeller.dart';
import '../modeller/Listeler.dart';
import '../modeller/Modeller.dart';
import '../widgets/Dialoglar.dart';
import '../widgets/DreamCogsGif.dart';

class PortfoydekiCeklerSayfasi extends StatefulWidget {
  @override
  _PortfoydekiCeklerSayfasiState createState() => _PortfoydekiCeklerSayfasiState();
}

class _PortfoydekiCeklerSayfasiState extends State<PortfoydekiCeklerSayfasi> {

  bool loading = false;
  final DataGridController _dataGridController = DataGridController();
  late PortfoydekiCeklerDataSource _portfoydekiCeklerDataSource;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _portfoydekiCeklerDataSource = PortfoydekiCeklerDataSource(_dataGridController);
    AutoOrientation.fullAutoMode();
    _portfoydekiCeklerGetir();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    portfoydekiCeklerGridList.clear();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    print(currentOrientation);
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid()) : Scaffold(
          appBar: AppBar(
            title: Text("Portföydeki Çekler"),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
          ),
          body: !loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) :Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: _grid(),
            ),
      )
    );
  }

  _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        source: _portfoydekiCeklerDataSource,
        controller: this._dataGridController,
        selectionMode: SelectionMode.single,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        columns: <GridColumn> [
          dreamColumn(columnName: 'subeAdi',label : "ŞUBE ADI",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'musteriCekleri',label : "MÜŞTERİ ÇEKLERİ",),
          dreamColumn(columnName: 'firmaCekleri',label : "FİRMA ÇEKLERİ",),
          dreamColumn(columnName: 'toplamCek',label : "TOPLAM ÇEK",),
          dreamColumn(columnName: 'musteriSenetleri',label : "MÜŞTERİ SENETLERİ",),
          dreamColumn(columnName: 'firmaSenetleri',label : "FİRMA SENETLERİ",),
          dreamColumn(columnName: 'toplamSenet',label : "TOPLAM SENET",),

        ],
      ),
    );
  }
  _portfoydekiCeklerGetir() async {
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/PortfoydekiCekler?"
          "FullAccess=${UserInfo.fullAccess}&"
          "Mobile=true&"
          "DevInfo=${TelefonBilgiler.userDeviceInfo}&"
          "AppVer=${TelefonBilgiler.userAppVersion}&"
          "UserId=${UserInfo.activeUserId}"),
          headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 30));
    } on TimeoutException catch (e) {
      showDialog(context: context,
          builder: (BuildContext context ){
            return BilgilendirmeDialog("Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    } on Error catch (e) {
      showDialog(context: context,
          builder: (BuildContext context ){
            return BilgilendirmeDialog("Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    }
    if(response.statusCode == 200) {
      setState(() {
        var cekDetay = jsonDecode(response.body);
        for(var cek in cekDetay){
          PortfoydekiCeklerGridModel gridPortfoydekiCekler = new PortfoydekiCeklerGridModel(cek['subeAdi'],cek['musteriCekleri'],cek['firmaCekleri'],
              cek['toplamCek'],cek['musteriSenetleri'],cek['firmaSenetleri'],cek['toplamSenet']);
          portfoydekiCeklerGridList.add(gridPortfoydekiCekler);
        }
        _portfoydekiCeklerDataSource = PortfoydekiCeklerDataSource(_dataGridController);
        loading = !loading;
      });
    }
  }
}

class PortfoydekiCeklerDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = portfoydekiCeklerGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'subeAdi',value: e.subeAdi),
          DataGridCell<double>(columnName: 'musteriCekleri',value: e.musteriCekleri),
          DataGridCell<double>(columnName: 'firmaCekleri',value: e.firmaCekleri),
          DataGridCell<double>(columnName: 'toplamCek',value: e.toplamCek),
          DataGridCell<double>(columnName: 'musteriSenetleri',value: e.musteriSenetleri),
          DataGridCell<double>(columnName: 'firmaSenetleri',value: e.firmaSenetleri),
          DataGridCell<double>(columnName: 'toplamSenet',value: e.toplamSenet),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  PortfoydekiCeklerDataSource(this.dataGridController) {
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

          return Container(
            alignment: alignValue(e.value),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(e.value == null ? "": formatValue(e.value).toString(),maxLines: 1,overflow: TextOverflow.ellipsis,style: getSelectionStyle(),),
          );
        }).toList()
    );


  }

  void updateDataGridSource() {
    notifyListeners();
  }
}