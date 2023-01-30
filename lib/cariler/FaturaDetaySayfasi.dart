import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FaturaDetaySayfasi extends StatefulWidget {

  final String kayitNo;
  final String sira;
  final String seri;
  FaturaDetaySayfasi(this.sira,this.seri,this.kayitNo);
  @override
  _FaturaDetaySayfasiState createState() => _FaturaDetaySayfasiState();
}
final List<Detaylar> listDetaylar = [];


class _FaturaDetaySayfasiState extends State<FaturaDetaySayfasi> {
  bool sort = false;
  bool loading = false;
  final DataGridController _dataGridController = new DataGridController();

  late EmployeeDataSource _employeeDataSource = EmployeeDataSource(_dataGridController);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AutoOrientation.fullAutoMode();
    _detayGetir();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listDetaylar.clear();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return !loading ? Container(child: Center(child: CircularProgressIndicator(),),) :
    currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ?
    HorizontalPage(
      _grid()
    ) : Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/dreambg.jpg"), fit: BoxFit.cover)),
      child:  Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: Text("Fatura Detayları"),
        ),
        body: _grid(),
      ),
    );
  }


  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _employeeDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        controller: _dataGridController,
        columns: <GridColumn> [
          dreamColumn(columnName: 'evrakSeri', label: 'EVRAK SERİ',alignment: Alignment.center),
          dreamColumn(columnName: 'evrakSira', label: 'EVRAK SIRA',alignment: Alignment.center),
          dreamColumn(columnName: 'stokKodu',label: 'STOK KODU',alignment: Alignment.center),
          dreamColumn(columnName: 'stokAdi', label: 'STOK ADI',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'birimFiyat', label: 'BİRİM FİYAT',alignment: Alignment.center),
          dreamColumn(columnName: 'miktar', label: 'MİKTAR',alignment: Alignment.center),
          dreamColumn(columnName: 'tutar', label: 'TUTAR',alignment: Alignment.center),
          dreamColumn(columnName: 'iskonto', label: 'İSKONTO',alignment: Alignment.center),
          dreamColumn(columnName: 'masVergi', label: 'MAS VERGİ',alignment: Alignment.center),
          dreamColumn(columnName: 'netBirimFiyat', label: 'NET BİRİM FİYAT',alignment: Alignment.center),
          dreamColumn(columnName: 'netTutar', label: 'NET TUTAR',alignment: Alignment.center),
          dreamColumn(columnName: 'dovizKuru', label: 'DÖVİZ KURU',alignment: Alignment.center),
        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }


  _detayGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/FaturaDetay?seri=${widget.seri}&sira=${widget.sira}&RecNo=${widget.kayitNo}&vtName=${UserInfo.activeDB}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      var jsonDetaylar = jsonDecode(response.body);
      for(var detay in jsonDetaylar) {
        print(detay);
        Detaylar detaylar = Detaylar(detay['EvrakSeri'], detay['EvrakSira'],detay['StokKodu'],
            detay['StokAdi'],detay['BirimFiyat'], detay['Miktar'],detay['Tutar'],detay['Iskonto'],detay['MasVergi'],detay['NetBirimFiyat'],detay['NetTutar'],detay['DovizKuru']);
        setState(() {
          listDetaylar.add(detaylar);
          loading = true;
        });
      }
      _employeeDataSource = EmployeeDataSource(_dataGridController);
    }else{
      setState(() {
        loading = true;
      });
      showDialog(context: context,builder: (context) => 
          BilgilendirmeDialog("Bu faturaya ait detay bulunamamıştır")).then((value) => Navigator.pop(context));
    }
  }


}

class Detaylar {
  final String evrakSeri;
  final int evrakSira;
  final String stokKodu;
  final String stokAdi;
  final double birimFiyat;
  final double miktar;
  final double tutar;
  final double iskonto;
  final double masVergi;
  final double netBirimFiyat;
  final double netTutar;
  final double dovizKuru;
  Detaylar(this.evrakSeri,this.evrakSira,this.stokKodu,this.stokAdi,this.birimFiyat,this.miktar,this.tutar,this.iskonto,this.masVergi,this.netBirimFiyat,this.netTutar,this.dovizKuru);
}

class EmployeeDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = listDetaylar.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'evrakSeri' , value: e.evrakSeri),
          DataGridCell<int>(columnName: 'evrakSira' , value: e.evrakSira),
          DataGridCell<String>(columnName: 'stokKodu' , value: e.stokKodu),
          DataGridCell<String>(columnName: 'stokAdi' , value: e.stokAdi),
          DataGridCell<double>(columnName: 'birimFiyat' , value: e.birimFiyat),
          DataGridCell<double>(columnName: 'miktar' , value: e.miktar),
          DataGridCell<double>(columnName: 'tutar' , value: e.tutar),
          DataGridCell<double>(columnName: 'iskonto' , value: e.iskonto),
          DataGridCell<double>(columnName: 'masVergi' , value: e.masVergi),
          DataGridCell<double>(columnName: 'netBirimFiyat' , value: e.netBirimFiyat),
          DataGridCell<double>(columnName: 'netTutar' , value: e.netTutar),
          DataGridCell<double>(columnName: 'dovizKuru' , value: e.dovizKuru),
        ]
    )).toList();
  }



  final DataGridController dataGridController;
  EmployeeDataSource(this.dataGridController) {
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