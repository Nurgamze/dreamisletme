import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Listeler.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'StokDetaySayfasi.dart';

class StokAlternatifleriSayfasi extends StatefulWidget {
  final StoklarGridModel data;
  StokAlternatifleriSayfasi({required this.data});
  @override
  _StokAlternatifleriSayfasiState createState() => _StokAlternatifleriSayfasiState();
}

class _StokAlternatifleriSayfasiState extends State<StokAlternatifleriSayfasi> {

  TextEditingController _aramaController = new TextEditingController();

  DataGridController dataGridController = DataGridController();
  late StokAlternatifleriDataSource _stokAlternatifleriDataSource;

  bool loading = false;
  List<StokAlternatifleriGridModel> aramaList = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
    _alternatifleriGetir();

    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stokAlternatifleriGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid(),) :
      Scaffold(
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
        Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.only(top: 5,left: 5,bottom: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(3, 5),
                        ),
                      ],
                      color: Colors.white
                  ),
                  child: Center(child: TextFormField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                          onPressed: () {
                            _aramaController.text = "";
                            FocusScope.of(context).unfocus();
                            _satisAra();
                          },
                        )
                    ),
                    controller: _aramaController,
                    onChanged: (v) {
                      _satisAra();
                    },
                  ),),
                  width: MediaQuery.of(context).size.width * 6 / 7 - 10,
                  height: 50,
                ),
                InkWell(
                  child: Container(
                      margin: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(3, 5),
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width/7-5,
                      height: 50,
                      padding: EdgeInsets.all(5),
                      child: Center(child: FaIcon(FontAwesomeIcons.search,color: Colors.blue.shade900,size: 18,),)
                  ),
                  onTap: () async{
                    if(await Foksiyonlar.internetDurumu(context)){
                      _satisAra();
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 5,),
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
                    Text("ALTERNATİFLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                    Text("${widget.data.stokKodu}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                  ],)
            ),
            Expanded(child: Container(
              margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
              child: _grid(),
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
         controller: dataGridController,
         selectionMode: SelectionMode.single,
         allowSorting: true,
         allowTriStateSorting: true,
         columnWidthMode: ColumnWidthMode.auto,
         columnSizer: customColumnSizer,
         gridLinesVisibility: GridLinesVisibility.vertical,
         headerGridLinesVisibility: GridLinesVisibility.vertical,
         headerRowHeight: 35,
         rowHeight: 35,
         source: _stokAlternatifleriDataSource,
         columns: <GridColumn> [
           dreamColumn(columnName: 'stokKodu', label: 'STOK KODU',alignment: Alignment.centerLeft),
           dreamColumn(columnName: 'stokAdi', label: 'STOK ADI',alignment: Alignment.centerLeft),
           dreamColumn(columnName: 'miktar', label: 'MİKTAR',),
           dreamColumn(columnName: 'urunTipi', label: 'ÜRÜN TİPİ',),
           dreamColumn(columnName: 'ipRate', label: 'IP RATE',),
           dreamColumn(columnName: 'marka', label: 'MARKA',),
           dreamColumn(columnName: 'kasaTipi', label: 'KATA TİPİ',),
           dreamColumn(columnName: 'tip', label: 'TİP',),
           dreamColumn(columnName: 'ekOzellik', label: 'EK ÖZELLİK',),
           dreamColumn(columnName: 'sinifi', label: 'SINIFI',),
           dreamColumn(columnName: 'renk', label: 'RENK',),
           dreamColumn(columnName: 'ledSayisi', label: 'LED SAYISI',),
           dreamColumn(columnName: 'volt', label: 'VOLD',),
           dreamColumn(columnName: 'guc', label: 'GÜÇ',),
           dreamColumn(columnName: 'kelvin', label: 'KELVİN',),
           dreamColumn(columnName: 'akim', label: 'AKIM',),
           dreamColumn(columnName: 'garantiSuresi', label: 'GARANTİ SÜRESİ',),
           dreamColumn(columnName: 'satisPotansiyeli', label: 'SATIŞ POTANSİYELİ',),
           dreamColumn(columnName: 'aileKutugu', label: 'AİLE KÜTÜĞÜ',),
         ],
         onCellTap: (v) {
           Future.delayed(Duration(milliseconds: 50), () async{
             if(v.rowColumnIndex.rowIndex > 0){
               var row = dataGridController.selectedRow!.getCells();
               print(row[0].value.toString());
               if(row[0].value.toString() != widget.data.stokKodu) _stokGit(row[0].value.toString());
             }
             FocusScope.of(context).requestFocus(new FocusNode());
           });
         },
       ),
     );
  }

  _satisAra() async {
    List<StokAlternatifleriGridModel> arananlarList = [];
    for(var stok in aramaList){
      if(stok.stokKodu!.toLowerCase().contains(_aramaController.text) || stok.stokAdi!.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(stok);
      }
    }
    setState(() {
      stokAlternatifleriGridList = arananlarList;
      _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
    });
  }
  _alternatifleriGetir() async {
    print(widget.data.stokKodu);
    var response = await http.get(Uri.parse("${Sabitler.url}/api/StokAlternatifleri?VtIsim=${UserInfo.activeDB}&StokKodu=${widget.data.stokKodu}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
    print(response.body);
    if(response.statusCode == 200){
      print(response.body);
      var alternatiflerJson = jsonDecode(response.body);
      for(var alternatifler in alternatiflerJson) {
        StokAlternatifleriGridModel alternatif = StokAlternatifleriGridModel(alternatifler['stokKodu'], alternatifler['stokAdi'],alternatifler['miktar'], alternatifler['urunTipi'], alternatifler['ipRate'],
            alternatifler['marka'],alternatifler['kasaTipi'],alternatifler['tip'],alternatifler['ekOzellik'],alternatifler['sinifi'],alternatifler['renk'],alternatifler['ledSayisi'],alternatifler['volt'],
            alternatifler['guc'],alternatifler['kelvin'],alternatifler['akim'],alternatifler['garantiSuresi'],alternatifler['satisPotansiyeli'],alternatifler['aileKutugu']);
        print(alternatif);
        setState(() {
          stokAlternatifleriGridList.add(alternatif);
        });
      }
      setState(() {
        _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
        aramaList = stokAlternatifleriGridList;
        loading = true;
      });
    }else{
      setState(() {
        _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
        stokAlternatifleriGridList.clear();
        loading = true;
      });
    }
  }


  _stokGit(String stokKodu) async {
    showDialog(context: context, builder: (_) => DreamCogs());
    var body = jsonEncode({
      "VtIsim" : UserInfo.activeDB,
      "SubeNo" : UserInfo.aktifSubeNo,
      "Arama":stokKodu.replaceAll("*", "%").replaceAll("\'", "\''"),
      "AnaGrup":"",
      "AltGrup" : "",
      "Marka" : "",
      "Reyon" : "",
      "Mobile":true,
      "DevInfo":TelefonBilgiler.userDeviceInfo,
      "AppVer":TelefonBilgiler.userAppVersion,
      "UserId":UserInfo.activeUserId,
      "altGruplar": "",
      "anaGruplar": "",
      "markalar": "",
      "reyonlar": "",
      "ureticiler" : "",
      "ambalajlar" : "",
      "sektorler" : "",
      "kalitekontrol" : "",
      "modeller" : "",
      "sezonlar" : "",
      "hammaddeler" : "",
      "kategoriler" : "",
    });
    var responseStok = await http.post(Uri.parse(
        "${Sabitler.url}/api/StokV4"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body
    ).timeout(Duration(seconds: 40));
    Navigator.pop(context);
    if(responseStok.statusCode == 200) {
      var stokDetay = jsonDecode(responseStok.body);
      print(stokDetay[0]);
      StoklarGridModel stoklarGridModel = StoklarGridModel(
          stokDetay[0]['stokKodu'],
          stokDetay[0]['stokIsim'],
          stokDetay[0]['barKodu'],
          stokDetay[0]['kisaIsim'],
          stokDetay[0]['alternatifStokAdi'],
          stokDetay[0]['alternatifStokKodu'],
          stokDetay[0]['stokYabanciIsim'],
          stokDetay[0]['anaGrup'],
          stokDetay[0]['altGrup'],
          stokDetay[0]['marka'],
          stokDetay[0]['reyon'],
          stokDetay[0]['depo1StokMiktar'],
          stokDetay[0]['depo2StokMiktar'],
          stokDetay[0]['depo3StokMiktar'],
          stokDetay[0]['depo4StokMiktar'],
          stokDetay[0]['tumDepolarStokMiktar'],
          stokDetay[0]['stokBirim'],
          stokDetay[0]['fiyat'],
          stokDetay[0]['doviz'],
          stokDetay[0]['alinanSiparisKalan'],
          stokDetay[0]['verilenSiparisKalan'],
          stokDetay[0]['son30GunSatis'],
          stokDetay[0]['son3AyOrtalamaSatis'],
          stokDetay[0]['son6AyOrtalamaSatis'],
          stokDetay[0]['sdsToplamStokMerkezDahil'],
          stokDetay[0]['sdsMerkez'],
          stokDetay[0]['sdsizmir'],
          stokDetay[0]['sdsAdana'],
          stokDetay[0]['sdsAntalya'],
          stokDetay[0]['sdsSeyrantepe'],
          stokDetay[0]['sdsAnkara'],
          stokDetay[0]['sdsEurasia'],
          stokDetay[0]['sdsBursa'],
          stokDetay[0]['sdsAnadolu'],
          stokDetay[0]['sdsIzmit'],
          stokDetay[0]['sdsBodrum'],
          stokDetay[0]['sdsKayseri'],
          stokDetay[0]['zenitled'],
          stokDetay[0]['zenitledUretim'],
          stokDetay[0]['zenitledMerkez'],
          stokDetay[0]['zenitledAdana'],
          stokDetay[0]['zenitledBursa'],
          stokDetay[0]['zenitledAntalya'],
          stokDetay[0]['zenitledAnkara'],
          stokDetay[0]['zenitledKonya'],
          stokDetay[0]['D1SdsToplamStokMerkezDahil'],
          stokDetay[0]['D1SdsMerkez'],
          stokDetay[0]['D1SdsIzmir'],
          stokDetay[0]['D1SdsAdana'],
          stokDetay[0]['D1SdsAntalya'],
          stokDetay[0]['D1SdsSeyrantepe'],
          stokDetay[0]['D1SdsAnkara'],
          stokDetay[0]['D1SdsEurasia'],
          stokDetay[0]['D1SdsBursa'],
          stokDetay[0]['D1SdsAnadolu'],
          stokDetay[0]['D1SdsIzmit'],
          stokDetay[0]['D1SdsBodrum'],
          stokDetay[0]['D1SdsKayseri'],
          stokDetay[0]['D1Zenitled'],
          stokDetay[0]['D1ZenitledUretim'],
          stokDetay[0]['D1ZenitledMerkez'],
          stokDetay[0]['D1ZenitledAdana'],
          stokDetay[0]['D1ZenitledBursa'],
          stokDetay[0]['D1ZenitledAntalya'],
          stokDetay[0]['D1ZenitledAnkara'],
          stokDetay[0]['D1ZenitledKonya'],
          stokDetay[0]['stokAileKutugu']
      );
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => StokDetaySayfasi(data: stoklarGridModel,),
      ));
      return true;
    }else{
    }
  }
}





class StokAlternatifleriDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = stokAlternatifleriGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'stokKodu',value: e.stokKodu),
          DataGridCell<String>(columnName: 'stokAdi',value: e.stokAdi),
          DataGridCell<double>(columnName: 'miktar',value: e.miktar),
          DataGridCell<String>(columnName: 'urunTipi',value: e.urunTipi),
          DataGridCell<String>(columnName: 'ipRate',value: e.ipRate),
          DataGridCell<String>(columnName: 'marka',value: e.marka),
          DataGridCell<String>(columnName: 'kasaTipi',value: e.kasaTipi),
          DataGridCell<String>(columnName: 'tip',value: e.tip),
          DataGridCell<String>(columnName: 'ekOzellik',value: e.ekOzellik),
          DataGridCell<String>(columnName: 'sinifi',value: e.sinifi),
          DataGridCell<String>(columnName: 'renk',value: e.renk),
          DataGridCell<String>(columnName: 'ledSayisi',value: e.ledSayisi),
          DataGridCell<String>(columnName: 'volt',value: e.volt),
          DataGridCell<String>(columnName: 'guc',value: e.guc),
          DataGridCell<String>(columnName: 'kelvin',value: e.kelvin),
          DataGridCell<String>(columnName: 'akim',value: e.akim),
          DataGridCell<String>(columnName: 'garantiSuresi',value: e.garantiSuresi),
          DataGridCell<String>(columnName: 'satisPotansiyeli',value: e.satisPotansiyeli),
          DataGridCell<String>(columnName: 'aileKutugu',value: e.aileKutugu),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  StokAlternatifleriDataSource(this.dataGridController) {
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