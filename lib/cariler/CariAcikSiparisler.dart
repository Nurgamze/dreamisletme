import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
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
import '../Stoklar/StokDetaySayfasi.dart';
import 'models/cari.dart';



class CariAcikSiparislerSayfasi extends StatefulWidget {
  final DreamCari data;
  CariAcikSiparislerSayfasi({required this.data});
  @override
  _CariAcikSiparislerSayfasiState createState() => _CariAcikSiparislerSayfasiState();
}


class _CariAcikSiparislerSayfasiState extends State<CariAcikSiparislerSayfasi> {

  TextEditingController _aramaController = new TextEditingController();
  DataGridController dataGridController = DataGridController();
  late CariAcikSiparislerGridSource _cariAcikSiparislerGridSource;
  bool loading = false;
  List<AcikSiparislerGridModel> aramaList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cariAcikSiparislerGridSource = CariAcikSiparislerGridSource(dataGridController);
    _acikSiparisleriGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    acikSiparisGridList.clear();
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
                      margin: EdgeInsets.only(top: 5,left: 5,bottom: 0),
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
                        Text("AÇIK SİPARİŞLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                        Text("${widget.data.unvan}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
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
        controller: dataGridController,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        source: _cariAcikSiparislerGridSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'sipStokKod', label : 'STOK KODU',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'sipStokIsim',label : 'STOK ADI',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'sipCins', label : 'SİPARİŞ CİNSİ',),
          dreamColumn(columnName: 'sipTip', label : 'SİPARİŞ TİPİ',),
          dreamColumn(columnName: 'sipEvrakSeri',label : "EVRAK NO",),
          dreamColumn(columnName: 'kalan', label : 'KALAN',),
          dreamColumn(columnName: 'sipMiktar', label : 'SİPARİŞ MİKTARI',minWidth: 120),
          dreamColumn(columnName: 'sipTeslimMiktar', label : 'TESLİM MİKTARI',),
          dreamColumn(columnName: 'birim', label : 'BİRİM',),
          dreamColumn(columnName: 'birimFiyat', label : 'BİRİM FİYAT',),
          dreamColumn(columnName: 'dovizCinsi', label : 'DÖVİZ CİNSİ',),
          dreamColumn(columnName: 'tutar', label : 'TUTAR',),
        ],
          onCellTap: (value) {
          print("data gridiçine tıkladım");
            Future.delayed(Duration(milliseconds: 50), () {
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
          }
      ),
    );
  }



  _satisAra() async {
    List<AcikSiparislerGridModel> arananlarList = [];
    for(var siparis in aramaList){
      if(siparis.sipStokKod.toLowerCase().contains(_aramaController.text) || siparis.sipStokIsim.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(siparis);
      }
    }
    setState(() {
      acikSiparisGridList = arananlarList;
      _cariAcikSiparislerGridSource = CariAcikSiparislerGridSource(dataGridController);
    });
  }

  _acikSiparisleriGetir() async {
    print(widget.data);
    var response = await http.get(Uri.parse("${Sabitler.url}/api/AcikSiparisler?vtIsim=${UserInfo.activeDB}&cariKod=${widget.data.kod}&stokKod=&caridenMi=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey" : Sabitler.apiKey});
    print(response.statusCode);
    print(response.request);
    print(widget.data);
    if(response.statusCode == 200){
      var siparislerJson = jsonDecode(response.body);
      for(var siparisler in siparislerJson) {
        print(siparisler);
        AcikSiparislerGridModel siparis = AcikSiparislerGridModel(
            siparisler['sip_cins'],
            siparisler['sip_tip'],
            siparisler['sip_evrakno_seri'],
            siparisler['sip_evrakno_sira'],
            siparisler['sip_stok_kod'],
            siparisler['sto_isim'],
            siparisler['cari_unvan'],
            siparisler['sip_musteri_kod'],
            siparisler['sip_miktar'],
            siparisler['sip_teslim_miktar'],
            siparisler['kalan'],
            siparisler['tutar'],
            siparisler['birim'],
            siparisler['birimFiyat'],
            siparisler['dovizCinsi'],
            DateTime.parse(siparisler['sip_tarih'].toString()),
            DateTime.parse(siparisler['sip_teslim_tarih'].toString())

        );
        acikSiparisGridList.add(siparis);
      }
      if(acikSiparisGridList.length == 1) acikSiparisGridList.clear();
      if(acikSiparisGridList.length == 2){
        late AcikSiparislerGridModel first;
        late AcikSiparislerGridModel last;
        for(var data in acikSiparisGridList)
        {
          if(data.sipStokKod == "TOPLAM") last = data;
          else first = data;
        }
        List<AcikSiparislerGridModel> newList = [first,last];
        acikSiparisGridList = newList;

      }
      setState(() {
        loading = true;
        _cariAcikSiparislerGridSource = CariAcikSiparislerGridSource(dataGridController);
        aramaList = acikSiparisGridList;
      });
    }else{
      setState(() {
        acikSiparisGridList.clear();
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



class CariAcikSiparislerGridSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;


  final DataGridController dataGridController;
  CariAcikSiparislerGridSource(this.dataGridController) {
    buildDataGridRows();
  }
  void buildDataGridRows() {
    dataGridRows = acikSiparisGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'sipStokKod',value: e.sipStokKod),
          DataGridCell<String>(columnName: 'sipStokIsim',value: e.sipStokIsim),
          DataGridCell<int>(columnName: 'sipCins',value: e.sipCins),
          DataGridCell<int>(columnName: 'sipTip',value: e.sipTip),
          DataGridCell<String>(columnName: 'sipEvrakSeri',value: "${e.sipEvrakSeri}${e.sipEvrakSira}"),
          DataGridCell<double>(columnName: 'kalan',value: e.kalan),
          DataGridCell<double>(columnName: 'sipMiktar',value: e.sipMiktar),
          DataGridCell<double>(columnName: 'sipTeslimMiktar',value: e.sipTeslimMiktar),
          DataGridCell<String>(columnName: 'birim',value: e.birim),
          DataGridCell<double>(columnName: 'birimFiyat',value: e.birimFiyat),
          DataGridCell<String>(columnName: 'dovizCinsi',value: e.dovizCinsi),
          DataGridCell<double>(columnName: 'tutar',value: e.tutar),
        ]
    )).toList();
  }


  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    Color getRowBackGroundColor() {
      final int index = effectiveRows.indexOf(row);
      if(index %2 != 0){
        return Colors.grey.shade300;
      }else {
        return Colors.white;
      }
    }
    TextStyle getSelectionStyle() {
      if(dataGridController.selectedRows.contains(row)){
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }else{
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black));
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