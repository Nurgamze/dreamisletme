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

import '../lojistik/Stoklar/StokDetaySayfasi.dart';

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

  bool active = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
    _alternatifleriGetir(-1);

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
                        hintText: "Depo adı veya Stok adı",
                        contentPadding: EdgeInsets.only(top: 15),
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
                height:55,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3,top: 0,bottom: 0),
                  child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Column(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                              child: Text("ALTERNATİFLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.left,)),
                          Align(
                            alignment: Alignment.centerLeft,
                              child: Text("${widget.data.stokKodu}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.left,maxLines: 1,)),
                        ],),
                      Switch(
                        value: active,
                           onChanged: (value){
                             setState(() {
                               active=value;
                               print("active:::: ${active}");
                               setState(() {
                                 active ? _alternatifleriGetir(0) : _alternatifleriGetir(-1);
                               });
                             });
                           },
                           activeTrackColor: Colors.white, //buton içi
                           activeColor: Colors.green,      //üstteki düğm
                         ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 90,
                              child: active ? Text("Stokta Olanlar",style: TextStyle(color: Colors.white,fontSize: 14),) : Text("Tüm Stoklar",style: TextStyle(color: Colors.white,fontSize: 14),)),
                        ),
                    ],
                  ),
                )
            ),
            Expanded(
                child: Container(
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
           dreamColumn(columnName: 'dep_adi', label: 'DEPO ADI',alignment: Alignment.centerLeft),
           dreamColumn(columnName: 'sto_kod', label: 'STOK KODU',alignment: Alignment.centerLeft),
           dreamColumn(columnName: 'sto_isim', label: 'STOK ADI',alignment: Alignment.centerLeft),
           dreamColumn(columnName: 'Miktar', label: 'MİKTAR',),

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
      if(stok.dep_adi!.toLowerCase().contains(_aramaController.text) || stok.sto_isim!.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(stok);
      }
    }
    setState(() {
      stokAlternatifleriGridList = arananlarList;
      _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
    });
  }


   void _alternatifleriGetir(int stokMiktar) async {

    print(widget.data.stokKodu);

    stokAlternatifleriGridList.clear();

    var response = await http.get(Uri.parse("${Sabitler.url}/api/StokAlternatifleri?VtIsim=${UserInfo.activeDB}&StokKodu=${widget.data.stokKodu}&StokMiktar=${stokMiktar}" ),
        headers: {"apiKey" : Sabitler.apiKey});

    if(response.statusCode == 200){

      var alternatiflerJson = jsonDecode(response.body);
      for(var alternatifler in alternatiflerJson) {

        StokAlternatifleriGridModel alternatif = StokAlternatifleriGridModel(
            alternatifler['dep_adi'],
            alternatifler['sto_kod'],
            alternatifler['sto_isim'],
            alternatifler['Miktar'],
        );
        setState((){
          stokAlternatifleriGridList.add(alternatif);
        });
      }
      setState(() {
        _stokAlternatifleriDataSource.updateDataGridSource();
        aramaList = stokAlternatifleriGridList;
        loading = true;
      });
    }else{
      setState(() {
        stokAlternatifleriGridList.clear();
        _stokAlternatifleriDataSource = StokAlternatifleriDataSource(dataGridController);
        loading = true;
      });
    }
  }



  _stokGit(String stokKodu) async {
    stokKodu=widget.data.stokKodu;
    print("VtIsim ${UserInfo.activeDB}");
    print("SubeNo ${UserInfo.aktifSubeNo}");
    print("Arama ${stokKodu.replaceAll("*", "%").replaceAll("\'", "\''")}");
    print("DevInfo ${TelefonBilgiler.userDeviceInfo}");
    print("AppVer ${TelefonBilgiler.userAppVersion}");
    print("UserId ${UserInfo.activeUserId}");


    showDialog(context: context, builder: (_) => DreamCogs());
    var body = jsonEncode({
      "VtIsim" : UserInfo.activeDB,
      "SubeNo" : UserInfo.aktifSubeNo,
      "Arama":stokKodu.replaceAll("*", "%").replaceAll("\'", "\''"),
      "AnaGrup":"",
      "AltGrup" : "",
      "Marka" : "",
      "Reyon" : "",
      "kategori" : "",
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
     // "uygulama":" "
    });

    var responseStok = await http.post(Uri.parse("${Sabitler.url}/api/StokV4"),
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
          stokDetay[0]['kategori'],  //kategorikodu eklendi
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
          stokDetay[0]['sdsSivas'],
          stokDetay[0]['sdsDenizli'],
          stokDetay[0]['sdsManisa'],
          stokDetay[0]['zenitled'],
          stokDetay[0]['zenitledUretim'],
          stokDetay[0]['zenitledMerkez'],
          stokDetay[0]['zenitledAdana'],
          stokDetay[0]['zenitledBursa'],
          stokDetay[0]['zenitledAntalya'],
          stokDetay[0]['zenitledAnkara'],
          stokDetay[0]['zenitledKonya'],
          stokDetay[0]['zenitledPerpa'],
          stokDetay[0]['zenitledETicaret'],
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
          stokDetay[0]['D1SdsSivas'],
          stokDetay[0]['D1SdsDenizli'],
          stokDetay[0]['D1SdsManisa'],
          stokDetay[0]['D1Zenitled'],
          stokDetay[0]['D1ZenitledUretim'],
          stokDetay[0]['D1ZenitledMerkez'],
          stokDetay[0]['D1ZenitledAdana'],
          stokDetay[0]['D1ZenitledBursa'],
          stokDetay[0]['D1ZenitledAntalya'],
          stokDetay[0]['D1ZenitledAnkara'],
          stokDetay[0]['D1ZenitledKonya'],
          stokDetay[0]['D1ZenitledPerpa'],
          stokDetay[0]['D1ZenitledETicaret'],
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
    print("build Datanın içindeyim");
    dataGridRows = stokAlternatifleriGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'dep_adi',value: e.dep_adi),
          DataGridCell<String>(columnName: 'sto_kod',value: e.sto_kod),
          DataGridCell<String>(columnName: 'sto_isim',value: e.sto_isim),
          DataGridCell<double>(columnName: 'Miktar',value: e.Miktar),
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
    buildDataGridRows();
    notifyListeners();
  }
}