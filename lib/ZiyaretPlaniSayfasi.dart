import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as sync;
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';
import 'modeller/GridModeller.dart';
import 'modeller/Listeler.dart';
import 'modeller/Modeller.dart';
import 'widgets/Dialoglar.dart';
import 'widgets/DreamCogsGif.dart';
import 'widgets/const_screen.dart';


class ZiyaretPlaniSayfasi extends StatefulWidget {
  @override
  _ZiyaretPlaniSayfasiState createState() => _ZiyaretPlaniSayfasiState();
}



class _ZiyaretPlaniSayfasiState extends State<ZiyaretPlaniSayfasi> {

  final DataGridController  _dataGridController = DataGridController();
  late ZiyaretPlaniDataSource _ziyaretPlaniDataSource = ZiyaretPlaniDataSource(_dataGridController);

  bool loading = false;
  String gosterilecekTarih2= DateFormat('dd-MM-yyyy').format(DateTime.now());
  DateTime now = DateTime.now();
  String gosterilecekTarih1 = "";
  late DateTime secilenTarih1;
  DateTime secilenTarih2 = DateTime.now();
  bool planlilar = false;
  bool biteniGizle = false;
  bool banaAit = false;
  bool tapSending = false;
  bool cariKodFiltreMi = false;
  bool ilgiliFiltreMi = false;
  bool sehirFiltreMi = false;

  final List<Map<String,dynamic>> cariKodFiltreList = [];
  List<String?> cariKodFiltreler = [];

  final List<Map<String,dynamic>> ilgiliFiltreList = [];
  List<String?> ilgiliFiltreler = [];

