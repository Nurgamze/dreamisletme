import 'dart:async';
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Listeler.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'StokDetaySayfasi.dart';
class StoklarSayfasi extends StatefulWidget {
  @override
  _StoklarSayfasiState createState() => _StoklarSayfasiState();
}

class _StoklarSayfasiState extends State<StoklarSayfasi> {


  bool loading = true;
  TextEditingController _stokAramaController = new TextEditingController();
  String arananKelime = "";
  bool grupFiltreMi = false;


  bool filtreMarkalarMi = false;
  bool filtreReyonlarMi = false;
  bool filtreUreticilerMi = false;
  bool filtreAmbalajlarMi = false;
  bool filtreSektorlerMi = false;
  bool filtreKalitekontrolMi = false;
  bool filtreModellerMi = false;
  bool filtreSezonlarMi = false;
  bool filtreHammaddelerMi = false;
  bool filtreKategorilerMi = false;

  String gidecekAnaGruplar = "";
  String gidecekAltGruplar = "";
  String gidecekMarkalar = "";
  String gidecekReyonlar = "";
  String gidecekUreticiler = "";
  String gidecekAmbalajlar = "";
  String gidecekSektorler = "";
  String gidecekKalitekontrol = "";
  String gidecekModeller = "";
  String gidecekSezonlar = "";
  String gidecekHammaddeler = "";
  String gidecekKategoriler = "";


  List<String> aramaHelperList = [];

