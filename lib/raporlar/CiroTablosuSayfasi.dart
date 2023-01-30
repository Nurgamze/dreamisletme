import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../modeller/GridModeller.dart';
import '../modeller/Listeler.dart';
import '../modeller/Modeller.dart';
import '../widgets/Dialoglar.dart';
import '../widgets/DreamCogsGif.dart';
import '../widgets/HorizontalPage.dart';
class CiroTablosuSayfasi extends StatefulWidget {
  @override
  _CiroTablosuSayfasiState createState() => _CiroTablosuSayfasiState();
}


class _CiroTablosuSayfasiState extends State<CiroTablosuSayfasi> {

  bool loading = true;
  String secilenTarih1 = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String secilenTarih2= DateFormat('dd-MM-yyyy').format(DateTime.now());
  DateTime now = DateTime.now();
  String dateYear = DateTime.now().year.toString();
  String dateMonth = DateTime.now().month.toString();
  String dateDay = DateTime.now().day.toString();

  DataGridController _ciroTablosuController = DataGridController();
  late CiroTablosuDataSource _ciroTablosuDataSource;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ciroTablosuDataSource = CiroTablosuDataSource(_ciroTablosuController);
    AutoOrientation.fullAutoMode();
    _ciroTablosuGetir();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid(),) :
      Scaffold(
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child:  Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/2.2-25,
                          child: Center(
                            child:Text(secilenTarih1,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                          )
                      ),
                      onTap: () => callDatePicker(1),
                    ),
                    InkWell(
                      child: Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/2.2-25,
                          child: Center(
                            child:Text(secilenTarih2,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                          )
                      ),
                      onTap: () => callDatePicker(2),
                    ),
                    InkWell(
                        child: Container(
                            decoration: Sabitler.dreamBoxDecoration,
                            margin: EdgeInsets.only(right: 1),
                            height: 50,
                            width: 50,
                            child: Center(
                                child: Icon(Icons.search,color: Colors.blue.shade900,)
                            )
                        ),
                        onTap: () => _ciroTablosuGetir()
                    ),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.blue.shade900,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text("CİRO TABLOSU",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
              ),
              !loading ? Expanded(child: DreamCogs(),) :
              Expanded(child: Container(
                margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                child:  _grid(),
              ))
            ],
          ),
        ),
      )
    );

  }


  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        source: _ciroTablosuDataSource,
        selectionMode: SelectionMode.single,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        controller: this._ciroTablosuController,
        columns: <GridColumn> [
          dreamColumn(columnName: 'vtKod',label : "VT KODU",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'sube',label : "ŞUBE",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'ciroBuAy',label : "BU AY TOPLAM",),
          dreamColumn(columnName: 'ciroGecenYil',label : "CİRO GEÇEN YIL",),
          dreamColumn(columnName: 'ciroBuYil',label : "CİRO BU YIL",),
          dreamColumn(columnName: 'iskonto',label : "İSKONTO",),
          dreamColumn(columnName: 'irsaliyeSayisi',label : "İRSALİYE SAYISI",),
          dreamColumn(columnName: 'musteriSayisi',label : "MÜŞTERİ SAYISI",),
          dreamColumn(columnName: 'irsaliyeOrtalamasi',label : "İRSALİYE ORTALAMASI",),
          dreamColumn(columnName: 'nakit',label : "NAKİT",),
          dreamColumn(columnName: 'cek',label : "ÇEK",),
          dreamColumn(columnName: 'senet',label : "SENET",),
          dreamColumn(columnName: 'toplamTahsilat',label : "TOPLAM TAHSİLAT",),

        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
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
  void callDatePicker(int secilenTarih) async {
    var order = await getDate();
    if(order != null){
      if(secilenTarih == 1) {
        setState(() {
          secilenTarih1 = DateFormat('dd-MM-yyyy').format(order);
          now = order;
        });
      }else{
        setState(() {
          secilenTarih2 = DateFormat('dd-MM-yyyy').format(order);
          now = order;
        });
      }
    }
  }
  _ciroTablosuGetir() async {
    setState(() {
      loading=false;
    });
    ciroTablosuGridList.clear();
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/CiroDream?"
          "tarih1=$secilenTarih1&"
          "tarih2=$secilenTarih2&"
          "FullAccess=${UserInfo.fullAccess}&"
          "Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&"
          "AppVer=${TelefonBilgiler.userAppVersion}&"
          "UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 30));
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
    print(response.statusCode);
    print(response.body);
    print(secilenTarih1);
    print(secilenTarih2);
    if(response.statusCode == 200) {
      setState(() {
        var ciroDetay = jsonDecode(response.body);
        for(var ciro in ciroDetay){
          CiroTablosuGridModel ciroTablosuGridModel = new CiroTablosuGridModel.fromMap(ciro);
          ciroTablosuGridList.add(ciroTablosuGridModel);
        }
      });
    }
    setState(() {
      loading = true;
      _ciroTablosuDataSource = CiroTablosuDataSource(_ciroTablosuController);
    });
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
}




class CiroTablosuDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = ciroTablosuGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'vtKod',value: e.vtKod),
          DataGridCell<String>(columnName: 'sube',value: e.sube),
          DataGridCell<double>(columnName: 'ciroBuAy',value: e.ciroBuAy),
          DataGridCell<double>(columnName: 'ciroGecenYil',value: e.ciroGecenYil),
          DataGridCell<double>(columnName: 'ciroBuYil',value: e.ciroBuYil),
          DataGridCell<double>(columnName: 'iskonto',value: e.iskonto),
          DataGridCell<int>(columnName: 'irsaliyeSayisi',value: e.irsaliyeSayisi),
          DataGridCell<int>(columnName: 'musteriSayisi',value: e.musteriSayisi),
          DataGridCell<String>(columnName: 'irsaliyeOrtalamasi',value: e.irsaliyeOrtalamasi),
          DataGridCell<double>(columnName: 'nakit',value: e.nakit),
          DataGridCell<double>(columnName: 'cek',value: e.cek),
          DataGridCell<double>(columnName: 'senet',value: e.senet),
          DataGridCell<double>(columnName: 'toplamTahsilat',value: e.toplamTahsilat),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  CiroTablosuDataSource(this.dataGridController) {
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