import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'modeller/GridModeller.dart';
import 'modeller/Listeler.dart';
import 'modeller/Modeller.dart';
import 'widgets/Dialoglar.dart';
import 'widgets/DreamCogsGif.dart';
import 'widgets/HorizontalPage.dart';
import 'widgets/const_screen.dart';

class DovizKurlariSayfasi extends StatefulWidget {
  final bool userMi;
  DovizKurlariSayfasi(this.userMi);
  @override
  _DovizKurlariSayfasiState createState() => _DovizKurlariSayfasiState();
}

class _DovizKurlariSayfasiState extends State<DovizKurlariSayfasi> {
  bool loading = false;
  String secilenTarih = DateFormat('dd-MM-yyyy').format(DateTime.now());
  DateTime now = DateTime.now();
  String dateYear = DateTime.now().year.toString();
  String dateMonth = new DateFormat.MMMM('tr').format(DateTime.now());
  String dateDay = DateTime.now().day.toString();
  
  final DataGridController _dataGridController = DataGridController();
  late DovizKurlariDataSource _dovizKurlariDataSource = DovizKurlariDataSource(_dataGridController);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dovizKurGetir();
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dovizKurlariGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ?
      HorizontalPage(_grid(),) :
      Scaffold(
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: Column(
          children: [
            InkWell(
              child: Container(
                child:Row(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),topLeft: Radius.circular(5)),
                          color: Colors.blue.shade900,
                        ),
                        margin: EdgeInsets.only(left: 1),
                        height: 50,
                        width: MediaQuery.of(context).size.width/5,
                        child: Center(child: Text("TARİH:",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                    ),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(5),topRight: Radius.circular(5)),
                            border: Border.all(color: Colors.blue.shade900),
                            color: Colors.white
                        ),
                        margin: EdgeInsets.only(right: 1),
                        height: 50,
                        width: MediaQuery.of(context).size.width/5*4-4,
                        child: Center(child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(dateDay,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold))),
                            Text(dateMonth,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold))),
                            Text(dateYear,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold)))
                          ],
                        ),)
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top: 10),
              ),
              onTap: () => callDatePicker(),
            ),
            SizedBox(height: 10,),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                  color: Colors.blue.shade900,
                ),
                margin: EdgeInsets.symmetric(horizontal: 1),
                height: 35,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("DÖVİZ KURLARI",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w500))),
                    Text("(Tablodaki kurlar Mikro'dan alınmıştır)",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w500)))
                  ],
                )
            ),
            !loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) :
            Expanded(child: Container(
              margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
              child:  _grid(),
            ))
          ],
        )
      )
    );

  }

  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _dovizKurlariDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        columns: <GridColumn> [
          dreamColumn(columnName: 'kur',label : "KUR",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'alis',label : "ALIŞ",),
          dreamColumn(columnName: 'satis',label : "SATIŞ",),
          dreamColumn(columnName: 'efAlis',label : "EFEKTİF ALIŞ",minWidth: 100),
          dreamColumn(columnName: 'efSatis',label : "EFEKTİF SATIŞ",minWidth: 110),
          dreamColumn(columnName: 'tarih',label : "TARİH",),

        ],
        controller: this._dataGridController,
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }

  _dovizKurGetir() async {
    loading=false;
    if(!widget.userMi){
      UserInfo.fullAccess = false;
      UserInfo.activeUserId = 0;
    }
    dovizKurlariGridList.clear();
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/DovizKurlari?tarih=${secilenTarih}&FullAccess=${UserInfo.fullAccess}&"
          "Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 20));
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
        var kurDetay = jsonDecode(response.body);
        for(var kur in kurDetay){
          DovizKurlariGridModel gridDovizKurlari = new DovizKurlariGridModel(kur['kur'],kur['alis'],kur['satis'],
              kur['efAlis'],kur['efSatis'],DateTime.parse(kur['tarih']));
          dovizKurlariGridList.add(gridDovizKurlari);
        }
        loading = !loading;
        _dovizKurlariDataSource = DovizKurlariDataSource(_dataGridController);
      });
    }
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "TARİH SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: now,
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.from(colorScheme: ColorScheme.light(background: Colors.white,onSurface: Colors.black,primary: Colors.blue.shade900)),
          child: child!,
        );
      },
    );
  }
  void callDatePicker() async {
    var order = await getDate();
    if(order != null){
      setState(() {
        dateDay = order.day.toString();
        dateMonth = new DateFormat.MMMM('tr').format(order);
        dateYear = order.year.toString();
        secilenTarih = DateFormat('dd-MM-yyyy').format(order);
        now = order;
        _dovizKurGetir();
      });
    }
  }

}





class DovizKurlariDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = dovizKurlariGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'kur',value: e.kur),
          DataGridCell<double>(columnName: 'alis',value: e.alis),
          DataGridCell<double>(columnName: 'satis',value: e.satis),
          DataGridCell<double>(columnName: 'efAlis',value: e.efAlis),
          DataGridCell<double>(columnName: 'efSatis',value: e.efSatis),
          DataGridCell<DateTime>(columnName: 'tarih',value: e.tarih),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  DovizKurlariDataSource(this.dataGridController) {
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

