
/*import 'dart:async';
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';
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

import 'CariDetaySayfasi.dart';

class CarilerSayfasi extends StatefulWidget {
  @override
  _CarilerSayfasiState createState() => _CarilerSayfasiState();
}


class _CarilerSayfasiState extends State<CarilerSayfasi> {


  bool loading = true;
  TextEditingController _cariAramaController = new TextEditingController();
  String arananKelime = "";
  List<String> aramaHelperList = [];
  final DataGridController _dataGridController = DataGridController();
  late CarilerDataSource _carilerDataSource;


  final List<Map<String,dynamic>> gruplarFiltreList = [];
  final List<Map<String,dynamic>> temsilcilerFiltreList = [];
  final List<Map<String,dynamic>> bolgelerFiltreList = [];
  final List<Map<String,dynamic>> sektorlerFiltreList = [];

  List<String?> secilenSektorlerList = [];
  List<String?> secilenGruplarList = [];
  List<String?> secilenBolgelerList = [];
  List<String?> secilenTemsilcilerList = [];

  bool filtreSektolerMi = false;
  bool filtreGruplarMi = false;
  bool filtreBolgelerMi = false;
  bool filtreTemsilcilerMi = false;


  String gidecekSektorler = "";
  String gidecekGruplar = "";
  String gidecekBolgeler = "";
  String gidecekTemsilciler = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _filtreGetir();
    _carilerDataSource = CarilerDataSource(_dataGridController);
    AutoOrientation.fullAutoMode();
    _cariAutoComplateGetir();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    carilerGridList.clear();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: OrientationBuilder(
        builder: (context,currentOrientation) {
          if(currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet) {
            return HorizontalPage(_grid(),);
          }else {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Container(
                    child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
                ),
                actions: [
                  filtreSektolerMi || filtreGruplarMi || filtreBolgelerMi || filtreTemsilcilerMi ? Badge(
                    position: BadgePosition.topEnd(top: 0, end: 5),
                    badgeColor: Colors.red,
                    badgeContent: Text("${secilenBolgelerList.length + secilenGruplarList.length + secilenSektorlerList.length +
                        secilenTemsilcilerList.length}",style: TextStyle(color: Colors.white)),
                    child: IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: ()async {
                      /*if(filtreSecMarkalarList.isEmpty){
                        showDialog(context: context,builder: (conxtext) => Center(child:  CircularProgressIndicator(),));
                        await _filtreGetir();
                        Navigator.pop(context);
                      }*/
                      showDialog(context: context,builder: (context) => _filtreDialog());
                    }),
                  )
                      : IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: () async {
                        showDialog(context: context,builder: (context) => _filtreDialog());
                      }
                  ),
                ],
                centerTitle: true,
                backgroundColor: Colors.blue.shade900,
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
                        child: TypeAheadFormField(
                          hideOnLoading: true,
                          textFieldConfiguration: TextFieldConfiguration(
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) async {
                              if(await Foksiyonlar.internetDurumu(context)){
                                setState(() {
                                  loading = false;
                                  arananKelime = _cariAramaController.text;
                                });
                                carilerGridList = [];
                                _carilerGetir();
                              }
                            },
                            decoration: InputDecoration(
                                hintText:
                                'Sadece kod aramak için * ekleyin',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                                  onPressed: () {
                                    //_dataGridController.selectedRow = null;
                                    _cariAramaController.text = "";
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                            ),
                            controller: this._cariAramaController,
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
                              for (var i = 0; i < mySuggestion.toString().length;
                              i++) {
                                aramaHelperList.add(mySuggestion[i].toString());
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
                            this._cariAramaController.text = suggestion.toString();
                            if(await Foksiyonlar.internetDurumu(context)){
                              setState(() {
                                loading = false;
                                arananKelime = _cariAramaController.text;
                              });
                              carilerGridList = [];
                              _carilerGetir();
                            }
                          },
                          onSaved: (value) => this._cariAramaController.text = value!,
                        ),
                        width: MediaQuery.of(context).size.width -70,
                        height: 60,
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
                              arananKelime = _cariAramaController.text;
                            });
                            carilerGridList = [];
                            _carilerGetir();
                          }
                          //FocusScope.of(context).requestFocus(new FocusNode());
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
                      child: Center(child: Text("CARİLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
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
      ),
    );
  }
  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        allowSorting: true,
        allowTriStateSorting: true,
        controller: _dataGridController,
        source: _carilerDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        columns: <GridColumn> [
          dreamColumn(columnName: 'Unvan',label : "ÜNVAN",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'KOD',label : "CARİ KOD",alignment: Alignment.center),
          dreamColumn(columnName: 'Bakiye',label : "BAKİYE",alignment: Alignment.center,minWidth: 120),
          dreamColumn(columnName: 'Risk',label : "RİSK",alignment: Alignment.center,minWidth: 120),
          dreamColumn(columnName: 'Kredi',label : "KREDİ",alignment: Alignment.center,minWidth: 120),
          dreamColumn(columnName: 'KalanKredi',label : "KALAN KREDİ",alignment: Alignment.center),
          dreamColumn(columnName: 'Vade',label : "VADE",alignment: Alignment.center),
          dreamColumn(columnName: 'TEMSILCI',label : "TEMSİLCİ",alignment: Alignment.center),
          dreamColumn(columnName: 'SEKTOR',label : "SEKTÖR",alignment: Alignment.center),
          dreamColumn(columnName: 'BOLGE',label : "BÖLGE",alignment: Alignment.center),
          dreamColumn(columnName: 'GRUP',label:'GRUP',alignment: Alignment.center),
          dreamColumn(columnName: 'VDAIRESI',label:'VERGİ DAİRESİ',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'VNO',label:'VERGİ NO',alignment: Alignment.center),
          dreamColumn(columnName: 'EMAIL',label:'EMAİL',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'GSM',label:'GSM',alignment: Alignment.center),
          dreamColumn(columnName: 'MUSTERITIPI',label:'MÜŞTERİ TİPİ',alignment: Alignment.center),
          dreamColumn(columnName: 'MUTABAKATMAIL',label:'MÜTABAKAT MAİL',alignment: Alignment.centerLeft),
        ],
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), (){
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex >0){
              var row = _dataGridController.selectedRow!.getCells();
              CarilerGridModel cari = carilerGridList.where((e) => e.Kod == row[1].value.toString()).first;
              _dataGridController.selectedIndex = -1;
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CariDetaySayfasi(data: cari,),
              ));
            }
          });
        },
      ),
    );
  }

  Widget _filtreDialog(){
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child:     SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Sektörler',
                      placeholder: 'Sektör Filtrele',
                      selectedValue: secilenSektorlerList,
                      onChange: (state) => setState(() => secilenSektorlerList = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: sektorlerFiltreList,
                        value: (index, item) => item['Kod'],
                        title: (index, item) => item['Kod'] == "" ?"Tanımsız" : item['Kod'],
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
                                  filtreSektolerMi = false;
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
                                if(secilenSektorlerList.length >0){
                                  for(var a in secilenSektorlerList){
                                    markalar += ''''$a',''';
                                  }
                                }
                                markalar.length > 0 ? markalar = markalar.substring(0,markalar.length-1) : markalar = "";
                                gidecekSektorler = markalar;
                                setState(() {
                                  loading = false;
                                  if(secilenSektorlerList.isEmpty) filtreSektolerMi = false;
                                  else filtreSektolerMi = true;
                                });
                                v.closeModal();
                                Navigator.pop(context);
                                await _carilerGetir();
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
                        if(filtreSektolerMi){
                          return Badge(
                            position: BadgePosition.bottomEnd(bottom: -5, end: 10),
                            badgeColor: Colors.red,
                            badgeContent: Text("${secilenSektorlerList.length}",style: TextStyle(color: Colors.white),),
                            child: InkWell(
                                child: Container(child: Center(child: Text("Sektör",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () async {
                                  state.showModal();


                                }
                            ),
                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Sektör",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                              onTap: () async {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Gruplar',
                      placeholder: 'Grup Filtrele',
                      selectedValue: secilenGruplarList,
                      onChange: (state) => setState(() => secilenGruplarList = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: gruplarFiltreList,
                        value: (index, item) => item['Kod'],
                        title: (index, item) => item['Kod'] == "" ?"Tanımsız" : item['Kod'],
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
                                gidecekGruplar = "";
                                v.selection!.clear();
                                setState(() {
                                  filtreGruplarMi = false;
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
                                if(secilenGruplarList.length >0){
                                  for(var a in secilenGruplarList){
                                    reyonlar += ''''$a',''';
                                  }
                                }
                                reyonlar.length > 0 ? reyonlar = reyonlar.substring(0,reyonlar.length-1) : reyonlar = "";
                                gidecekGruplar = reyonlar;
                                setState(() {
                                  loading = false;
                                  if(secilenGruplarList.isEmpty) filtreGruplarMi = false;
                                  else filtreGruplarMi = true;
                                });
                                v.closeModal();
                                Navigator.pop(context);
                                await _carilerGetir();
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
                        if(filtreGruplarMi){
                          return Badge(
                            position: BadgePosition.bottomEnd(bottom: -0, end: 10),
                            badgeColor: Colors.red,
                            badgeContent: Text("${secilenGruplarList.length}",style: TextStyle(color: Colors.white),),
                            child: InkWell(
                                child: Container(child: Center(child: Text("Grup",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();

                                }
                            ),
                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Grup",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                              onTap: () {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Bölgeler',
                      placeholder: 'Bölge Filtrele',
                      selectedValue: secilenBolgelerList,
                      onChange: (state) => setState(() => secilenBolgelerList = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: bolgelerFiltreList,
                        value: (index, item) => item['Kod'],
                        title: (index, item) => item['Kod'] == "" ?"Tanımsız" : item['Kod'],
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
                                gidecekBolgeler = "";
                                v.selection!.clear();
                                setState(() {
                                  filtreBolgelerMi = false;
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
                                if(secilenBolgelerList.length >0){
                                  for(var a in secilenBolgelerList){
                                    ureticiler += ''''$a',''';
                                  }
                                }
                                ureticiler.length > 0 ? ureticiler = ureticiler.substring(0,ureticiler.length-1) : ureticiler = "";
                                gidecekBolgeler = ureticiler;
                                setState(() {
                                  loading = false;
                                  if(secilenBolgelerList.isEmpty) filtreBolgelerMi = false;
                                  else filtreBolgelerMi = true;
                                });
                                v.closeModal();
                                Navigator.pop(context);
                                await _carilerGetir();
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
                        if(filtreBolgelerMi){
                          return Badge(
                            position: BadgePosition.bottomEnd(bottom: -0, end: 10),
                            badgeColor: Colors.red,
                            badgeContent: Text("${secilenBolgelerList.length}",style: TextStyle(color: Colors.white),),
                            child: InkWell(
                                child: Container(child: Center(child: Text("Bölge",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();

                                }
                            ),
                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Bölge",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                              onTap: () {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child:   SmartSelect<String?>.multiple(modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Temsilciler',
                      placeholder: 'Temsilci Filtrele',
                      selectedValue: secilenTemsilcilerList,
                      onChange: (state) => setState(() => secilenTemsilcilerList = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: temsilcilerFiltreList,
                        value: (index, item) => item['Kod'],
                        title: (index, item) => item['Kod'] == "" ?"Tanımsız" : item['Kod'],
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
                                gidecekTemsilciler = "";
                                v.selection!.clear();
                                setState(() {
                                  filtreTemsilcilerMi = false;
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
                                if(secilenTemsilcilerList.length >0){
                                  for(var a in secilenTemsilcilerList){
                                    ambalajlar += ''''$a',''';
                                  }
                                }
                                ambalajlar.length > 0 ? ambalajlar = ambalajlar.substring(0,ambalajlar.length-1) : ambalajlar = "";
                                gidecekTemsilciler = ambalajlar;
                                setState(() {
                                  loading = false;
                                  if(secilenTemsilcilerList.isEmpty) filtreTemsilcilerMi = false;
                                  else filtreTemsilcilerMi = true;
                                });
                                v.closeModal();
                                Navigator.pop(context);
                                await _carilerGetir();
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
                        if(filtreTemsilcilerMi){
                          return Badge(
                            position: BadgePosition.bottomEnd(bottom: -5, end: 10),
                            badgeColor: Colors.red,
                            badgeContent: Text("${secilenTemsilcilerList.length}",style: TextStyle(color: Colors.white),),
                            child: InkWell(
                                child: Container(child: Center(child: Text("Temsilci",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                onTap: () {
                                  state.showModal();

                                }
                            ),
                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Temsilci",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                              onTap: () {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Center(
                          child: Text("Temizle",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontSize: 18),),),
                        onTap: (){
                          setState(() {
                            filtreBolgelerMi = false;
                            filtreGruplarMi = false;
                            filtreSektolerMi = false;
                            filtreTemsilcilerMi = false;
                            gidecekTemsilciler = "";
                            gidecekGruplar = "";
                            gidecekBolgeler = "";
                            gidecekSektorler= "";
                            secilenTemsilcilerList.clear();
                            secilenSektorlerList.clear();
                            secilenGruplarList.clear();
                            secilenBolgelerList.clear();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    VerticalDivider(),
                    Expanded(
                        child:InkWell(
                          child: Center(
                            child: Text("Tamam",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
  Future<void> _filtreGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/CariFiltreler?vtIsim=${UserInfo.activeDB}"),headers: {"apiKey" : Sabitler.apiKey});

    if(response.statusCode == 200){
      var filtreler = jsonDecode(response.body);
      for(var filtre in filtreler){
        switch (filtre["Grup"])
        {
          case "Gruplar":
            setState(() {
              gruplarFiltreList.add(filtre);
            });

            break;
          case "Temsilciler":

            setState(() {
              temsilcilerFiltreList.add(filtre);
            });
            break;
          case "Bölgeler":
            setState(() {
              bolgelerFiltreList.add(filtre);
            });
            break;
          case "Sektörler":
            setState(() {
              sektorlerFiltreList.add(filtre);
            });
            break;
          default:

            break;
        }
      }


    }

  }

  _cariAutoComplateGetir() async {
    cariAutoComplateList.clear();
    var response = await http.get(Uri.parse("${Sabitler
        .url}/api/AutoComplate?VtIsim=${UserInfo.activeDB}&FullAccess=${UserInfo.fullAccess}&Mobile=true&DevInfo=${TelefonBilgiler
        .userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey": Sabitler.apiKey});
    if (response.statusCode == 200) {
      var gelenCariler = jsonDecode(response.body);
      for (var cariler in gelenCariler) {
        setState(() {
          cariAutoComplateList.add(cariler);
        });
      }
    }
  }
  _carilerGetir() async {
    carilerGridList.clear();
    var body = jsonEncode({
      "VtIsim" : UserInfo.activeDB,
      "Arama":arananKelime.replaceAll("*", "%").replaceAll("\'", "\''"),
      "Mobile":true,
      "FullAccess":true,
      "DevInfo":TelefonBilgiler.userDeviceInfo,
      "AppVer":TelefonBilgiler.userAppVersion,
      "UserId":UserInfo.activeUserId,
      "Temsilciler": gidecekTemsilciler,
      "Gruplar" : gidecekGruplar,
      "Bolgeler" : gidecekBolgeler,
      "Sektorler" : gidecekSektorler,
    });
    late http.Response response;
    print(UserInfo.activeDB);
    try {
      response  = await http.post(Uri.parse("${Sabitler.url}/api/Carilers"),
          headers: {
        "apiKey" : Sabitler.apiKey,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body
          ).timeout(Duration(seconds: 35));
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

      var cariDetay = jsonDecode(response.body);
      for(var cari in cariDetay){
        CarilerGridModel gridCariler = new CarilerGridModel(cari["BOLGE"], cari["KalanKredi"], cari["Risk"], cari["Bakiye"], cari["TEMSILCI"], cari["UNVAN"], cari["Vade"], cari["KOD"], cari["VDAIRESI"],
            cari["EMAIL"], cari["VNO"], cari["SEKTOR"], cari["MUTABAKATMAIL"], cari["MUSTERITIPI"], cari["Kredi"], cari["GSM"], cari["GRUP"]);
        carilerGridList.add(gridCariler);
      }
      setState(() {
        loading = true;
      });
      _carilerDataSource = CarilerDataSource(_dataGridController);
      Fluttertoast.showToast(
          msg: "${carilerGridList.length} kart bulundu",
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
    List<String> eslesenler100 = [];
    for (int i = 0; i < cariAutoComplateList.length; i++) {
      eslesenler.add(cariAutoComplateList[i]['UNVAN']);
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
}


class CarilerDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;


  final DataGridController dataGridController;
  CarilerDataSource(this.dataGridController) {
    buildDataGridRows();
  }
  void buildDataGridRows() {
    dataGridRows = carilerGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'Unvan',value: e.Unvan),
          DataGridCell<String>(columnName: 'KOD',value: e.Kod),
          DataGridCell<double>(columnName: 'Bakiye',value: e.Bakiye),
          DataGridCell<double>(columnName: 'Risk',value: e.Risk),
          DataGridCell<double>(columnName: 'Kredi',value: e.Kredi),
          DataGridCell<double>(columnName: 'KalanKredi',value: e.KalanKredi),
          DataGridCell<String>(columnName: 'Vade',value: e.Vade),
          DataGridCell<String>(columnName: 'TEMSILCI',value: e.Temsilci),
          DataGridCell<String>(columnName: 'SEKTOR',value: e.Sektor),
          DataGridCell<String>(columnName: 'BOLGE',value: e.Bolge),
          DataGridCell<String>(columnName: 'GRUP',value: e.Grup),
          DataGridCell<String>(columnName: 'VDAIRESI',value: e.VDairesi),
          DataGridCell<String>(columnName: 'VNO',value: e.VNo),
          DataGridCell<String>(columnName: 'EMAIL',value: e.Email),
          DataGridCell<String>(columnName: 'GSM',value: e.Gsm),
          DataGridCell<String>(columnName: 'MUSTERITIPI',value: e.MusteriTipi),
          DataGridCell<String>(columnName: 'MUTABAKATMAIL',value: e.Mutabakatmail),
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


 */