import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Listeler.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/yeni_formlar/YeniStokReferans.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../widgets/Dialoglar.dart';

class StokReferanslarSayfasi extends StatefulWidget {
  final String stokKodu, stokAdi;
  StokReferanslarSayfasi({required this.stokKodu,required this.stokAdi});
  @override
  _StokReferanslarSayfasiState createState() => _StokReferanslarSayfasiState();
}

class _StokReferanslarSayfasiState extends State<StokReferanslarSayfasi> {

  bool loading = false;
  bool sort = false;

  DataGridController _dataGridController = new DataGridController();
  late StokReferanslarDataSource _stokReferanslarDataSource;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stokReferanslarDataSource = StokReferanslarDataSource(_dataGridController);
    _stokReferanslarGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stokReferanslariGridList.clear();
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue.shade900,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => YeniStokReferans(widget.stokKodu))).then((value) {
                  if(value == true){
                    _stokReferanslarGetir();
                  }
            });
          },
        ),
        body: !loading ? DreamCogs() :
        Container(
          padding: EdgeInsets.only(bottom: Device.get().isIphoneX ? 16 :0),
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
                      Text("REFERANS MÜŞTERİLERİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                      Text("${widget.stokKodu}-${widget.stokAdi}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                    ],)
              ),
              Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                    child: SfDataGridTheme(
                      data: myGridTheme,
                      child: SfDataGrid(
                        selectionMode: SelectionMode.single,
                        allowSorting: true,
                        allowTriStateSorting: true,
                        columnWidthMode: ColumnWidthMode.auto,
                        columnSizer: customColumnSizer,
                        gridLinesVisibility: GridLinesVisibility.vertical,
                        headerGridLinesVisibility: GridLinesVisibility.vertical,
                        headerRowHeight: 35,
                        controller: _dataGridController,
                        rowHeight: 35,
                        source: _stokReferanslarDataSource,
                        columns: <GridColumn> [
                          dreamColumn(columnName: 'cariUnvan', label: 'CARİ ÜNVAN',alignment: Alignment.centerLeft),
                          dreamColumn(columnName: 'yetkili', label: 'YETKİLİ',),
                          dreamColumn(columnName: 'sehir', label: 'ŞEHİR',),
                          dreamColumn(columnName: 'eposta', label: 'E-POSTA',),
                          dreamColumn(columnName: 'telefon', label: 'TELEFON',),
                          dreamColumn(columnName: 'olusturan', label: 'OLUŞTURAN',),
                          dreamColumn(columnName: 'aciklama', label: 'AÇIKLAMA',),
                        ],
                        onCellTap: (value) {
                          Future.delayed(Duration(milliseconds: 50), () async{
                            FocusScope.of(context).requestFocus(new FocusNode());
                            if(value.rowColumnIndex.rowIndex > 0){
                              var row = _dataGridController.selectedRow!.getCells();
                              String notAciklama = row[6].value ?? "";
                              _dataGridController.selectedIndex = -1;
                              showDialog(context: context,builder: (context) => DetayDialog(detay: notAciklama,baslik: "AÇIKLAMA"));
                            }
                          });
                        },
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      )
    );

  }

  _stokReferanslarGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/StokReferanslar?stokKodu=${widget.stokKodu}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      stokReferanslariGridList.clear();
      var referanslarJson = jsonDecode(response.body);
      for(var referans in referanslarJson) {
        StokReferanslariGridModel referansModel = StokReferanslariGridModel.fromMap(referans);
        stokReferanslariGridList.add(referansModel);
      }
      setState(() {
        loading = true;
      });
    }else{
      setState(() {
        stokReferanslariGridList.clear();
        loading = true;
      });
    }
    _stokReferanslarDataSource = StokReferanslarDataSource(_dataGridController);
  }
}





class StokReferanslarDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = stokReferanslariGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
        DataGridCell<String>(columnName: 'cariUnvan',value: e.cariUnvan),
        DataGridCell<String>(columnName: 'yetkili',value: e.yetkili),
        DataGridCell<String>(columnName: 'sehir',value: e.sehir),
        DataGridCell<String>(columnName: 'eposta',value: e.eposta),
        DataGridCell<String>(columnName: 'telefon',value: e.telefon),
        DataGridCell<int>(columnName: 'olusturan',value: e.olusturan),
        DataGridCell<String>(columnName: 'aciklama',value: e.detay),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  StokReferanslarDataSource(this.dataGridController) {
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