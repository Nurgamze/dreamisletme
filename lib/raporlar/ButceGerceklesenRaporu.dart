import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as sync;
import '../modeller/GridModeller.dart';
import '../modeller/Listeler.dart';
import '../modeller/Modeller.dart';
import '../stoklar/HorizontalPage.dart';
import '../stoklar/const_screen.dart';
import '../widgets/Dialoglar.dart';
import '../widgets/DreamCogsGif.dart';
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';




class ButceGerceklesenRaporuSayfasi extends StatefulWidget {
  const ButceGerceklesenRaporuSayfasi({Key? key}) : super(key: key);

  @override
  _ButceGerceklesenRaporuSayfasiState createState() => _ButceGerceklesenRaporuSayfasiState();
}


final List<Map<String, dynamic>> _donemFiltreList = [];
List<String?> _donemFiltreler = [];

final List<Map<String, dynamic>> _stokHizmetFiltreList = [];
List<String?> _stokHizmetFiltreler = [];


class _ButceGerceklesenRaporuSayfasiState extends State<ButceGerceklesenRaporuSayfasi> {

  bool loading = true;
  final DataGridController _dataGridController = DataGridController();
  late ButceGerceklesenRaporuDataSource _butceGerceklesenRaporuDataSource;
  List<String> butceler = [];

  String secilenButce = "";
  String tempButce = "";

  List<ButceGerceklesenRapor> aramaList = [];



  bool donemFiltreMi = false;
  bool stokHizmetMi = false;