  List<String?> _filtreler = [];
  List<String?> filtreMarkalarList = [];
  List<String?> filtreReyonlarList = [];
  List<String?> filtreUreticilerList = [];
  List<String?> filtreAmbalajlarList = [];
  List<String?> filtreSektorlerList = [];
  List<String?> filtreKalitekontrolList = [];
  List<String?> filtreModellerList = [];
  List<String?> filtreSezonlarList = [];
  List<String?> filtreHammaddelerList = [];
  List<String?> filtreKategorilerList = [];
  
  
  final DataGridController _dataGridController = DataGridController();
  late StoklarDataSource _stoklarDataSource;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stoklarDataSource = StoklarDataSource(_dataGridController);
    _stokAutoComplateGetir();
    AutoOrientation.fullAutoMode();
    filtreSecMarkalarList.clear();
    filtreSecReyonlarList.clear();
    filtreSecUreticilerList.clear();
    filtreSecAmbalajlarList.clear();
    filtreSecSektorlerList.clear();
    filtreSecKalitekontrolList.clear();
    filtreSecModellerList.clear();
    filtreSecSezonlarList.clear();
    filtreSecHammaddelerList.clear();
    filtreSecKategorilerList.clear();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stoklarGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: OrientationBuilder(
        builder: (context,currentOrientation){
          if(currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet){
            return HorizontalPage(_grid(),);
          }else{
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Container(
                    child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
                ),
                centerTitle: true,
                backgroundColor: Colors.blue.shade900,
                actions: [
                  IconButton(
                      icon: FaIcon(FontAwesomeIcons.camera),
                      onPressed: () {
                        scanBarcodeNormal();
                      }
                  ),
                  filtreMarkalarMi || filtreReyonlarMi || filtreUreticilerMi || filtreAmbalajlarMi || filtreSektorlerMi || filtreKalitekontrolMi || filtreModellerMi || filtreSezonlarMi || filtreHammaddelerMi || filtreKategorilerMi ||  grupFiltreMi ? Badge(
                    position: BadgePosition.topEnd(top: 0, end: 5),
                    badgeColor: Colors.red,
                    badgeContent: Text("${_filtreler.length + filtreMarkalarList.length + filtreReyonlarList.length +
                        filtreUreticilerList.length + filtreAmbalajlarList.length +
                        filtreSektorlerList.length + filtreKalitekontrolList.length +
                        filtreModellerList.length + filtreSezonlarList.length + filtreHammaddelerList.length +
                        filtreKategorilerList.length }",style: TextStyle(color: Colors.white)),
                    child: IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: ()async {
                      if(filtreSecMarkalarList.isEmpty){
                        showDialog(context: context,builder: (conxtext) => Center(child:  CircularProgressIndicator(),));
                        await _filtreGetir();
                        Navigator.pop(context);
                      }
                      showDialog(context: context,builder: (context) => _filtreDialog());
                    }),
                  )
                      : IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: () async {
                    if(filtreSecMarkalarList.isEmpty){
                      showDialog(context: context,builder: (conxtext) => Center(child:  CircularProgressIndicator(),));
                      await _filtreGetir();
                      Navigator.pop(context);
                    }
                    showDialog(context: context,builder: (context) => _filtreDialog());
                  }
                  ),
                ],
              ),
              body: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5,left: 10),
                        margin: EdgeInsets.only(top: 10,left: 5,bottom: 5),
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
                        width: MediaQuery.of(context).size.width -70,
                        height: 60,
                        child: TypeAheadFormField(
                          hideOnLoading: true,
                          textFieldConfiguration: TextFieldConfiguration(
                            onSubmitted: (value) async {
                              if(await Foksiyonlar.internetDurumu(context)){
                                setState(() {
                                  loading = false;
                                  arananKelime = _stokAramaController.text;
                                });
                                stoklarGridList = [];
                                _stoklariGetir(false);
                              }
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            decoration: InputDecoration(
                                hintText:
                                'Stok arayın',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                                  onPressed: () {
                                    //_dataGridController.selectedRow = null;
                                    _stokAramaController.text = "";
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                            ),
                            controller: this._stokAramaController,
                          ),
                          suggestionsCallback: (pattern) {
                            arananKelime = pattern;
                            if(pattern == "")
                              return [];
                            return getSuggestions(pattern);
                          },
                          noItemsFoundBuilder: (context) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              height: 40,
                              child: Center(
                                child: Text(
                                  "Sonuç bulunamadı",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            );
                          },
                          itemBuilder: (context, suggestion) {
                            if (arananKelime != "") {
                              var mySuggestion = suggestion
                                  .toString()
                                  .replaceAll(arananKelime.toUpperCase(), '=');
                              for (var i = 0; i < mySuggestion.toString().length; i++) {
                                aramaHelperList.add(mySuggestion[i]);
                              }
                            }
                            return ListTile(
                                title: RichText(
                                  text: TextSpan(
                                      children: List.generate(
                                          aramaHelperList.length, (index) {
                                        if (arananKelime != "") {
                                          String lastChar;
                                          if (aramaHelperList[index]
                                              .toString()
                                              .toLowerCase() ==
                                              "=") {
                                            if (aramaHelperList.length - 1 == index) {
                                              lastChar = arananKelime.toUpperCase();
                                              aramaHelperList.clear();
                                              return TextSpan(
                                                  text: lastChar,
                                                  style: TextStyle(color: Colors.red));
                                            }
                                            return TextSpan(
                                                text: arananKelime.toUpperCase(),
                                                style: TextStyle(color: Colors.red));
                                          }
                                          if (aramaHelperList.length - 1 == index) {
                                            lastChar = aramaHelperList[index];
                                            aramaHelperList.clear();
                                            return TextSpan(
                                                text: lastChar,
                                                style: TextStyle(color: Colors.black));
                                          }
                                          return TextSpan(
                                              text: aramaHelperList[index],
                                              style: TextStyle(color: Colors.black));
                                        } else {
                                          return TextSpan(text: "");
                                        }
                                      })),
                                ));
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) async {
                            this._stokAramaController.text = suggestion.toString();
                            if(await Foksiyonlar.internetDurumu(context)){
                              setState(() {
                                arananKelime = _stokAramaController.text;
                              });
                              stoklarGridList = [];
                              _stoklariGetir(false);
                            }
                          },
                          onSaved: (value) => this._stokAramaController.text = value!,
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
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
                              width: 55,
                              height: 60,
                              padding: EdgeInsets.all(5),
                              child: Center(child: FaIcon(FontAwesomeIcons.search,color: Colors.blue.shade900,size: 18,),)
                          ),
                        ),
                        onTap: () async{
                          if(await Foksiyonlar.internetDurumu(context)){
                            setState(() {
                              loading = false;
                              if(_filtreler.isEmpty){
                                gidecekAltGruplar = "";
                                gidecekAnaGruplar = "";
                                setState(() {
                                  grupFiltreMi = false;
                                });
                              }else{
                                String anaGruplar = "";
                                String altGruplar = "";
                                var secilenFilteler = _filtreler;

                                if(secilenFilteler.length >0){
                                  for(var a in secilenFilteler){
                                    var anaAlt = a!.split(";");
                                    anaGruplar += ''''${anaAlt[0]}',''';
                                    altGruplar += ''''${anaAlt[1]}',''';
                                  }
                                  anaGruplar = anaGruplar.substring(0,anaGruplar.length-1);
                                  altGruplar = altGruplar.substring(0,altGruplar.length-1);
                                }
                                gidecekAltGruplar = altGruplar;
                                gidecekAnaGruplar = anaGruplar;
                                setState(() {
                                  grupFiltreMi = true;
                                });
                              }
                              if(filtreMarkalarList.isEmpty){
                                gidecekMarkalar = "";
                                setState(() {
                                  filtreMarkalarMi = false;
                                });
                              }else{
                                String markalar = "";
                                var secilenFilteler = filtreMarkalarList;
                                if(secilenFilteler.length >0){
                                  for(var a in secilenFilteler){
                                    markalar += ''''$a',''';
                                  }
                                }
                                markalar.length > 0 ? markalar = markalar.substring(0,markalar.length-1) : markalar = "";
                                gidecekMarkalar = markalar;
                                setState(() {
                                  loading = false;
                                  filtreMarkalarMi = true;
                                });
                              }
                              if(_stokAramaController.text == ""){
                                arananKelime = "*";
                              }else{
                                arananKelime = _stokAramaController.text;
                              }
                            });
                            stoklarGridList = [];
                            _stoklariGetir(false);
                          }
                          FocusScope.of(context).requestFocus(new FocusNode());
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
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text("STOKLAR",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                  ),
                  !loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) :
                  Expanded(child: Container(
                    margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                    child: _grid(),
                  ),)
                ],
              ),
            );
          }
        },
      )
    );

  }
  Widget _grid() {
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: Color.fromRGBO(235, 90, 12, 1),
        sortIconColor: Colors.white,
      ),
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
        source: _stoklarDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'stokKodu', label: "STOK KODU",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'stokIsim', label: "STOK ADI",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'stokYabanciIsim', label: "STOK YABANCI ADI",alignment: Alignment.centerLeft,visible: UserInfo.activeDB == "MikroDB_V16_12" ? true : false),
          dreamColumn(columnName: 'musait', label: 'MÜSAİT (DEPO1-SİPARİŞ)',minWidth: 200),
          dreamColumn(columnName: 'tumDepolarStokMiktar', label: 'TÜM DEPOLAR STOK MİKTAR'),
          dreamColumn(columnName: 'depo1StokMiktar', label: 'DEPO 1 STOK MİKTAR'),
          dreamColumn(columnName: 'depo2StokMiktar', label: 'DEPO 2 STOK MİKTAR'),
          dreamColumn(columnName: 'depo3StokMiktar', label: 'DEPO 3 STOK MİKTAR'),
          dreamColumn(columnName: 'depo4StokMiktar', label: 'DEPO 4 STOK MİKTAR'),
          dreamColumn(columnName: 'merkez', label: UserInfo.activeDB == "MikroDB_V16_12" ? 'LOJİSTİK' : 'MERKEZ'),
          dreamColumn(columnName: 'alinanSiparisKalan', label: 'ALINAN SİPARİŞ'),
          dreamColumn(columnName: 'verilenSiparisKalan', label: 'VERİLAN SİPARİŞ'),
          dreamColumn(columnName: 'stokAileKutugu', label: 'STOK AİLE KÜTÜĞÜ'),
          dreamColumn(columnName: 'marka', label: 'MARKA'),
          dreamColumn(columnName: 'reyon', label: 'REYON'),
          dreamColumn(columnName: 'stokBirim', label: 'BİRİM'),
          dreamColumn(columnName: 'fiyat', label: "FİYAT"),
          dreamColumn(columnName: 'doviz', label: "DÖVİZ"),
          dreamColumn(columnName: 'kisaIsim', label: 'KISA ADI'),
          dreamColumn(columnName: 'anaGrup', label: 'ANA GRUP'),
          dreamColumn(columnName: 'altGrup', label: 'ALT GRUP'),
          dreamColumn(columnName: 'alternatifStokKodu', label: "İLK ALTERNATİF STOK KODU",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'alternatifStokIsim', label: "İLK ALTERNATİF STOK ADI",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'barKodu', label: "BARKODU"),

        ],
        controller: this._dataGridController,
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), (){
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex >0){
              var row = _dataGridController.selectedRow!.getCells();
              StoklarGridModel stok = stoklarGridList.where((e) => e.stokKodu == row[0].value.toString()).first;
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => StokDetaySayfasi(data: stok,),
              ));
              _dataGridController.selectedIndex = -1;
            }
          });
        },
      ),
    );
  }

  Widget _filtreDialog(){
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 440,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  child: SmartSelect<String?>.multiple(
                      modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Ana Grup/Alt Grup',
                      placeholder: 'Stok Filtrele',
                      selectedValue: _filtreler,
                      onChange: (state) => setState(() => _filtreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: filtreList,
                        value: (index, item) => item['sta_ana_grup_kod']+";"+item['sta_kod'],
                        title: (index, item) => item['sta_kod'],
                        group: (index, item) => item['sta_ana_grup_kod'],
                      ),
                      modalFooterBuilder: (context,v) {
                        return Row(
                          children: [
                            InkWell(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width/2,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(2, 5),
                                      ),
                                    ],
                                    color: Colors.red
                                ),
                                child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                              ),
                              onTap: () async {
                                v.selection!.clear();
                                gidecekAnaGruplar = "";
                                gidecekAltGruplar = "";
                                Fluttertoast.showToast(
                                    msg: "Filtreler temizlendi.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 16.0
                                );
                                setState(() {
                                  grupFiltreMi = false;
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width/2,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(2, 5),
                                      ),
                                    ],
                                    color: Colors.grey.shade500
                                ),
                                child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                              ),
                              onTap: () async {
                                String anaGruplar = "";
                                String altGruplar = "";
                                v.onChange();
                                if(_filtreler.length >0){
                                  for(var a in _filtreler){
                                    var anaAlt = a!.split(";");
                                    anaGruplar += ''''${anaAlt[0]}',''';
                                    altGruplar += ''''${anaAlt[1]}',''';
                                  }
                                }
                                anaGruplar.length > 0 ? anaGruplar = anaGruplar.substring(0,anaGruplar.length-1) : anaGruplar = "";
                                altGruplar.length > 0 ? altGruplar = altGruplar.substring(0,altGruplar.length-1) : altGruplar = "";
                                gidecekAltGruplar = altGruplar;
                                gidecekAnaGruplar = anaGruplar;
                                setState(() {
                                  loading = false;
                                  if(_filtreler.isEmpty) grupFiltreMi = false;
                                  else grupFiltreMi = true;
                                });
                                v.closeModal();
                                Navigator.pop(context);
                                await _stoklariGetir(false);
                              },
                            )
                          ],
                        );
                      },
                      groupHeaderBuilder: (context,s,v) {
                        return Container(
                          height: 40,
                            width: double.infinity,
                            color: Colors.blueGrey,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 15,right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${v.name}",style: TextStyle(color: Colors.white),),
                                Text("${v.choices!.length}",style: TextStyle(color: Colors.white),)
                              ],
                            )
                        );
                      },
                      choiceGrouped: true,
                      modalFilter: true,
                      modalType: S2ModalType.fullPage,
                      modalFilterAuto: true,
                      choiceEmptyBuilder: (context,s){
                        return const Center(
                          child: Text("STOK FİLTRESİ BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if(grupFiltreMi){
                          return Badge(
                            position: BadgePosition.topEnd(top: 5, end: 20),
                            badgeColor: Colors.red,
                            badgeContent: Text("${_filtreler.length}",style: TextStyle(color: Colors.white)),
                            child: InkWell(
                                child: Container(child: Center(child: Text("Ana Grup/Alt Grup",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
                                onTap: () async {
                                  state.showModal();
                                }
                            ),
                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Ana Grup/Alt Grup",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
                              onTap: () async {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:     SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Marka',
                        placeholder: 'Stok Filtrele',
                        selectedValue: filtreMarkalarList,
                        onChange: (state) => setState(() => filtreMarkalarList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecMarkalarList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekMarkalar = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreMarkalarMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String markalar = "";
                                  v.onChange();
                                  if(filtreMarkalarList.length >0){
                                    for(var a in filtreMarkalarList){
                                      markalar += ''''$a',''';
                                    }
                                  }
                                  markalar.length > 0 ? markalar = markalar.substring(0,markalar.length-1) : markalar = "";
                                  gidecekMarkalar = markalar;
                                  setState(() {
                                    loading = false;
                                    if(filtreMarkalarList.isEmpty) filtreMarkalarMi = false;
                                    else filtreMarkalarMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreMarkalarMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreMarkalarList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Marka",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () async {
                                    state.showModal();


                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Marka",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () async {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Reyon',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreReyonlarList,
                        onChange: (state) => setState(() => filtreReyonlarList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecReyonlarList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekReyonlar = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreReyonlarMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String reyonlar = "";
                                  v.onChange();
                                  if(filtreReyonlarList.length >0){
                                    for(var a in filtreReyonlarList){
                                      reyonlar += ''''$a',''';
                                    }
                                  }
                                  reyonlar.length > 0 ? reyonlar = reyonlar.substring(0,reyonlar.length-1) : reyonlar = "";
                                  gidecekReyonlar = reyonlar;
                                  setState(() {
                                    loading = false;
                                    if(filtreReyonlarList.isEmpty) filtreReyonlarMi = false;
                                    else filtreReyonlarMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreReyonlarMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreReyonlarList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Reyon",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Reyon",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Üreticiler',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreUreticilerList,
                        onChange: (state) => setState(() => filtreUreticilerList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecUreticilerList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekUreticiler = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreUreticilerMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String ureticiler = "";
                                  v.onChange();
                                  if(filtreUreticilerList.length >0){
                                    for(var a in filtreUreticilerList){
                                      ureticiler += ''''$a',''';
                                    }
                                  }
                                  ureticiler.length > 0 ? ureticiler = ureticiler.substring(0,ureticiler.length-1) : ureticiler = "";
                                  gidecekUreticiler = ureticiler;
                                  setState(() {
                                    loading = false;
                                    if(filtreUreticilerList.isEmpty) filtreUreticilerMi = false;
                                    else filtreUreticilerMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreUreticilerMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreUreticilerList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Üretici",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Üretici",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Ambalajlar',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreAmbalajlarList,
                        onChange: (state) => setState(() => filtreAmbalajlarList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecAmbalajlarList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekAmbalajlar = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreAmbalajlarMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String ambalajlar = "";
                                  v.onChange();
                                  if(filtreAmbalajlarList.length >0){
                                    for(var a in filtreAmbalajlarList){
                                      ambalajlar += ''''$a',''';
                                    }
                                  }
                                  ambalajlar.length > 0 ? ambalajlar = ambalajlar.substring(0,ambalajlar.length-1) : ambalajlar = "";
                                  gidecekAmbalajlar = ambalajlar;
                                  setState(() {
                                    loading = false;
                                    if(filtreAmbalajlarList.isEmpty) filtreAmbalajlarMi = false;
                                    else filtreAmbalajlarMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreAmbalajlarMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreAmbalajlarList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Ambalaj",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Ambalaj",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Sektörler',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreSektorlerList,
                        onChange: (state) => setState(() => filtreSektorlerList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecSektorlerList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekSektorler = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreSektorlerMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String sektorler = "";
                                  v.onChange();
                                  if(filtreSektorlerList.length >0){
                                    for(var a in filtreSektorlerList){
                                      sektorler += ''''$a',''';
                                    }
                                  }
                                  sektorler.length > 0 ? sektorler = sektorler.substring(0,sektorler.length-1) : sektorler = "";
                                  gidecekSektorler = sektorler;
                                  setState(() {
                                    loading = false;
                                    if(filtreSektorlerList.isEmpty) filtreSektorlerMi = false;
                                    else filtreSektorlerMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreSektorlerMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreSektorlerList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Sektör",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Sektör",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Kalite Kontrol Tanımları',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreKalitekontrolList,
                        onChange: (state) => setState(() => filtreKalitekontrolList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecKalitekontrolList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekKalitekontrol = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreKalitekontrolMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String kaliteKontrol = "";
                                  v.onChange();
                                  if(filtreKalitekontrolList.length >0){
                                    for(var a in filtreKalitekontrolList){
                                      kaliteKontrol += ''''$a',''';
                                    }
                                  }
                                  kaliteKontrol.length > 0 ? kaliteKontrol = kaliteKontrol.substring(0,kaliteKontrol.length-1) : kaliteKontrol = "";
                                  gidecekKalitekontrol = kaliteKontrol;
                                  setState(() {
                                    loading = false;
                                    if(filtreKalitekontrolList.isEmpty) filtreKalitekontrolMi = false;
                                    else filtreKalitekontrolMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreKalitekontrolMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreKalitekontrolList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Kalite Kontrol",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Kalite Kontrol",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Modeller',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreModellerList,
                        onChange: (state) => setState(() => filtreModellerList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecModellerList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekModeller = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreModellerMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String modeller = "";
                                  v.onChange();
                                  if(filtreModellerList.length >0){
                                    for(var a in filtreModellerList){
                                      modeller += ''''$a',''';
                                    }
                                  }
                                  modeller.length > 0 ? modeller = modeller.substring(0,modeller.length-1) : modeller = "";
                                  gidecekModeller = modeller;
                                  setState(() {
                                    loading = false;
                                    if(filtreModellerList.isEmpty) filtreModellerMi = false;
                                    else filtreModellerMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreModellerMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreModellerList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Model",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Model",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Sezonlar',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreSezonlarList,
                        onChange: (state) => setState(() => filtreSezonlarList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecSezonlarList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekSezonlar= "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreSezonlarMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String sezonlar = "";
                                  v.onChange();
                                  if(filtreSezonlarList.length >0){
                                    for(var a in filtreSezonlarList){
                                      sezonlar += ''''$a',''';
                                    }
                                  }
                                  sezonlar.length > 0 ? sezonlar = sezonlar.substring(0,sezonlar.length-1) : sezonlar = "";
                                 gidecekSezonlar = sezonlar;
                                  setState(() {
                                    loading = false;
                                    if(filtreSezonlarList.isEmpty) filtreSezonlarMi = false;
                                    else filtreSezonlarMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreSezonlarMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreSezonlarList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Sezon",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Sezon",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Hammaddeler',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreHammaddelerList,
                        onChange: (state) => setState(() => filtreHammaddelerList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecHammaddelerList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekHammaddeler = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreHammaddelerMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String hammaddeler = "";
                                  v.onChange();
                                  if(filtreHammaddelerList.length >0){
                                    for(var a in filtreHammaddelerList){
                                      hammaddeler += ''''$a',''';
                                    }
                                  }
                                  hammaddeler.length > 0 ? hammaddeler = hammaddeler.substring(0,hammaddeler.length-1) : hammaddeler = "";
                                  gidecekHammaddeler = hammaddeler;
                                  setState(() {
                                    loading = false;
                                    if(filtreHammaddelerList.isEmpty) filtreHammaddelerMi = false;
                                    else filtreHammaddelerMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreHammaddelerMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreHammaddelerList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Hammadde",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Hammadde",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        title: 'Kategoriler',
                        placeholder: 'Stok Filtrele',
                       selectedValue: filtreKategorilerList,
                        onChange: (state) => setState(() => filtreKategorilerList = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: filtreSecKategorilerList,
                          value: (index, item) => item['Kod'],
                          title: (index, item) => item['Kod'],
                          group: (index, item) => item['Grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  gidecekKategoriler = "";
                                  v.selection!.clear();
                                  setState(() {
                                    filtreKategorilerMi = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  String kategoriler = "";
                                  v.onChange();
                                  if(filtreKategorilerList.length >0){
                                    for(var a in filtreKategorilerList){
                                      kategoriler += ''''$a',''';
                                    }
                                  }
                                  kategoriler.length > 0 ? kategoriler = kategoriler.substring(0,kategoriler.length-1) : kategoriler = "";
                                  gidecekKategoriler = kategoriler;
                                  setState(() {
                                    loading = false;
                                    if(filtreKategorilerList.isEmpty) filtreKategorilerMi = false;
                                    else filtreKategorilerMi = true;
                                  });
                                  v.closeModal();
                                  Navigator.pop(context);
                                  await _stoklariGetir(false);
                                },
                              )
                            ],
                          );
                        },
                        choiceGrouped: false,
                        modalFilter: true,
                        modalType: S2ModalType.fullPage,
                        modalFilterAuto: true,
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(filtreKategorilerMi){
                            return Badge(
                              position: BadgePosition.bottomEnd(bottom: 5, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${filtreKategorilerList.length}",style: TextStyle(color: Colors.white),),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Kategori",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();

                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Kategori",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(child: InkWell(
                child: Container(
                  child: Center(
                    child: Text("Tamam",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontSize: 18),),),
                ),
                onTap: (){
                  Navigator.pop(context);
                },
              ))
            ],
          ),
        ),
      ),
    );
  }

  _stokAutoComplateGetir() async {
    stokAutoComplateList.clear();
    var response = await http.get(Uri.parse("${Sabitler
        .url}/api/StokAutoComplate?VtIsim=${UserInfo.activeDB}&FullAccess=${UserInfo.fullAccess}&Mobile=true&DevInfo=${TelefonBilgiler
        .userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey": Sabitler.apiKey});
    if (response.statusCode == 200) {
      var gelenStoklar = jsonDecode(response.body);
      for (var stoklar in gelenStoklar) {
        stokAutoComplateList.add(stoklar);
      }
    }
  }

  _stoklariGetir(bool isScan) async {
    setState(() {
      loading = false;
    });
    print("UserInfo.aktifSubeNo");
    print(UserInfo.aktifSubeNo);
    stoklarGridList.clear();
    var body = jsonEncode({
      "VtIsim" : UserInfo.activeDB,
      "SubeNo" : UserInfo.aktifSubeNo,
      "Arama":arananKelime.replaceAll("*", "%").replaceAll("\'", "\''"),
      "AnaGrup":"",
      "AltGrup" : "",
      "Marka" : "",
      "Reyon" : "",
      "Mobile":true,
      "DevInfo":TelefonBilgiler.userDeviceInfo,
      "AppVer":TelefonBilgiler.userAppVersion,
      "UserId":UserInfo.activeUserId,
      "altGruplar": gidecekAltGruplar,
      "anaGruplar": gidecekAnaGruplar,
      "markalar": gidecekMarkalar,
      "reyonlar": gidecekReyonlar,
      "ureticiler" : gidecekUreticiler,
      "ambalajlar" : gidecekAmbalajlar,
      "sektorler" : gidecekSektorler,
      "kalitekontrol" : gidecekKalitekontrol,
      "modeller" : gidecekModeller,
      "sezonlar" : gidecekSezonlar,
      "hammaddeler" : gidecekHammaddeler,
      "kategoriler" : gidecekKategoriler,
    });
    late http.Response response;
    try {
      response = await http.post(Uri.parse(
          "${Sabitler.url}/api/StokV4"),
          headers: {
            "apiKey": Sabitler.apiKey,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body
      ).timeout(Duration(seconds: 40));
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
    print(response.reasonPhrase);
    print(response.body);
    if(response.statusCode == 200) {
      var stokDetay = jsonDecode(response.body);
      for(var stok in stokDetay){
        StoklarGridModel stoklarGridModel = StoklarGridModel(
            stok['stokKodu'],
            stok['stokIsim'],
            stok['barKodu'],
            stok['kisaIsim'],
            stok['alternatifStokAdi'],
            stok['alternatifStokKodu'],
            stok['stokYabanciIsim'],
            stok['anaGrup'],
            stok['altGrup'],
            stok['marka'],
            stok['reyon'],
            stok['depo1StokMiktar'],
            stok['depo2StokMiktar'],
            stok['depo3StokMiktar'],
            stok['depo4StokMiktar'],
            stok['tumDepolarStokMiktar'],
            stok['stokBirim'],
            stok['fiyat'],
            stok['doviz'],
            stok['alinanSiparisKalan'],
            stok['verilenSiparisKalan'],
            stok['son30GunSatis'],
            stok['son3AyOrtalamaSatis'],
            stok['son6AyOrtalamaSatis'],
            stok['sdsToplamStokMerkezDahil'],
            stok['sdsMerkez'],
            stok['sdsizmir'],
            stok['sdsAdana'],
            stok['sdsAntalya'],
            stok['sdsSeyrantepe'],
            stok['sdsAnkara'],
            stok['sdsEurasia'],
            stok['sdsBursa'],
            stok['sdsAnadolu'],
            stok['sdsIzmit'],
            stok['sdsBodrum'],
            stok['sdsKayseri'],
            stok['zenitled'],
            stok['zenitledUretim'],
            stok['zenitledMerkez'],
            stok['zenitledAdana'],
            stok['zenitledBursa'],
            stok['zenitledAntalya'],
            stok['zenitledAnkara'],
            stok['zenitledKonya'],
            stok['D1SdsToplamStokMerkezDahil'],
            stok['D1SdsMerkez'],
            stok['D1SdsIzmir'],
            stok['D1SdsAdana'],
            stok['D1SdsAntalya'],
            stok['D1SdsSeyrantepe'],
            stok['D1SdsAnkara'],
            stok['D1SdsEurasia'],
            stok['D1SdsBursa'],
            stok['D1SdsAnadolu'],
            stok['D1SdsIzmit'],
            stok['D1SdsBodrum'],
            stok['D1SdsKayseri'],
            stok['D1Zenitled'],
            stok['D1ZenitledUretim'],
            stok['D1ZenitledMerkez'],
            stok['D1ZenitledAdana'],
            stok['D1ZenitledBursa'],
            stok['D1ZenitledAntalya'],
            stok['D1ZenitledAnkara'],
            stok['D1ZenitledKonya'],
            stok['stokAileKutugu']
        );
        stoklarGridList.add(stoklarGridModel);
      }
      if(isScan && stoklarGridList.length == 1){

        StoklarGridModel stok = stoklarGridList[0];

        Navigator.push(context, MaterialPageRoute(builder: (context) => StokDetaySayfasi(data: stok)));
      }

      setState(() {
        _stoklarDataSource = StoklarDataSource(_dataGridController);
        loading = true;
      });
      Fluttertoast.showToast(
          msg: "${stoklarGridList.length} kart bulundu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.blue.shade900,
          fontSize: 16.0
      );
      bool canVibrate = await Vibrate.canVibrate;
      if(canVibrate) Vibrate.vibrate();

    }else{
      setState(() {
        loading = true;
      });
    }
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  List<String> getSuggestions(String query) {
    List<String> eslesenler = [];
    List<String> eslesenler100 =  [];
    for (int i = 0; i < stokAutoComplateList.length; i++) {
      eslesenler.add(stokAutoComplateList[i]['stoklar']);
    }
    eslesenler.retainWhere((s) =>
        s.toLowerCase().contains(query.toLowerCase()));
    if(eslesenler.length > 100){
      for(int i =0 ; i<100; i++){
        eslesenler100.add(eslesenler[i]);
      }
      return eslesenler100;
    }else{
      return eslesenler;
    }

  }

  Future<void> _filtreGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/StokFiltre?vtIsim=${UserInfo.activeDB}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      filtreList.clear();
      var filtreler = jsonDecode(response.body);
      for(var filtre in filtreler){
        setState(() {
          filtreList.add(
              filtre);
        });
      }
    }else if(response.statusCode == 400){
      var message = jsonDecode(response.body);
      showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
    }
    response = await http.get(Uri.parse("${Sabitler.url}/api/StokFiltreGetir?vtIsim=${UserInfo.activeDB}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200){
      var filtreler = jsonDecode(response.body);
      for(var filtre in filtreler){
        switch (filtre["Grup"])
        {
          case "Markalar":
            setState(() {
              filtreSecMarkalarList.add(filtre);
            });

            break;
          case "Reyonlar":

            setState(() {
              filtreSecReyonlarList.add(filtre);
            });
            break;
          case "Üreticiler":
            setState(() {
              filtreSecUreticilerList.add(filtre);
            });
            break;
          case "Ambalajlar":
            setState(() {
              filtreSecAmbalajlarList.add(filtre);
            });
            break;
          case "Sektörler":
            setState(() {
              filtreSecSektorlerList.add(filtre);
            });
            break;
          case "Kalite Konrol":
            setState(() {
              filtreSecKalitekontrolList.add(filtre);
            });
            break;
          case "Modeller":
            setState(() {
              filtreSecModellerList.add(filtre);
            });
            break;
          case "Sezonlar":
            setState(() {
              filtreSecSezonlarList.add(filtre);
            });
            break;
          case "Hammaddeler":
            setState(() {
              filtreSecHammaddelerList.add(filtre);
            });
            break;
          case "Kategoriler":
            setState(() {
              filtreSecKategorilerList.add(filtre);
            });
            break;
          default:

            break;
        }
      }


    }else if(response.statusCode == 400){
      var message = jsonDecode(response.body);
      showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
    }

  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "İptal", true, ScanMode.BARCODE);

    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if(barcodeScanRes != "-1"){
        _stokAramaController.text = barcodeScanRes;
        arananKelime = barcodeScanRes;
        _stoklariGetir(true);
      }
    });
  }
}


final List<Map<String,dynamic>> filtreList = [];



final List<Map<String,dynamic>> filtreSecMarkalarList = [];
final List<Map<String,dynamic>> filtreSecReyonlarList = [];
final List<Map<String,dynamic>> filtreSecUreticilerList = [];
final List<Map<String,dynamic>> filtreSecAmbalajlarList = [];
final List<Map<String,dynamic>> filtreSecSektorlerList = [];
final List<Map<String,dynamic>> filtreSecKalitekontrolList = [];
final List<Map<String,dynamic>> filtreSecModellerList = [];
final List<Map<String,dynamic>> filtreSecSezonlarList = [];
final List<Map<String,dynamic>> filtreSecHammaddelerList = [];
final List<Map<String,dynamic>> filtreSecKategorilerList = [];




class StoklarDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;


  final DataGridController dataGridController;
  StoklarDataSource(this.dataGridController) {
    buildDataGridRows();
  }
  void buildDataGridRows() {
    dataGridRows = stoklarGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'stokKodu',value: e.stokKodu),
          DataGridCell<String>(columnName: 'stokIsim',value: e.stokIsim),
          DataGridCell<String>(columnName: 'stokYabanciIsim',value: e.stokYabanciIsim),
          DataGridCell<double>(columnName: 'musait',value: e.depo1StokMiktar-e.alinanSiparisKalan),
          DataGridCell<double>(columnName: 'tumDepolarStokMiktar',value: e.tumDepolarStokMiktar),
          DataGridCell<double>(columnName: 'depo1StokMiktar',value: e.depo1StokMiktar),
          DataGridCell<double>(columnName: 'depo2StokMiktar',value: e.depo2StokMiktar),
          DataGridCell<double>(columnName: 'depo3StokMiktar',value: e.depo3StokMiktar),
          DataGridCell<double>(columnName: 'depo4StokMiktar',value: e.depo4StokMiktar),
          DataGridCell<double>(columnName: 'merkez',value: UserInfo.activeDB == "MikroDB_V16_12" ? e.zenitledMerkez : e.sdsMerkez),
          DataGridCell<double>(columnName: 'alinanSiparisKalan',value: e.alinanSiparisKalan),
          DataGridCell<double>(columnName: 'verilenSiparisKalan',value: e.verilenSiparisKalan),
          DataGridCell<String>(columnName: 'stokAileKutugu',value: e.stokAileKutugu),
          DataGridCell<String>(columnName: 'marka',value: e.marka),
          DataGridCell<String>(columnName: 'reyon',value: e.reyon),
          DataGridCell<String>(columnName: 'stokBirim',value: e.stokBirim),
          DataGridCell<double>(columnName: 'fiyat',value: e.fiyat),
          DataGridCell<String>(columnName: 'doviz',value: e.doviz),
          DataGridCell<String>(columnName: 'kisaIsim',value: e.kisaIsim),
          DataGridCell<String>(columnName: 'anaGrup',value: e.anaGrup),
          DataGridCell<String>(columnName: 'altGrup',value: e.altGrup),
          DataGridCell<String>(columnName: 'alternatifStokKodu',value: e.stokAlternatifKod),
          DataGridCell<String>(columnName: 'alternatifStokIsim',value: e.stokAlternatifIsim),
          DataGridCell<String>(columnName: 'barKodu',value: e.barKodu),
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
    return DataGridRowAdapter(
        color: getRowBackGroundColor(),
        cells: row.getCells().map<Widget>((e) {

          return Container(
            alignment: alignValue(e.value),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(e.value == null ? "": formatValue(e.value).toString(),maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black),),
          );
        }).toList()
    );


  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
