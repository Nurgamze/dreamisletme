import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'cariler/models/cari.dart';
import 'modeller/GridModeller.dart';
import 'modeller/Listeler.dart';
import 'modeller/Modeller.dart';
import 'widgets/DreamCogsGif.dart';
import 'widgets/HorizontalPage.dart';
import 'widgets/const_screen.dart';
import 'yeni_formlar/YeniZiyaret.dart';

class ZiyaretlerSayfasi extends StatefulWidget {
  final bool adayMi;
  final AdayCarilerGridModel? cariData;
  final DreamCari? data;
  ZiyaretlerSayfasi(this.adayMi,{this.data,this.cariData});
  @override
  _ZiyaretlerSayfasiState createState() => _ZiyaretlerSayfasiState();
}

class _ZiyaretlerSayfasiState extends State<ZiyaretlerSayfasi> {


  bool loading = true;

  late ZiyaretlerDataSource _ziyaretlerDataSource = ZiyaretlerDataSource(_dataGridController);
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ziyaretleriGetir();
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    ziyaretlerGridList.clear();
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid(),) : Scaffold(
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue.shade900,
          onPressed: () {
            if(widget.adayMi){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => YeniZiyaretSayfasi(widget.cariData!.Kod,widget.cariData!.unvan)));
            }else{

              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => YeniZiyaretSayfasi(widget.data!.kod ?? "",widget.data!.unvan ?? "")));
            }
          },
        ),
        body: Column(
          children: [
            SizedBox(height: 5,),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                  color: Colors.blue.shade900,),
                margin: EdgeInsets.symmetric(horizontal: 1),
                height: 30,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Text("ZİYARET LİSTESİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
            ),
            loading ? Expanded(child: Container(child: DreamCogs())) :
            Expanded(child: Container(
              margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
              child: _grid()
            ),)
          ],
        ),
      )
    );

  }

  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        allowSorting: true,
        allowTriStateSorting: true,
        controller: this._dataGridController,
        source: _ziyaretlerDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        columns: <GridColumn> [
          dreamColumn(columnName: 'ziyTarihi',label : "ZİY. TARİHİ"),
          dreamColumn(columnName: 'personel',label : "PERSONEL"),
          dreamColumn(columnName: 'irtibatSekli',label : "İRTİBAT ŞEKLİ"),
          GridColumn(columnName: 'not', label: Container(child: Text( "ZİYARET NOTU",style: headerStyle,),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.centerLeft))
        ],
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex > 0){
              var row = _dataGridController.selectedRow!.getCells();
              String notAciklama = row[3].value;
              _dataGridController.selectedIndex = -1;
              showDialog(context: context,builder: (context) => DetayDialog(detay: notAciklama,baslik: "ZİYARET DETAYI"));
            }
          });
        },
      ),
    );
  }
  _ziyaretleriGetir() async {
    if (widget.adayMi){
      var response = await http.get(Uri.parse("${Sabitler.url}/api/ZiyaretlerForAday?vtname=${UserInfo.activeDB}&chkod=${widget.cariData!.Kod}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
      if(response.statusCode == 200) {
        setState(() {
          var ziyaretler = jsonDecode(response.body);
          for(var ziyaret in ziyaretler){
            ZiyaretlerGridModel gridZiyaretler = new ZiyaretlerGridModel(ziyaret["veri"].toString(), ziyaret["refNo"], DateTime.parse(ziyaret["ziyTarihi"].toString()), ziyaret["irtibatSekli"],
                ziyaret["personel"], ziyaret["cariYetkilisi"], ziyaret["yer"], ziyaret["konu"], ziyaret["not"]);
            ziyaretlerGridList.add(gridZiyaretler);
          }
          _ziyaretlerDataSource = ZiyaretlerDataSource(_dataGridController);
          loading = !loading;
        });
      }else{
      }
    }
    else{
      var response = await http.get(Uri.parse("${Sabitler.url}/api/Ziyaretler?vtname=${UserInfo.activeDB}&chkod=${widget.data!.kod}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
      print(response.statusCode);
      if(response.statusCode == 200){
        setState(() {
          var ziyaretler = jsonDecode(response.body);
          for(var ziyaret in ziyaretler){
            ZiyaretlerGridModel gridZiyaretler = new ZiyaretlerGridModel(ziyaret["veri"].toString(), ziyaret["refNo"], DateTime.parse(ziyaret["ziyTarihi"].toString()), ziyaret["irtibatSekli"],
                ziyaret["personel"], ziyaret["cariYetkilisi"], ziyaret["yer"], ziyaret["konu"], ziyaret["not"]);
            ziyaretlerGridList.add(gridZiyaretler);
          }
          loading = !loading;
        });
      }else if(response.statusCode == 404){
        setState(() {
          ziyaretlerGridList.clear();
          _ziyaretlerDataSource = ZiyaretlerDataSource(_dataGridController);
          loading =! loading;
        });
      }
    }
  }
}





class BaseDataGridSource extends DataGridSource {
  final DataGridController dataGridController;
  final List<DataGridRow> dataGridRows;
  BaseDataGridSource(this.dataGridController,this.dataGridRows) {
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

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





class ZiyaretlerDataSource extends DataGridSource {

  final DataGridController dataGridController;
  ZiyaretlerDataSource(this.dataGridController) {
    buildDataGridRows();
  }


  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = ziyaretlerGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<DateTime>(columnName: 'ziyTarihi',value: e.ziyTarihi),
          DataGridCell<String>(columnName: 'personel',value: e.personel),
          DataGridCell<String>(columnName: 'irtibatSekli',value: e.irtibatSekli),
          DataGridCell<String>(columnName: 'not',value: e.not),
        ]
    )).toList();
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