  bool tapSending = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _butceGerceklesenRaporuDataSource = ButceGerceklesenRaporuDataSource(_dataGridController);
    AutoOrientation.fullAutoMode();
    _butceleriGetir();
    _donemFiltreler.clear();
    _stokHizmetFiltreler.clear();
    _donemFiltreList.clear();
    _stokHizmetFiltreList.clear();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    butceGerceklesenRaporGridList.clear();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid()) : Scaffold(
          appBar: AppBar(
            title: Text("Bütçe Gerçekleşen"),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
            actions: [
              IconButton(icon: FaIcon(FontAwesomeIcons.fileExcel), onPressed: () {
                if(butceGerceklesenRaporGridList.isEmpty) return;
                if(tapSending) return;
                _exportExcel();

              }),
              donemFiltreMi || stokHizmetMi
                  ? Stack(
                alignment: Alignment(0,5),
                children: [
                  Container(
                    color: Colors.red,
                  ),
                  Text(
                      "${_stokHizmetFiltreler.length + _donemFiltreler.length}",
                      style: TextStyle(color: Colors.white)),
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.filter),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) => _filtreDialog()).then((value) {
                          print(value);
                          if (_donemFiltreler.isNotEmpty) {
                            setState(() {
                              donemFiltreMi = true;
                            });
                          } else {
                            donemFiltreMi = false;
                          }

                          if (_stokHizmetFiltreler.isNotEmpty) {
                            setState(() {
                              stokHizmetMi = true;
                            });
                          } else {
                            stokHizmetMi = false;
                          }

                        });
                      }),
                ],
              )
                  : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.filter),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => _filtreDialog()).then((value) {
                      print(value);
                      if (_donemFiltreler.isNotEmpty) {
                        setState(() {
                          donemFiltreMi = true;
                        });
                      } else {
                        donemFiltreMi = false;
                      }

                      if (_stokHizmetFiltreler.isNotEmpty) {
                        setState(() {
                          stokHizmetMi = true;
                        });
                      } else {
                        stokHizmetMi = false;
                      }

                    });
                  }),
            ],
          ),
          body: Column(
            children: [
              InkWell(
                child:  Container(
                  decoration: Sabitler.dreamBoxDecoration,
                  margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(secilenButce.isNotEmpty ? secilenButce : "Bütçe seçmek için dokunun",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                ),
                onTap: () {
                  Picker(
                    adapter: PickerDataAdapter(
                        data: List.generate(butceler.length, (index) =>
                            PickerItem(text: Center(child: Text(butceler[index],style: TextStyle(fontSize: 18),),),value: butceler[index]))
                    ),
                    title: Text("Bütçe Seçiniz"),
                    textAlign: TextAlign.right,
                    onConfirm:  (Picker picker, List<int> selecteds) {
                      secilenButce = picker.adapter.getSelectedValues().first;
                      _butceDetayGetir(secilenButce);
                      setState(() {});
                    },
                    selectedTextStyle: TextStyle(color: Colors.blue),
                    cancelTextStyle: TextStyle(color: Colors.red),
                    confirmText: "Onayla",
                    cancelText: "İptal",
                    hideHeader: true,

                  ).showDialog(context);
                },
              ),
              !loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) : Expanded(child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: _grid(),
              ),)
            ],
          ),
        )
    );
  }

  _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        source: _butceGerceklesenRaporuDataSource,
        controller: _dataGridController,
        selectionMode: SelectionMode.single,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        columns: <GridColumn> [
          dreamColumn(columnName: 'sira',label : "SIRA",visible: false),
          dreamColumn(columnName: 'donem',label : "DÖNEM",),
          dreamColumn(columnName: 'stokHizmetDetayKodu',label : "STOK HİZMET DETAY KODU",),
          dreamColumn(columnName: 'hedeflenenTlSatis',label : "HEDEFLENEN TL SATIŞ",),
          dreamColumn(columnName: 'gerceklesenTlSatis',label : "GERÇEKLEŞEN TL SATIŞ",),
          dreamColumn(columnName: 'tlSatisFarki',label : "TL SATIŞ FARKI",),
          dreamColumn(columnName: 'hedeflenenAltDovizSatis',label : "HEDEFLENEN ALT.DÖVİZ SATIŞ",),
          dreamColumn(columnName: 'gerceklesenAltDovizSatis',label : "GERÇEKLEŞEN ALT.DÖVİZ SATIŞ",),
          dreamColumn(columnName: 'altDovizSatisFarki',label : "ALT.DÖVİZ SATIŞ FARKI",),

        ],
      ),
    );
  }
  _butceDetayGetir(String butce) async {
    late http.Response response;
    try {
      var body = jsonEncode({
        "vtIsim": UserInfo.activeDB,
        "butce": butce,
      });
      loading = !loading;
      response  = await http.post(Uri.parse("${Sabitler.url}/api/ButcelerDetay"),
          headers: {
            "apiKey": Sabitler.apiKey,
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: body);
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
    butceGerceklesenRaporGridList.clear();
    _donemFiltreler.clear();
    _stokHizmetFiltreler.clear();
    _donemFiltreList.clear();
    _stokHizmetFiltreList.clear();
    donemFiltreMi = false;
    stokHizmetMi = false;

    if(response.statusCode == 200) {
      var cekDetay = jsonDecode(response.body);
      for(var cek in cekDetay){
        ButceGerceklesenRapor bgr = ButceGerceklesenRapor.fromMap(cek);
        butceGerceklesenRaporGridList.add(bgr);

        bool addT = true;
        bool addS = true;
        for (var map in _donemFiltreList) {
          if (map["value"] == bgr.donem) {
            addT = false;
          }
        }
        for (var map in _stokHizmetFiltreList) {
          if (map["value"] == bgr.stokHizmetDetayKodu) {
            addS = false;
          }
        }
        if (addS) {
          _stokHizmetFiltreList
              .add({"grup": "Stok Hizmet Detay Kodu", "value": bgr.stokHizmetDetayKodu});
        }
        if (addT) {
          _donemFiltreList
              .add({"grup": "Dönem", "value": bgr.donem});
        }
      }
      aramaList = butceGerceklesenRaporGridList;
      _butceGerceklesenRaporuDataSource = ButceGerceklesenRaporuDataSource(_dataGridController);
      loading = !loading;
      setState(() {

      });
    }
  }


  _butceleriGetir() async {
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/Butceler?vtIsim=${UserInfo.activeDB}"),
          headers: {
            "apiKey": Sabitler.apiKey,
            'Content-Type': 'application/json; charset=UTF-8',
          });
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

        var decoded = jsonDecode(response.body);
        for(var map in decoded){
          butceler.add(map['butce']);
        }
      });
    }
  }


  Widget _filtreDialog() {
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 150,
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
                  child: Container(
                    child: SmartSelect<String?>.multiple(
                        title: 'Dönem Filtre',
                        placeholder: 'Dönem Filtrele',
                        selectedValue: _donemFiltreler,
                        modalHeaderStyle: S2ModalHeaderStyle(
                            backgroundColor: Colors.blue.shade900),
                        onChange: (state) =>
                            setState(() => _donemFiltreler = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: _donemFiltreList,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['value'],
                          group: (index, item) => item['grup'],
                        ),
                        onModalClose: (c,s){
                          print(c);
                          print(s);
                        },
                        modalFooterBuilder: (context, v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ], color: Colors.red),
                                  child: Center(
                                    child: Text("Temizle",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                onTap: () async {
                                  v.selection!.clear();
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0);
                                  setState(() {
                                    _gridAra([], _stokHizmetFiltreler);
                                    donemFiltreMi = false;
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ], color: Colors.grey.shade500),
                                  child: Center(
                                    child: Text(
                                      "Filtreyle Arama Yap",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  v.onChange();
                                  if (_donemFiltreler.length > 0) {
                                    setState(() {
                                      donemFiltreMi = true;
                                    });
                                  } else {
                                    donemFiltreMi = false;
                                  }
                                  v.closeModal();
                                  _gridAra(
                                      _donemFiltreler, _stokHizmetFiltreler);
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
                        choiceEmptyBuilder: (context, s) {
                          return Container(
                            child: Center(
                              child: Text("FİLTRE BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if (donemFiltreMi) {
                            return Stack(
                              alignment: Alignment(15,20),
                              children: [
                                Container(
                                  color: Colors.red,
                                ), Text("${_donemFiltreler.length}",
                                    style: TextStyle(color: Colors.white)),
                                InkWell(
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          "Dönem",
                                          style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(top: 10),
                                    ),
                                    onTap: () async {
                                      state.showModal();
                                    }),
                              ],
                            );
                          } else {
                            return InkWell(
                                child: Container(
                                  child: Center(
                                    child: Text(
                                      "Dönem",
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                  ),
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                onTap: () async {
                                  state.showModal();
                                });
                          }
                        }),
                  ),
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    child: SmartSelect<String?>.multiple(
                        title: 'Stok Hizmet Detay Kodu',
                        placeholder: 'Stok Hizmet Detay Kodu Filtrele',
                        selectedValue: _stokHizmetFiltreler,
                        modalHeaderStyle: S2ModalHeaderStyle(
                            backgroundColor: Colors.blue.shade900),
                        onChange: (state) =>
                            setState(() => _stokHizmetFiltreler = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: _stokHizmetFiltreList,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['value'],
                          group: (index, item) => item['grup'],
                        ),
                        modalFooterBuilder: (context, v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ], color: Colors.red),
                                  child: Center(
                                    child: Text("Temizle",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                onTap: () async {
                                  v.selection!.clear();
                                  setState(() {
                                    stokHizmetMi = false;
                                    _gridAra(_donemFiltreler, []);
                                  });
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0);
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(2, 5),
                                    ),
                                  ], color: Colors.grey.shade500),
                                  child: Center(
                                    child: Text(
                                      "Filtreyle Arama Yap",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  v.onChange();
                                  setState(() {
                                    if (_stokHizmetFiltreler.length > 0) {
                                      stokHizmetMi = true;
                                    } else {
                                      stokHizmetMi = false;
                                    }
                                  });
                                  v.closeModal();
                                  _gridAra(
                                      _donemFiltreler, _stokHizmetFiltreler);
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
                        choiceEmptyBuilder: (context, s) {
                          return Container(
                            child: Center(
                              child: Text("STOK FİLTRESİ BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if (stokHizmetMi) {
                            return Stack(
                              alignment: Alignment(10,20),
                              children: [
                                Container(
                                  color: Colors.red,
                                ),
                                Text(
                                  "${_stokHizmetFiltreler.length}",
                                  style: TextStyle(color: Colors.white),
                                ), InkWell(
                                    child: Container(
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "Stok Hizmet Detay Kodu",
                                            style: TextStyle(
                                                color: Colors.blue.shade900,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(bottom: 0),
                                    ),
                                    onTap: () async {
                                      state.showModal();
                                    }),
                              ],
                            );
                          } else {
                            return InkWell(
                                child: Container(
                                  child: Center(
                                    child: FittedBox(
                                      child: Text(
                                        "Stok Hizmet Detay Kodu",
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.only(bottom: 0),
                                ),
                                onTap: () async {
                                  state.showModal();
                                });
                          }
                        }),
                  ),
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Container(
                            child: Center(
                              child: Text(
                                "Temizle",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _donemFiltreler = [];
                              _stokHizmetFiltreler = [];
                              stokHizmetMi = false;
                              donemFiltreMi = false;
                              _gridAra([], []);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                          child: InkWell(
                            child: Container(
                              child: Center(
                                child: Text(
                                  "Tamam",
                                  style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ))
                    ],
                  ))
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }


  _gridAra(List<String?> a, List<String?> b) {
    List<ButceGerceklesenRapor> arananlarList = [];
    if (a.isEmpty && b.isEmpty) {
      setState(() {
        butceGerceklesenRaporGridList = aramaList;

        _butceGerceklesenRaporuDataSource =
            ButceGerceklesenRaporuDataSource(_dataGridController);
      });
      return;
    }
    if (a.isNotEmpty && b.isEmpty) {
      for (var value in aramaList) {
        if (a.contains(value.donem)) {
          arananlarList.add(value);
        }
      }
      setState(() {
        butceGerceklesenRaporGridList = arananlarList;

        _butceGerceklesenRaporuDataSource =
            ButceGerceklesenRaporuDataSource(_dataGridController);
      });
      return;
    }
    if (a.isEmpty && b.isNotEmpty) {
      for (var value in aramaList) {
        if (b.contains(value.stokHizmetDetayKodu)) {
          arananlarList.add(value);
        }
      }
      setState(() {
        butceGerceklesenRaporGridList = arananlarList;

        _butceGerceklesenRaporuDataSource =
            ButceGerceklesenRaporuDataSource(_dataGridController);
      });
      return;
    }
    for (var value in aramaList) {
      if (a.contains(value.donem) && b.contains(value.stokHizmetDetayKodu)) {
        arananlarList.add(value);
      }
    }
    setState(() {
      butceGerceklesenRaporGridList = arananlarList;

      _butceGerceklesenRaporuDataSource = ButceGerceklesenRaporuDataSource(_dataGridController);
    });
  }



  _exportExcel() async{
    tapSending= true;


    final sync.Workbook workbook = sync.Workbook();
    final sync.Worksheet sheet = workbook.worksheets[0];

    sheet.name = "Sayfa1";

    for(int i = 0; i< butceGerceklesenRaporGridList.length+1; i++){
      if(i == 0){
        var cell = sheet.getRangeByName("A1");
        cell.value = "DÖNEM";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("B1");
        cell.value = "STOK HİZMET DETAY KODU";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("C1");
        cell.value = "HEDEFLENEN TL SATIŞ";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("D1");
        cell.value = "GERÇEKLEŞEN TL SATIŞ";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("E1");
        cell.value = "TL SATIŞ FARKI";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("F1");
        cell.value = "HEDEFLENEN ALT. DÖVİZ SATIŞ";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("G1");
        cell.value = "GERÇEKLEŞEN ALT. DÖVİZ SATIŞ";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("H1");
        cell.value = "ALT. DÖVİZ SATIŞ FARKI";
        cell.cellStyle.backColor = "#C6C6C6";
        cell.cellStyle.fontColor = "#000000";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
      }else if(butceGerceklesenRaporGridList[i-1].stokHizmetDetayKodu == "Toplam" || butceGerceklesenRaporGridList[i-1].stokHizmetDetayKodu == "Toplamı"){
        var cell = sheet.getRangeByName("A${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].donem;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("B${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].stokHizmetDetayKodu;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("C${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].hedeflenenTlSatis;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("D${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].gerceklesenTlSatis;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("E${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].tlSatisFarki;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("F${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].hedeflenenAltDovizSatis;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("G${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].gerceklesenAltDovizSatis;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("H${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].altDovizSatisFarki;
        cell.cellStyle.backColor = "#4caf50";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
      }else{
        var cell = sheet.getRangeByName("A${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].donem;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("B${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].stokHizmetDetayKodu;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("C${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].hedeflenenTlSatis;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("D${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].gerceklesenTlSatis;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("E${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].tlSatisFarki;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("F${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].hedeflenenAltDovizSatis;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("G${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].gerceklesenAltDovizSatis;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
        cell = sheet.getRangeByName("H${i+1}");
        cell.value = butceGerceklesenRaporGridList[i-1].altDovizSatisFarki;
        cell.cellStyle.backColor = "#ffffff";
        cell.cellStyle.borders.all.color  = "#000000";
        cell.cellStyle.borders.all.lineStyle = sync.LineStyle.thin;
      }
    }
    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);
    sheet.autoFitColumn(3);
    sheet.autoFitColumn(4);
    sheet.autoFitColumn(5);
    sheet.autoFitColumn(6);
    sheet.autoFitColumn(7);
    sheet.autoFitColumn(8);
    Directory appDocDir = await getApplicationDocumentsDirectory();


    final List<int> bytes = workbook.saveAsStream();
    await File("${appDocDir.path}/Butce_gerceklesen_rapor.xlsx").writeAsBytes(bytes);
    workbook.dispose();

    await send("${appDocDir.path}/Butce_gerceklesen_rapor.xlsx");

    return;

  }


  Future<void> send(String path) async {
    Share.shareFiles([path]);
    tapSending= false;
  }


}











class ButceGerceklesenRaporuDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = butceGerceklesenRaporGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'sira',value: e.sira),
          DataGridCell<String>(columnName: 'donem',value: e.donem),
          DataGridCell<String>(columnName: 'stokHizmetDetayKodu',value: e.stokHizmetDetayKodu),
          DataGridCell<double>(columnName: 'hedeflenenTlSatis',value: e.hedeflenenTlSatis),
          DataGridCell<double>(columnName: 'gerceklesenTlSatis',value: e.gerceklesenTlSatis),
          DataGridCell<double>(columnName: 'tlSatisFarki',value: e.tlSatisFarki),
          DataGridCell<double>(columnName: 'hedeflenenAltDovizSatis',value: e.hedeflenenAltDovizSatis),
          DataGridCell<double>(columnName: 'gerceklesenAltDovizSatis',value: e.gerceklesenAltDovizSatis),
          DataGridCell<double>(columnName: 'altDovizSatisFarki',value: e.altDovizSatisFarki),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  ButceGerceklesenRaporuDataSource(this.dataGridController) {
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
      if(effectiveRows[index].getCells()[0].value != 1){
        return Colors.green;
      }
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