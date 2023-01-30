import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sdsdream_flutter/modeller/Listeler.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'modeller/GridModeller.dart';
import 'modeller/Modeller.dart';
import 'widgets/HorizontalPage.dart';
import 'widgets/const_screen.dart';

class OnlineHesabimSayfasi extends StatefulWidget {
  @override
  _OnlineHesabimSayfasiState createState() => _OnlineHesabimSayfasiState();
}

class _OnlineHesabimSayfasiState extends State<OnlineHesabimSayfasi> {


  bool loading = true;
  final DataGridController _dataGridController = DataGridController();
  late OnlineHesabimDataSource _onlineHesabimDataSource = OnlineHesabimDataSource(_dataGridController);


  final dateFormat = new DateFormat('dd-MM-yyyy hh:mm');

  String gosterilenTarih1 = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String gosterilenTarih2= DateFormat('dd-MM-yyyy').format(DateTime.now());
  DateTime secilenTarih1 = DateTime.now();
  DateTime secilenTarih2 = DateTime.now();
  String dateYear = DateTime.now().year.toString();
  String dateMonth = DateTime.now().month.toString();
  String dateDay = DateTime.now().day.toString();

  List<Bankalar> _bankalarList = [];
  List<DropdownMenuItem<Bankalar>>? _dropdownMenuItems;
  Bankalar? _selectedItem;
  String banka = "";
  String bankaKodu = "";
  String bankaIban = "";
  String sonGuncelleme = "";
  double giren = 0.0;
  double cikan = 0.0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getBankalar();
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
    Color myBlue = Colors.blue.shade900;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid()) :Scaffold(
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: loading ? Container(child: Center(child: Image.asset("assets/images/dreamcogs.gif",width: MediaQuery.of(context).size.width/4,),),height: MediaQuery.of(context).size.height,) :
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 5,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButton<Bankalar>(
                      value: _selectedItem,
                      style: GoogleFonts.roboto(color: myBlue,fontWeight: FontWeight.w600),
                      isExpanded: true,
                      items: _dropdownMenuItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                          banka = value!.bankaIsmi;
                          bankaKodu = value.bankaKodu;
                          bankaIban = value.bankaIban;
                          sonGuncelleme = value.sonGuncelleme.toString();
                          _haraketleriGetir(bankaKodu);
                        });
                      },
                    ),
                    decoration: Sabitler.dreamBoxDecoration,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child:  Container(
                              decoration: Sabitler.dreamBoxDecoration,
                              margin: EdgeInsets.only(right: 1),
                              height: 40,
                              width: MediaQuery.of(context).size.width/2.2-15,
                              child: Center(
                                child:Text(gosterilenTarih1,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 19,color: Colors.blue.shade900,fontWeight: FontWeight.w500))),
                              )
                          ),
                          onTap: () => callDatePicker(1),
                        ),
                        InkWell(
                          child: Container(
                              decoration: Sabitler.dreamBoxDecoration,
                              margin: EdgeInsets.only(right: 1),
                              height: 40,
                              width: MediaQuery.of(context).size.width/2.2-15,
                              child: Center(
                                child:Text(gosterilenTarih2,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 18,color: Colors.blue.shade900,fontWeight: FontWeight.w500))),
                              )
                          ),
                          onTap: () => callDatePicker(2),
                        ),
                        InkWell(
                          child: Container(
                              decoration: Sabitler.dreamBoxDecoration,
                              margin: EdgeInsets.only(right: 1),
                              height: 40,
                              width: 40,
                              child: Center(
                                  child: Icon(Icons.search,color: Colors.blue.shade900,size: 26,)
                              )
                          ),
                          onTap: () {
                            _haraketleriGetir(bankaKodu);
                            print(onlineHesabimGridList.length);
                          },
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    child:  Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("IBAN  ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.w500))),
                              Icon(Icons.copy)
                            ],
                          ),
                          Text(bankaIban,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 17,color: myBlue,fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    onTap: () {
                      Clipboard.setData((new ClipboardData(text: bankaIban)));
                      Fluttertoast.showToast(
                          msg: "Banka IBAN panoya kopyalandı.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          textColor: Colors.white,
                          backgroundColor: Colors.black,
                          fontSize: 16.0
                      );
                    },
                  ),
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("BAKİYE",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500))),
                            Text(onlineHesabimGridList.isEmpty ? "0.00" : Foksiyonlar.formatMoney(onlineHesabimGridList[0].bakiye),style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: myBlue,fontWeight: FontWeight.w700))),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("GİREN",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500))),
                            Text(Foksiyonlar.formatMoney(giren),style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.green,fontWeight: FontWeight.w700))),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("ÇIKAN",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w500))),
                            Text(Foksiyonlar.formatMoney(cikan),style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16,color: Colors.red,fontWeight: FontWeight.w700))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
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
                          Text("BANKA HAREKETLERİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w500))),
                          Text("(SON GÜNCELLEME : ${dateFormat.format(DateTime.parse(sonGuncelleme))})",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.w500)))
                        ],
                      )
                  ),
                  Expanded(child: _grid(),)
                ],
              ),
            )
      )
    );
  }
  List<DropdownMenuItem<Bankalar>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<Bankalar>> items = [];
    for (Bankalar listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text("${listItem.bankaIsmi}\n${listItem.bankaKodu}"),
          value: listItem,
        ),
      );
    }
    return items;
  }
  Widget _grid() {
    return Container(
      margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
      child: SfDataGridTheme(
        data: myGridTheme,
        child: SfDataGrid(
          allowSorting: true,
          allowTriStateSorting: true,
          selectionMode: SelectionMode.none,
          source: _onlineHesabimDataSource,
          columnWidthMode: ColumnWidthMode.auto,
          columnSizer: customColumnSizer,
          gridLinesVisibility: GridLinesVisibility.vertical,
          headerGridLinesVisibility: GridLinesVisibility.vertical,
          headerRowHeight: 35,
          rowHeight: 35,
          columns: <GridColumn> [
            dreamColumn(columnName: 'tutar',label : "Tutar",),
            dreamColumn(columnName: 'bakiye',label : "Bakiye",),
            dreamColumn(columnName: 'aciklama',label : "Açıklama",alignment: Alignment.centerLeft),
            dreamColumn(columnName: 'gonderenIban',label : "Gönderen IBAN",),
            dreamColumn(columnName: 'gonderenVkn',label : "Gönderen VKN",),
            dreamColumn(columnName: 'cariUnvan',label : "Cari Ünvanı",),
            dreamColumn(columnName: 'islemTarihi',label : "İşlem Tarihi",),
          ],
          controller: this._dataGridController,
          onCellTap: (v) {
            Future.delayed(Duration(milliseconds: 50), () async{
              FocusScope.of(context).requestFocus(new FocusNode());
            });
          },
        ),
      ),
    );
  }
  _getBankalar() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/OnlineBankalar?userId=${UserInfo.activeUserId}&dbName=${UserInfo.activeDB}&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200) {
      var bankalar = jsonDecode(response.body);
      for(var banka in bankalar){
        print(banka);
        _bankalarList.add(Bankalar(banka["Banka Kodu"], banka["Banka İsmi"],banka['Banka IBAN'],DateTime.parse(banka['Son Güncelleme'].toString())));
      }
      if(_bankalarList.isEmpty){
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return BilgilendirmeDialog("Bu şubeye ait online banka bulunmamaktadır.");
            }).then((value) => Navigator.pop(context));
        
      }else{
        setState(() {
          _dropdownMenuItems = buildDropDownMenuItems(_bankalarList);
          _selectedItem = _dropdownMenuItems![0].value;
          banka = _dropdownMenuItems![0].value!.bankaIsmi;
          bankaKodu = _dropdownMenuItems![0].value!.bankaKodu;
          bankaIban = _dropdownMenuItems![0].value!.bankaIban;
          sonGuncelleme = _dropdownMenuItems![0].value!.sonGuncelleme.toString();
          loading =false;
          _haraketleriGetir(_dropdownMenuItems![0].value!.bankaKodu);
        });
      }

    }
  }

  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "TARİH SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: secilenTarih1,
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
          gosterilenTarih1 = DateFormat('dd-MM-yyyy').format(order);
          secilenTarih1 = order;
        });
      }else{
        setState(() {
          gosterilenTarih2 = DateFormat('dd-MM-yyyy').format(order);
          secilenTarih2 = order;
        });
      }
    }
  }

  _haraketleriGetir(String bankaKodu) async {
    secilenTarih1.toString().substring(0,10);
    setState(() {
      loading = true;
    });
    //print(DateTime.parse(secilenTarih1.toString().substring(0,10)).add(Duration(hours: 23,minutes: 59,seconds: 59)));
    print(DateTime.parse(secilenTarih2.toString().substring(0,10)).add(Duration(hours: 23,minutes: 59,seconds: 59)));
    onlineHesabimGridList.clear();
    giren = 0;
    cikan = 0;
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/OnlineBankaHaraketleri?"
          "ilkTarih=${DateTime.parse(secilenTarih1.toString().substring(0,10))}&"
          "sonTarih=${DateTime.parse(secilenTarih2.toString().substring(0,10)).add(Duration(hours: 23,minutes: 59,seconds: 59))}&"
          "bankaKodu=$bankaKodu&userId=${UserInfo.activeUserId}&dbName=${UserInfo.activeDB}&DevInfo=${TelefonBilgiler.userDeviceInfo}&"
          "AppVer=${TelefonBilgiler.userAppVersion}"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 30));
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
      var haraketler = jsonDecode(response.body);
      for(var hareket in haraketler){
        setState(() {
          onlineHesabimGridList.add(OnlineHesabimGridModel(hareket['Tutar'],hareket['Bakiye'],hareket['Açıklama'],hareket['Transfer Tipi'],hareket['Gönderen IBAN'],hareket['Gönderen VKN'],DateTime.parse(hareket['İşlem Tarihi'].toString()),hareket['Cari Kodu'],hareket['Cari Ünvan']));
        });
        if(hareket['Tutar'] < 0) {
          cikan += hareket['Tutar'];
        }else{
          giren += hareket['Tutar'];
        }
      }
      print(onlineHesabimGridList.length);
    }else{
    }
    setState(() {
      loading = !loading;
      _onlineHesabimDataSource = OnlineHesabimDataSource(_dataGridController);
    });
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
}




class OnlineHesabimDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = onlineHesabimGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<double>(columnName: 'tutar',value: e.tutar),
          DataGridCell<double>(columnName: 'bakiye',value: e.bakiye),
          DataGridCell<String>(columnName: 'aciklama',value: e.aciklama),
          DataGridCell<String>(columnName: 'gonderenIban',value: e.gonderenIban),
          DataGridCell<String>(columnName: 'gonderenVkn',value: e.gonderenVkn),
          DataGridCell<String>(columnName: 'cariUnvan',value: e.cariUnvan),
          DataGridCell<DateTime>(columnName: 'islemTarihi',value: e.islemTarihi),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  OnlineHesabimDataSource(this.dataGridController) {
    buildDataGridRows();
  }
  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    TextStyle getSelectionStyle() {
      if(dataGridController.selectedRows.contains(row)){
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }else{
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }
    }
    Color getRowBackGroundColor() {
      if(row.getCells()[0].value < 0){
        return Colors.red.shade900;
      }else{
        return Colors.green.shade700;
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
class Bankalar{

  String bankaKodu;
  String bankaIsmi;
  String bankaIban;
  DateTime sonGuncelleme;

  Bankalar(this.bankaKodu,this.bankaIsmi,this.bankaIban,this.sonGuncelleme);
}