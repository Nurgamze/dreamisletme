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
class StokSatisKarlilikRaporuSayfasi extends StatefulWidget {
  @override
  _StokSatisKarlilikRaporuSayfasiState createState() => _StokSatisKarlilikRaporuSayfasiState();
}

class _StokSatisKarlilikRaporuSayfasiState extends State<StokSatisKarlilikRaporuSayfasi> {

  bool loading = true;
  String secilenTarih1 = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String secilenTarih2= DateFormat('dd-MM-yyyy').format(DateTime.now());
  DateTime now = DateTime.now();
  String dateYear = DateTime.now().year.toString();
  String dateMonth = DateTime.now().month.toString();
  String dateDay = DateTime.now().day.toString();

  DataGridController _ciroTablosuController = DataGridController();
  late KarlilikRaporuDataSource _karlilikRaporuDataSource;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _karlilikRaporuDataSource = KarlilikRaporuDataSource(_ciroTablosuController);
    _karlilikRaporuGetir();
    AutoOrientation.fullAutoMode();
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
                          width: MediaQuery.of(context).size.width-80,
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
                            width: 50,
                            child: Center(
                                child: Icon(Icons.search,color: Colors.blue.shade900,)
                            )
                        ),
                        onTap: () => _karlilikRaporuGetir()
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
                  child: Center(child: Text("STOK SATIŞ KARLILIK RAPORU",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
              ),
              !loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) :
              Expanded(child: Container(
                margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                child: _grid(),
              ))
            ],
          ),
        ),
      )
    );
  }

  _grid() {
    return  SfDataGridTheme(
      data:myGridTheme,
      child: SfDataGrid(
        controller: this._ciroTablosuController,
        selectionMode: SelectionMode.single,
        source: _karlilikRaporuDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        columns: <GridColumn> [
          dreamColumn(columnName: 'tarih',label : "TARİH",alignment: Alignment.centerLeft,),
          dreamColumn(columnName: 'cariIsmi',label : "CARİ ÜNVAN",alignment: Alignment.centerLeft,),
          dreamColumn(columnName: 'stokAdi',label : "STOK ADI",alignment: Alignment.centerLeft,),
          dreamColumn(columnName: 'satisMiktar',label : "SATIŞ MİKTARI",),
          dreamColumn(columnName: 'satisBirimi',label : "SATIŞ BİRİMİ",),
          dreamColumn(columnName: 'dovizFiyati',label : "DÖVİZ FİYATI",),
          dreamColumn(columnName: 'dovizCinsi',label : "DÖVİZ CİNSİ",),
          dreamColumn(columnName: 'dovizKuru',label : "DÖVİZ KURU",),
          dreamColumn(columnName: 'satisTutari',label : "SATIŞ TUTARI",),
          dreamColumn(columnName: 'maliyet',label : "MALİYET",),
          dreamColumn(columnName: 'karTutar',label : "KAR TUTARI",),
          dreamColumn(columnName: 'karYuzde',label : "KAR YÜZDESİ",),
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
      setState(() {
        secilenTarih1 = DateFormat('dd-MM-yyyy').format(order);
        now = order;
        _karlilikRaporuGetir();
      });
    }
  }
  _karlilikRaporuGetir() async {
    setState(() {
      loading=false;
    });
    stokSatisKarlilikRaporuGridList.clear();
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/StokSatisKarlilikRaporu?"
          "tarih1=$secilenTarih1&"
          "vtName=${UserInfo.activeDB}&"
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
        var raporDetay = jsonDecode(response.body);
        for(var rapor in raporDetay){
          print(rapor);
          StokSatisKarlilikRaporuGridModel stokSatisKarlilikRaporuGridModel = new StokSatisKarlilikRaporuGridModel(rapor['Tarih'],rapor['CARI ISMI'],rapor['STOK AD'],rapor['SATIS MIKTAR'],
              rapor['SATIS BIRIMI'],rapor['DOVIZ FIYATI'],rapor['DOVIZ CINSI'],rapor['DOVIZ KURU'],rapor['SATIS TUTARI'],rapor['MALIYET'],rapor['KAR TUTAR'],rapor['KAR YUZDE']);
          stokSatisKarlilikRaporuGridList.add(stokSatisKarlilikRaporuGridModel);
        }
      });
    }
    setState(() {
      loading = true;
      _karlilikRaporuDataSource = KarlilikRaporuDataSource(_ciroTablosuController);
    });
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
}








class KarlilikRaporuDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = stokSatisKarlilikRaporuGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'tarih',value: e.tarih),
          DataGridCell<String>(columnName: 'cariIsmi',value: e.cariIsmi),
          DataGridCell<String>(columnName: 'stokAdi',value: e.stokAdi),
          DataGridCell<double>(columnName: 'satisMiktar',value: e.satisMiktar),
          DataGridCell<String>(columnName: 'satisBirimi',value: e.satisBirimi),
          DataGridCell<double>(columnName: 'dovizFiyati',value: e.dovizFiyati),
          DataGridCell<String>(columnName: 'dovizCinsi',value: e.dovizCinsi),
          DataGridCell<double>(columnName: 'dovizKuru',value: e.dovizKuru),
          DataGridCell<double>(columnName: 'satisTutari',value: e.satisTutari),
          DataGridCell<double>(columnName: 'maliyet',value: e.maliyet),
          DataGridCell<double>(columnName: 'karTutar',value: e.karTutar),
          DataGridCell<double>(columnName: 'karYuzde',value: e.karYuzde),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  KarlilikRaporuDataSource(this.dataGridController) {
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