  final List<Map<String,dynamic>> sehirFiltreList = [];
  List<String?> sehirFiltreler = [];
  List<ZiyaretPlaniGridModel> yedekGridList = [];
  List<ZiyaretPlaniGridModel> aramaList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gosterilecekTarih1 = DateFormat('dd-MM-yyyy').format(DateTime(now.year,now.month-1,now.day,now.hour,now.minute,now.second,now.microsecond));
    secilenTarih1 = DateTime(now.year,now.month-1,now.day,now.hour,now.minute,now.second,now.microsecond);
    _ziyaretPlaniGetir();
  }
  @override
  Widget build(BuildContext context) {
    return ConstScreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
            actions: [
              IconButton(icon: FaIcon(FontAwesomeIcons.fileExcel), onPressed: () {
                if(ziyaretPlaniGridList.isEmpty) return;
                if(tapSending) return;
                _exportExcel();

              }),
              cariKodFiltreMi || ilgiliFiltreMi ? Stack(
                alignment: Alignment(0,5),
                children: [
                  Container(
                    color: Colors.red,
                  ), Text("${cariKodFiltreler.length + ilgiliFiltreler.length + sehirFiltreler.length}",style: TextStyle(color: Colors.white)),
                  IconButton(icon: const FaIcon(FontAwesomeIcons.filter), onPressed: ()async {
                    showDialog(context: context,builder: (context) => _filtreDialog());
                  }),
                ],
              )
                  : IconButton(icon: const FaIcon(FontAwesomeIcons.filter), onPressed: () async {
                showDialog(context: context,builder: (context) => _filtreDialog());
              }
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue.shade900,
            onPressed: () {
              showDialog(context: context,builder: (context) => BilgilendirmeDialog("Yeni ziyaret planı şuan geliştirilmektedir.\nYakın zamanda aktif edilmesini planlamaktayız."));
            },
          ),

          body: Column(
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
                            child:Text(gosterilecekTarih1,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                          )
                      ),
                      onTap: () => callDatePicker(1),
                    ),
                    InkWell(
                      child: Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: const EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/2.2-25,
                          child: Center(
                            child:Text(gosterilecekTarih2,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                          )
                      ),
                      onTap: () => callDatePicker(2),
                    ),
                    InkWell(
                      child: Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: const EdgeInsets.only(right: 1),
                          height: 50,
                          width: 50,
                          child: Center(
                              child: Icon(Icons.search,color: Colors.blue.shade900,)
                          )
                      ),
                      onTap: () async {
                        await _ziyaretPlaniGetir();
                      },
                    ),
                  ],
                ),
              ),/*
              Container(
                color: Colors.white,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child:  Container(
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                activeColor: Colors.blue.shade900,
                                onChanged: (v) {
                                  setState(() {
                                    planlilar = v;
                                    _aramaYap();
                                  });
                                },
                                value: planlilar,
                              ),
                              Text("Planlılar")
                            ],
                          )
                      ),
                      onTap: () {
                        setState(() {
                          planlilar = !planlilar;
                          _aramaYap();
                        });
                      },
                    ),
                    InkWell(
                      child:  Container(
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                activeColor: Colors.blue.shade900,
                                onChanged: (v) {
                                  setState(() {
                                    biteniGizle = v;
                                    _aramaYap();
                                  });
                                },
                                value: biteniGizle,
                              ),
                              Text("Biteni Gizle")
                            ],
                          )
                      ),
                      onTap: () {
                        setState(() {
                          biteniGizle = !biteniGizle;
                          _aramaYap();
                        });
                      },
                    ),
                    InkWell(
                      child:  Container(
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                activeColor: Colors.blue.shade900,
                                onChanged: (v) {
                                  setState(() {
                                    banaAit = v;
                                    _aramaYap();
                                  });
                                },
                                value: banaAit,
                              ),
                              Text("Bana Ait")
                            ],
                          )
                      ),
                      onTap: () {
                        setState(() {
                          banaAit =!banaAit;
                          _aramaYap();
                        });
                      },
                    ),
                  ],
                ),
              ),*/
              Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.blue.shade900,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text("ZİYARETLER",style: GoogleFonts.roboto(textStyle: const TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
              ),
              !loading ? Expanded(child: Container( child: DreamCogs())) :
              Expanded( child: Container(
                  margin: const EdgeInsets.only(bottom: 1,left: 1,right: 1),
                  child: _grid()
              ),)
            ],
          ),
        )
    );
  }
  Widget _grid() {
    return SfDataGridTheme(
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
        controller: _dataGridController,
        source: _ziyaretPlaniDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'id',label : "ID"),
          dreamColumn(columnName: 'planli',label : "PLANLI"),
          dreamColumn(columnName: 'durum',label : "DURUM"),
          dreamColumn(columnName: 'tarih',label : "TARİH"),
          dreamColumn(columnName: 'planTarih',label : "PLAN TARİHİ"),
          dreamColumn(columnName: 'cariKod',label : "CARİ KODU",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'cariAd',label : "CARİ ADI",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'sehir',label : "ŞEHİR",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'irtibatSekli',label : "İRTİBAT ŞEKLİ"),
          dreamColumn(columnName: 'ilgiliId',label : "İLGİLİ ID"),
          dreamColumn(columnName: 'ilgili',label : "İLGİLİ-ATANAN"),
          dreamColumn(columnName: 'ziyaretNotu',label : "ZİYARET NOTU",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'planNotu',label : "PLAN NOTU"),
          dreamColumn(columnName: 'atayan',label : "ATAYAN"),
          dreamColumn(columnName: 'atamaTarih',label : "ATAMA TARİHİ"),
        ],
        onCellTap: (value) {
          Future.delayed(const Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex > 0){
              var row = _dataGridController.selectedRow!.getCells();
              String notAciklama = row[11].value;
              _dataGridController.selectedIndex = -1;
              showDialog(context: context,builder: (context) => DetayDialog(detay: notAciklama,baslik: "ZİYARET DETAYI"));
            }
          });
        },
        onCellLongPress: (args){
          if(ziyaretPlaniGridList[args.rowColumnIndex.rowIndex].ilgili == UserInfo.mikroPersonelKod){

            print("ziyaret yetiştirme yetkin var ");
            //updateZiyaretNotu();


          }else{

            print("ziyaret yetiştirme yetkin yoooook ");
          }




        },
      ),
    );
  }

  Future <void> updateZiyaretNotu(int ZiyaretID ,String yeniNot) async{
    //

  }

  Future<DateTime?> getDate(String helpText,DateTime seciliTarih) {
    return showDatePicker(
      locale: const Locale('tr',''),
      helpText: helpText,
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: seciliTarih,
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
    if(secilenTarih == 1) {
      var order = await getDate("Plan Başlangıç Tarihi Seçiniz",secilenTarih1);
      if(order != null){
        setState(() {
          gosterilecekTarih1 = DateFormat('dd-MM-yyyy').format(order);
          secilenTarih1 = order;
        });
      }
    }else{
      var order = await getDate("Plan Bitiş Tarihi Seçiniz",secilenTarih2);
      if(order != null){
        setState(() {
          gosterilecekTarih2 = DateFormat('dd-MM-yyyy').format(order);
          secilenTarih2 = order;
        });
      }
      setState(() {

      });
    }
  }



  _aramaYap() {

    if(yedekGridList.isEmpty) return;
    if(planlilar == false && banaAit == false && biteniGizle == false){
      setState(() {
        ziyaretPlaniGridList = yedekGridList;

        _ziyaretPlaniDataSource = ZiyaretPlaniDataSource(_dataGridController);
      });
    }else{
      List<ZiyaretPlaniGridModel> list = [];
      for(var ziyaret in ziyaretPlaniGridList){
        if(ziyaret.planli!.contains(planlilar ? "+" : "")
            && ziyaret.ilgili!.contains(banaAit ? UserInfo.mikroPersonelKod! : "")
            && ziyaret.durum!.contains(biteniGizle ? "-" : "")){
          list.add(ziyaret);
        }
      }
      setState(() {
        ziyaretPlaniGridList = list;

        _ziyaretPlaniDataSource = ZiyaretPlaniDataSource(_dataGridController);
      });
    }
  }
  _ziyaretPlaniGetir() async {
    setState(() {
      loading = false;
    });
    late http.Response response;
    try {

      // print("PlanliZiyaretler?vtName=${UserInfo.activeDB}");
      // print("basZaman=$gosterilecekTarih1&sonZaman=$gosterilecekTarih2");
      // print("DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}");
      // print("UserId=${UserInfo.activeUserId}");

      response  = await http.get(Uri.parse("${Sabitler.url}/api/PlanliZiyaretler?vtName=${UserInfo.activeDB}&sadecePlanli=false&basZaman=$gosterilecekTarih1&sonZaman=$gosterilecekTarih2&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
          headers: {"apiKey" : Sabitler.apiKey}).timeout(const Duration(seconds: 30));
    } on TimeoutException {
      showDialog(context: context,
          builder: (BuildContext context ){
            return BilgilendirmeDialog("Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    } on Error {
      showDialog(context: context,
          builder: (BuildContext context ){
            return BilgilendirmeDialog("Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    }
    if(response.statusCode == 200) {
      var ziyaretPlanlari = jsonDecode(response.body);
      cariKodFiltreList.clear();
      ilgiliFiltreList.clear();
      ziyaretPlaniGridList.clear();
      for(var ziyaretPlani in ziyaretPlanlari){
        ZiyaretPlaniGridModel ziyaretPlaniGridModel = ZiyaretPlaniGridModel(
          ziyaretPlani["ID#"],
          ziyaretPlani["DURUM"],
          ziyaretPlani["PLANLI"],
          DateTime.parse(ziyaretPlani["TARİH"].toString()),
          ziyaretPlani["PLAN TARİH"] == null ? ziyaretPlani["PLAN TARİH"] : DateTime.parse(ziyaretPlani["PLAN TARİH"].toString()),
          ziyaretPlani["CARİ KOD"],
          ziyaretPlani["CARİ AD"],
          ziyaretPlani["İRTİBAT ŞEKLİ"],
          ziyaretPlani["İLGİLİ ID"],
          ziyaretPlani["İLGİLİ"],
          ziyaretPlani["ZİYARET NOTU"],
          ziyaretPlani["PLAN NOTU"],
          ziyaretPlani["ATAYAN"],
          ziyaretPlani["ATAMA TARİH"] == null ? null : DateTime.parse(ziyaretPlani["ATAMA TARİH"].toString()),
          ziyaretPlani["SEHIR"],);
        ziyaretPlaniGridList.add(ziyaretPlaniGridModel);
        bool addT = true;
        bool addS = true;
        bool addSehir = true;
        for (var map in cariKodFiltreList) {
          if(map["value"] == "${ziyaretPlani["CARİ KOD"]} - ${ziyaretPlani["CARİ AD"]}") addT = false;
        }
        for (var map in ilgiliFiltreList) {
          if(map["value"] == ziyaretPlani["İLGİLİ"]) addS = false;
        }
        for (var map in sehirFiltreList) {
          if(map["value"] == ziyaretPlani["SEHIR"]) addSehir = false;
        }
        if(addT) cariKodFiltreList.add({"grup" : "Cari Kodu","value": "${ziyaretPlani["CARİ KOD"]} - ${ziyaretPlani["CARİ AD"]}"});
        if(addS) ilgiliFiltreList.add({"grup" : "İlgili-Atanan","value": ziyaretPlani["İLGİLİ"]});
        if(addSehir) sehirFiltreList.add({"grup" : "Şehir","value": ziyaretPlani["SEHIR"]});
      }
      yedekGridList = ziyaretPlaniGridList;
      aramaList = ziyaretPlaniGridList;
      cariKodFiltreler.clear();
      ilgiliFiltreler.clear();
      sehirFiltreler.clear();
      sehirFiltreMi = false;
      cariKodFiltreMi = false;
      ilgiliFiltreMi = false;
      setState(() {
        loading = true;
      });
    }else{
    }
    _ziyaretPlaniDataSource = ZiyaretPlaniDataSource(_dataGridController);
    Future.delayed(const Duration(milliseconds: 50), () async{
      FocusScope.of(context).unfocus();
    });
  }



  Widget _filtreDialog(){
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: SmartSelect<String?>.multiple(
                      modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Cari Filtre',
                      placeholder: 'Cari Filtrele',
                      selectedValue: cariKodFiltreler,
                      onChange: (state) => setState(() => cariKodFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: cariKodFiltreList,
                        value: (index, item) => item['value'],
                        title: (index, item) => item['value'],
                        group: (index, item) => item['grup'],
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
                                child:const  Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                              ),
                              onTap: () async {
                                v.selection!.clear();
                                Fluttertoast.showToast(
                                    msg: "Filtreler temizlendi.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 16.0
                                );
                                setState(() {
                                  _gridAra([],ilgiliFiltreler,sehirFiltreler);
                                  cariKodFiltreMi = false;
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
                                child: const Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                              ),
                              onTap: () async {
                                v.onChange();
                                if(cariKodFiltreler.isNotEmpty){
                                  setState(() {
                                    cariKodFiltreMi = true;
                                  });
                                }else{
                                  cariKodFiltreMi = false;
                                }
                                v.closeModal();
                                _gridAra(cariKodFiltreler,ilgiliFiltreler,sehirFiltreler);
                                Navigator.pop(context);
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
                        return const Center(
                          child: Text("FİLTRE BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if(cariKodFiltreMi){
                          return Stack(
                            alignment: Alignment(0,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),
                              Text("${cariKodFiltreler.length}",style: TextStyle(color: Colors.white)),
                              InkWell(
                                  child: Container(child: Center(child: Text("Cari",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
                                  onTap: () async {
                                    state.showModal();
                                  }
                              ),
                            ],
                          );
                        }else{
                          return InkWell(
                              child: Container(padding: EdgeInsets.only(top: 10),child: Center(child: Text("Cari",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),),
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
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: SmartSelect<String?>.multiple(
                      modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'İlgili-Atanan',
                      placeholder: 'İlgili-Atanan Filtrele',
                      selectedValue: ilgiliFiltreler,
                      onChange: (state) => setState(() => ilgiliFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: ilgiliFiltreList,
                        value: (index, item) => item['value'],
                        title: (index, item) => item['value'],
                        group: (index, item) => item['grup'],
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
                                child: const Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                              ),
                              onTap: () async {
                                v.selection!.clear();
                                setState(() {
                                  ilgiliFiltreMi = false;
                                  _gridAra(cariKodFiltreler,[],sehirFiltreler);
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
                                        offset: const Offset(2, 5),
                                      ),
                                    ],
                                    color: Colors.grey.shade500
                                ),
                                child: const Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                              ),
                              onTap: () async {
                                v.onChange();
                                setState(() {
                                  if(ilgiliFiltreler.isNotEmpty){
                                    ilgiliFiltreMi = true;

                                  }else{
                                    ilgiliFiltreMi = false;
                                  }
                                });
                                v.closeModal();
                                _gridAra(cariKodFiltreler,ilgiliFiltreler,sehirFiltreler);
                                Navigator.pop(context);
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
                        return const Center(
                          child: Text("FİLTRE BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if(ilgiliFiltreMi){
                          return Stack(
                            alignment: Alignment(0,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),Text("${ilgiliFiltreler.length}",style: TextStyle(color: Colors.white),),
                              InkWell(
                                  child: Container(child: Center(child: Text("İlgili-Atanan",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () async {
                                    state.showModal();
                                  }
                              ),
                            ],

                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("İlgili-Atanan",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
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
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: SmartSelect<String?>.multiple(
                      modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Şehir',
                      placeholder: 'Şehir Filtrele',
                      selectedValue: sehirFiltreler,
                      onChange: (state) => setState(() => sehirFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: sehirFiltreList,
                        value: (index, item) => item['value'],
                        title: (index, item) => item['value'],
                        group: (index, item) => item['grup'],
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
                                child: const Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                              ),
                              onTap: () async {
                                v.selection!.clear();
                                setState(() {
                                  sehirFiltreMi = false;
                                  _gridAra(cariKodFiltreler,ilgiliFiltreler,[]);
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
                                        offset: const Offset(2, 5),
                                      ),
                                    ],
                                    color: Colors.grey.shade500
                                ),
                                child: const Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                              ),
                              onTap: () async {
                                v.onChange();
                                setState(() {
                                  if(sehirFiltreler.isNotEmpty){
                                    sehirFiltreMi = true;

                                  }else{
                                    sehirFiltreMi = false;
                                  }
                                });
                                v.closeModal();
                                _gridAra(cariKodFiltreler,ilgiliFiltreler,sehirFiltreler);
                                Navigator.pop(context);
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
                        return const Center(
                          child: Text("FİLTRE BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if(sehirFiltreMi){
                          return Stack(
                            alignment: Alignment(0,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ), Text("${sehirFiltreler.length}",style: TextStyle(color: Colors.white),),
                              InkWell(
                                  child: Container(child: Center(child: Text("Şehir",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () async {
                                    state.showModal();
                                  }
                              ),
                            ],

                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Şehir",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        cariKodFiltreler = [];
                        ilgiliFiltreler = [];
                        sehirFiltreler = [];
                        ilgiliFiltreMi = false;
                        cariKodFiltreMi = false;
                        sehirFiltreMi = false;
                        _gridAra([], [],[]);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Temizle",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontSize: 18),),
                  ),
                  Container(
                    height: 46,width: 1,
                    color: Colors.grey.shade300,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _gridAra(cariKodFiltreler,ilgiliFiltreler,sehirFiltreler);
                      },
                      child: Text("Tamam",style: TextStyle(color: Colors.green.shade800,fontWeight: FontWeight.w700,fontSize: 18),)
                  )
                ],
              )
            ],
          ),
        ),
      ),

    );
  }


  _gridAra(List<String?> a,List<String?> b,List<String?> c) {
    List<ZiyaretPlaniGridModel> arananlarList = [];

    for(var value in aramaList){
      if((a.contains("${value.cariKod} - ${value.cariAd}") || a.isEmpty ) && (b.contains(value.ilgili) || b.isEmpty) && (c.contains(value.sehir) || c.isEmpty))
      {
        arananlarList.add(value);
      }
    }
    setState(() {
      ziyaretPlaniGridList = arananlarList;

      _ziyaretPlaniDataSource = ZiyaretPlaniDataSource(_dataGridController);
    });
  }







  _exportExcel() async{
    tapSending= true;


    final sync.Workbook workbook = sync.Workbook();
    final sync.Worksheet sheet = workbook.worksheets[0];

    sheet.name = "Sayfa1";

    for(int i = 0; i< ziyaretPlaniGridList.length+1; i++){
      if(i == 0){
        var cell = sheet.getRangeByName("A1");
        cell.value = "ID";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("B1");
        cell.value = "TARİH";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("C1");
        cell.value = "CARİ KOD";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("D1");
        cell.value = "CARİ AD";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("E1");
        cell.value = "ŞEHİR";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("F1");
        cell.value = "İRTİBAT ŞEKLİ";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("G1");
        cell.value = "İLGİLİ-ATANAN";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("H1");
        cell.value = "ZİYARET NOTU";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
      }else{
        var cell = sheet.getRangeByName("A${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].id;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("B${i+1}");
        cell.value = DateFormat('dd.MM.yyyy').format(ziyaretPlaniGridList[i-1].tarih!);
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("C${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].cariKod;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("D${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].cariAd;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("E${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].sehir;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("F${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].irtibatSekli;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("G${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].ilgili;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("H${i+1}");
        cell.value = ziyaretPlaniGridList[i-1].ziyaretNotu;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
      }
    }
    sheet.autoFitColumn(3);
    sheet.autoFitColumn(4);
    sheet.autoFitColumn(7);
    sheet.autoFitColumn(8);
    Directory appDocDir = await getApplicationDocumentsDirectory();


    final List<int> bytes = workbook.saveAsStream();
    await File("${appDocDir.path}/Ziyaretler.xlsx").writeAsBytes(bytes);
    workbook.dispose();

    await send("${appDocDir.path}/Ziyaretler.xlsx");

    return;

  }


  Future<void> send(String path) async {
    Share.shareFiles([path]);
    tapSending= false;
  }

}





class ZiyaretPlaniDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = ziyaretPlaniGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id',value: e.id),
          DataGridCell<String>(columnName: 'planli',value: e.planli),
          DataGridCell<String>(columnName: 'durum',value: e.durum),
          DataGridCell<DateTime>(columnName: 'tarih',value: e.tarih),
          DataGridCell<DateTime>(columnName: 'planTarih',value: e.planTarih),
          DataGridCell<String>(columnName: 'cariKod',value: e.cariKod),
          DataGridCell<String>(columnName: 'cariAd',value: e.cariAd),
          DataGridCell<String>(columnName: 'sehir',value: e.sehir),
          DataGridCell<String>(columnName: 'irtibatSekli',value: e.irtibatSekli),
          DataGridCell<int>(columnName: 'ilgiliId',value: e.ilgiliId),
          DataGridCell<String>(columnName: 'ilgili',value: e.ilgili),
          DataGridCell<String>(columnName: 'ziyaretNotu',value: e.ziyaretNotu),
          DataGridCell<String>(columnName: 'planNotu',value: e.planNotu),
          DataGridCell<String>(columnName: 'atayan',value: e.atayan),
          DataGridCell<DateTime>(columnName: 'atamaTarih',value: e.atamaTarih),
        ]
    )).toList();
  }


  final DataGridController dataGridController;
  ZiyaretPlaniDataSource(this.dataGridController) {
    buildDataGridRows();
  }
  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    TextStyle getSelectionStyle() {
      if(dataGridController.selectedRows.contains(row)){
        return(const TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }else{
        return(const TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black));
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(e.value == null ? "": formatValue(e.value).toString(),maxLines: 1,overflow: TextOverflow.ellipsis,style: getSelectionStyle(),),
          );
        }).toList()
    );


  }

  void updateDataGridSource() {
    notifyListeners();
  }
}