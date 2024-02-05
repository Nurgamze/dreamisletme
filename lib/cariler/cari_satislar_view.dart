import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdsdream_flutter/cariler/models/cari_satislar.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/core/models/base_data_grid_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import '../Stoklar/StokDetaySayfasi.dart';
import '../core/services/api_service.dart';
import '../modeller/GridModeller.dart';

class CariSatislarView extends StatefulWidget {
  final cariKodu;
  final cariUnvan;
  CariSatislarView(this.cariKodu,this.cariUnvan);
  @override
  _CariSatislarViewState createState() => _CariSatislarViewState();
}



class _CariSatislarViewState extends State<CariSatislarView> {

  TextEditingController _aramaController = new TextEditingController();

  DataGridController dataGridController = DataGridController();
  late BaseDataGridSource _satislarDataSource;

  bool loading = false;
  List<CariSatislar> aramaList = [];
  
  List<CariSatislar> _cariSatislarList = [];

  List<StoklarGridModel> stoklarGridModel = [];

  late final List<StoklarGridModel> data;

  @override
  void initState() {
    _satislarDataSource = BaseDataGridSource(dataGridController,CariSatislar.buildDataGridRows(_cariSatislarList));
    // TODO: implement initState
    super.initState();
    _satislariGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cariSatislarList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid()) :
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
            Container(
              child: Column(
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
                            child: Center(child: FaIcon(FontAwesomeIcons.magnifyingGlass,color: Colors.blue.shade900,size: 18,),)
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
                          Text("NELER SATILMIŞ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                          Text("${widget.cariUnvan}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                        ],)
                  ),
                  Expanded(child:  Container(
                      margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                      child: _grid()
                  ))
                ],
              ),
            )
        )
    );
  }

  Widget _grid(){
    return  SfDataGridTheme(
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
        rowHeight: 35,
        controller: dataGridController,
        source: _satislarDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'stokKodu',  label:'STOK KODU',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'stokAdi',  label:'STOK ADI',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'tarih', label: "TARİH",),
          dreamColumn(columnName: 'miktar',  label:'MİKTAR',),
          dreamColumn(columnName: 'birim',  label:'BİRİM',),
          dreamColumn(columnName: 'birimFiyat', label:'BİRİM FİYAT',),
          dreamColumn(columnName: 'paraBirimi',  label:'PARA BİRİMİ',),
          dreamColumn(columnName: 'dovizBirimFiyat',  label:'DÖVİZ BİRİM FİYATI',),
          dreamColumn(columnName: 'doviz',  label:'DÖVİZ',),
          dreamColumn(columnName: 'kur',  label:'KUR',),
          dreamColumn(columnName: 'turu',  label:'TÜR',),
          dreamColumn(columnName: 'evrak',  label:'EVRAK',),
        ],

        //burada getiriyor ama içi çalışmıyor
        onCellTap: (value) async {
          Future.delayed(Duration(milliseconds: 10), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex > 0){
              print("if içindeyimmm ${value.rowColumnIndex.rowIndex}");
              var row = dataGridController.selectedRow!.getCells();
              print("row ? $row");
              setState(() {
                _stokGit(row[0].value.toString());
                print("setstate içinde ${row[0].value.toString()}");
              });
            }
          });
        },
      ),
    );
  }

  _satisAra() async {
    List<CariSatislar> arananlarList = [];
    for(var stok in aramaList){
      if(stok.stokKodu!.toLowerCase().contains(_aramaController.text) || stok.stokAdi!.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(stok);
      }
    }
    setState(() {
      _cariSatislarList = arananlarList;
      _satislarDataSource = BaseDataGridSource(dataGridController,CariSatislar.buildDataGridRows(_cariSatislarList));
    });
  }

  _satislariGetir() async {

    var queryParameters = {
      "VtIsim" : UserInfo.activeDB,
      "Customer" : false,
      "CariKodu" : widget.cariKodu,
      "Alislar" : false,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId,
    };

    var serviceData = await APIService.getDataWithModel<List<CariSatislar>,CariSatislar>("AlisSatislar", queryParameters, CariSatislar());
    if(serviceData?.statusCode == 200){
      _cariSatislarList = serviceData?.responseData ?? [];
      _satislarDataSource = BaseDataGridSource(dataGridController,CariSatislar.buildDataGridRows(_cariSatislarList));
      loading = true;
      aramaList = _cariSatislarList;
    }else{
      _cariSatislarList.clear();
      loading = true;
    }
    setState(() {});
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

    var responseStok = await http.post(Uri.parse( "${Sabitler.url}/api/StokV4"),
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
          stokDetay[0]['kategori'],
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
      print("hata var ");
    }
  }
}