import 'dart:async';
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import '../cariler/cari_satislar_view.dart';
import '../stoklar/HorizontalPage.dart';
import '../stoklar/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../modeller/GridModeller.dart';
import '../modeller/Listeler.dart';
import '../modeller/Modeller.dart';
import '../widgets/Dialoglar.dart';
import '../widgets/DreamCogsGif.dart';
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';

class SatisTahsilatAnaliziSayfasi extends StatefulWidget {
  const SatisTahsilatAnaliziSayfasi({Key? key}) : super(key: key);

  @override
  _SatisTahsilatAnaliziSayfasiState createState() =>
      _SatisTahsilatAnaliziSayfasiState();
}

final List<Map<String, dynamic>> temsilciFiltreList = [];
List<String?> _temsilciFiltreler = [];

final List<Map<String, dynamic>> sektorFiltreList = [];
List<String?> _sektorFiltreler = [];

final List<Map<String, dynamic>> carikodFiltreList = [];
List<String?> _carikodFiltreler = [];

final List<Map<String, dynamic>> bolgeFiltreList = [];
List<String?> _bolgeFiltreler = [];

class _SatisTahsilatAnaliziSayfasiState
    extends State<SatisTahsilatAnaliziSayfasi> {
  bool loading = true;
  DateTime secilenTarih1 = DateTime.now();
  DateTime secilenTarih2 = DateTime.now();
  DateTime now = DateTime.now();

  DataGridController _satisTahsilatAnaliziSayfasiController =
  DataGridController();
  late SatisTahsilatlarAnaliziDataSource _satisTahsilatlarAnaliziDataSource;

  bool temsilciFiltreMi = false;
  bool sektorFiltreMi = false;
  bool carikodFiltreMi = false;
  bool bolgeFiltreMi = false;

  List<SatisTahsilatlarAnaliziGridModel> aramaList = [];

  @override
  void initState() {
    super.initState();
    _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(
        _satisTahsilatAnaliziSayfasiController);
    Fluttertoast.showToast(
        msg: "İstediğiniz satıra dokunarak neler satıldığını görebilirsiniz",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.blue.shade900,
        fontSize: 14.0);
    _satisTahsilatAnaliziGetir();
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    super.dispose();
    if (!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: currentOrientation == Orientation.landscape &&
            !TelefonBilgiler.isTablet
            ? HorizontalPage(_grid())
            : Scaffold(
          appBar: AppBar(
            title: const Image(
              image: AssetImage("assets/images/b2b_isletme_v3.png"),
              width: 150,
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
            actions: [
              temsilciFiltreMi || sektorFiltreMi
                  ? Stack(
                alignment: Alignment(0,5),
                children: [
                  Container(
                    color: Colors.red,
                  ),Text(
                      "${_sektorFiltreler.length + _temsilciFiltreler.length + _carikodFiltreler.length + _bolgeFiltreler.length}",
                      style: TextStyle(color: Colors.white)),
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.filter),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) => _filtreDialog());
                      }),
                ],
              )
                  : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.filter),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => _filtreDialog());
                  }),
            ],
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
                      child: Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.2 -
                              25,
                          child: Center(
                            child: Text(
                                "${DateFormat('dd-MM-yyyy').format(secilenTarih1)}",
                                style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold))),
                          )),
                      onTap: () => callDatePicker(1),
                    ),
                    InkWell(
                      child: Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2.2 -
                              25,
                          child: Center(
                            child: Text(
                                "${DateFormat('dd-MM-yyyy').format(secilenTarih2)}",
                                style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold))),
                          )),
                      onTap: () => callDatePicker(2),
                    ),
                    InkWell(
                        child: Container(
                            decoration: Sabitler.dreamBoxDecoration,
                            margin: EdgeInsets.only(right: 1),
                            height: 50,
                            width: 50,
                            child: Center(
                                child: Icon(
                                  Icons.search,
                                  color: Colors.blue.shade900,
                                ))),
                        onTap: () => _satisTahsilatAnaliziGetir()),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                    color: Colors.blue.shade900,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text("SATIŞ TAHSİLAT ANALİZİ",
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  )),
              !loading
                  ? Container(
                child: DreamCogs(),
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4),
              )
                  : Expanded(
                  child: Container(
                      margin: EdgeInsets.only(
                          bottom: 1, left: 1, right: 1),
                      child: _grid()))
            ],
          ),
        ));
  }

  _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _satisTahsilatlarAnaliziDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        controller: this._satisTahsilatAnaliziSayfasiController,
        columns: <GridColumn>[
          dreamColumn(
              columnName: 'cari',
              label: "CARİ KOD",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'unvan',
              label: "CARİ ÜNVAN",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'sektor',
              label: "SEKTÖR",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'grup',
              label: "GRUP",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'temsilci',
              label: "TEMSİLCİ",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'bolge',
              label: "BÖLGE",
              alignment: Alignment.centerLeft),
          dreamColumn(
            columnName: 'netSatis',
            label: "NET SATIŞ",
          ),
          dreamColumn(
            columnName: 'kdvDahil',
            label: "KDV DAHİL",
          ),
          dreamColumn(
            columnName: 'nakitTahsilat',
            label: "NAKİT TAHSİLAT",
          ),
          dreamColumn(
            columnName: 'cekTah',
            label: "ÇEK TAHSİLAT",
          ),
          dreamColumn(
            columnName: 'senetTah',
            label: "SENET TAHSİLAT",
          ),
          dreamColumn(
            columnName: 'toplamTahsilat',
            label: "TOPLAM TAHSİLAT",
          ),
        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async {
            if (v.rowColumnIndex.rowIndex > 0) {
              FocusScope.of(context).requestFocus(new FocusNode());
              var row = _satisTahsilatAnaliziSayfasiController.selectedRow!
                  .getCells();
              String? cariKod = row[0].value;
              String cariUnvan = row[1].value;
              if (cariUnvan != "TOPLAM") {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: CariSatislarView("$cariKod", cariUnvan)));
              }
            }
          });
        },
      ),
    );
  }

  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr', ''),
      helpText: "TARİH SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: now,
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.from(
              colorScheme: ColorScheme.light(
                  background: Colors.white,
                  onSurface: Colors.black,
                  primary: Colors.blue.shade900)),
          child: child!,
        );
      },
    );
  }

  void callDatePicker(int secilenTarih) async {
    var order = await getDate();
    if (order != null) {
      if (secilenTarih == 1) {
        setState(() {
          secilenTarih1 = order;
          now = order;
        });
      } else {
        setState(() {
          secilenTarih2 = order;
          now = order;
        });
      }
    }
  }

  _satisTahsilatAnaliziGetir() async {
    setState(() {
      loading = false;
    });
    satisTahsilatlarAnaliziGridList.clear();
    late http.Response response;
    try {
      response = await http.get(
          Uri.parse(
              "${Sabitler.url}/api/SatisTahsilatAnalizi?tarih1=${DateFormat('dd/MM/yyyy').format(secilenTarih1)}&tarih2=${DateFormat('dd-MM-yyyy').format(secilenTarih2)}&"
                  "vtName=${UserInfo.activeDB}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&"
                  "UserId=${UserInfo.activeUserId}"),
          headers: {"apiKey": Sabitler.apiKey}).timeout(Duration(seconds: 30));
    } on TimeoutException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    } on Error catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    }
    if (response.statusCode == 200) {
      var analizDetay = jsonDecode(response.body);
      for (var analiz in analizDetay) {
        SatisTahsilatlarAnaliziGridModel satisTahsilatlarAnaliziGridModel =
        SatisTahsilatlarAnaliziGridModel(
            analiz['Cari'],
            analiz['Unvan'],
            analiz['Sektör'],
            analiz['Grup'],
            analiz['Temsilci'],
            analiz['Bölge'],
            analiz['Net Satış'],
            analiz['KDV Dahil'],
            analiz['Nakit Tahsilat'],
            analiz['Çek Tah.'],
            analiz['Senet Tah.'],
            analiz['Toplam Tahsilat']);
        satisTahsilatlarAnaliziGridList.add(satisTahsilatlarAnaliziGridModel);
        bool addC = true;
        bool addS = true;
        bool addT = true;
        bool addB = true;
        for (var map in carikodFiltreList) {
          if (map["value"] == "${analiz["CARİ KOD"]} - ${analiz["CARİ AD"]}")
            addC = false;
        }
        for (var map in sektorFiltreList) {
          if (map["value"] == analiz["Sektör"]) addS = false;
        }
        for (var map in temsilciFiltreList) {
          if (map["value"] == analiz["Temsilci"]) addT = false;
        }
        for (var map in bolgeFiltreList) {
          if (map["value"] == analiz["Bölge"]) addB = false;
        }
        if (addC) {
          carikodFiltreList.add({
            "grup": "Cari Kodu",
            "value": "${analiz["Cari"]} - ${analiz["Unvan"]}"
          });
        }
        if (addS && analiz["Sektör"] != "") {
          sektorFiltreList.add({"grup": "Sektör", "value": analiz["Sektör"]});
        }
        if (addT && analiz["Temsilci"] != "") {
          temsilciFiltreList
              .add({"grup": "Temsilci", "value": analiz["Temsilci"]});
        }
        if (addB && analiz["Bölge"] != "") {
          bolgeFiltreList.add({"grup": "Bölge", "value": analiz["Bölge"]});
        }
      }
      setState(() {
        _carikodFiltreler.clear();
        _sektorFiltreler.clear();
        _temsilciFiltreler.clear();
        _bolgeFiltreler.clear();
        carikodFiltreMi = false;
        sektorFiltreMi = false;
        temsilciFiltreMi = false;
        bolgeFiltreMi = false;
        aramaList = satisTahsilatlarAnaliziGridList;
      });
    }
    setState(() {
      _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(
          _satisTahsilatAnaliziSayfasiController);
      loading = true;
    });
    Future.delayed(Duration(milliseconds: 50), () async {
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  Widget _filtreDialog() {
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 200,
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
                      title: 'Cari Filtre',
                      placeholder: 'Cari Filtrele',
                      selectedValue: _carikodFiltreler,
                      modalHeaderStyle: S2ModalHeaderStyle(
                          backgroundColor: Colors.blue.shade900),
                      onChange: (state) =>
                          setState(() => _carikodFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: carikodFiltreList,
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
                                Fluttertoast.showToast(
                                    msg: "Filtreler temizlendi.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 16.0);
                                setState(() {
                                  _gridAra(_carikodFiltreler, _sektorFiltreler,
                                      _temsilciFiltreler, _bolgeFiltreler);
                                  carikodFiltreMi = false;
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
                                if (_carikodFiltreler.length > 0) {
                                  setState(() {
                                    carikodFiltreMi = true;
                                  });
                                } else {
                                  carikodFiltreMi = false;
                                }
                                v.closeModal();
                                _gridAra(_carikodFiltreler, _sektorFiltreler,
                                    _temsilciFiltreler, _bolgeFiltreler);
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
                        return const Center(
                          child: Text("FİLTRE BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if (carikodFiltreMi) {
                          return Stack(
                            alignment: Alignment(5,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),
                              Text("${_carikodFiltreler.length}",
                                  style: TextStyle(color: Colors.white)),
                              InkWell(
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        "Cari",
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
                                    "Cari",
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
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: InkWell(
                  child: SmartSelect<String?>.multiple(
                      title: 'Temsilci Filtre',
                      placeholder: 'Temsilci Filtrele',
                      selectedValue: _temsilciFiltreler,
                      modalHeaderStyle: S2ModalHeaderStyle(
                          backgroundColor: Colors.blue.shade900),
                      onChange: (state) =>
                          setState(() => _temsilciFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: temsilciFiltreList,
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
                                Fluttertoast.showToast(
                                    msg: "Filtreler temizlendi.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 16.0);
                                setState(() {
                                  _gridAra(_carikodFiltreler, _sektorFiltreler,
                                      _temsilciFiltreler, _bolgeFiltreler);
                                  temsilciFiltreMi = false;
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
                                if (_temsilciFiltreler.length > 0) {
                                  setState(() {
                                    temsilciFiltreMi = true;
                                  });
                                } else {
                                  temsilciFiltreMi = false;
                                }
                                v.closeModal();
                                _gridAra(_carikodFiltreler, _sektorFiltreler,
                                    _temsilciFiltreler, _bolgeFiltreler);
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
                        if (temsilciFiltreMi) {
                          return Stack(
                            alignment: Alignment(8,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),
                              Text("${_temsilciFiltreler.length}",
                                  style: TextStyle(color: Colors.white)),
                              InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Temsilci",
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                    padding: EdgeInsets.only(top: 0),
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
                                    "Temsilci",
                                    style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                  ),
                                ),
                                padding: EdgeInsets.only(top: 0),
                              ),
                              onTap: () async {
                                state.showModal();
                              });
                        }
                      }),
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
                        title: 'Sektör',
                        placeholder: 'Sektör Kodu Filtrele',
                        selectedValue: _sektorFiltreler,
                        modalHeaderStyle: S2ModalHeaderStyle(
                            backgroundColor: Colors.blue.shade900),
                        onChange: (state) =>
                            setState(() => _sektorFiltreler = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: sektorFiltreList,
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
                                    sektorFiltreMi = false;
                                    _gridAra(
                                        _carikodFiltreler,
                                        _sektorFiltreler,
                                        _temsilciFiltreler,
                                        _bolgeFiltreler);
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
                                    if (_sektorFiltreler.length > 0) {
                                      sektorFiltreMi = true;
                                    } else {
                                      sektorFiltreMi = false;
                                    }
                                  });
                                  v.closeModal();
                                  _gridAra(_carikodFiltreler, _sektorFiltreler,
                                      _temsilciFiltreler, _bolgeFiltreler);
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
                          if (sektorFiltreMi) {
                            return Stack(
                              alignment: Alignment(8,20),
                              children: [
                                Container(
                                  color: Colors.red,
                                ),
                                Text(
                                  "${_sektorFiltreler.length}",
                                  style: TextStyle(color: Colors.white),
                                ),InkWell(
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          "Sektör",
                                          style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
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
                                    child: Text("Sektör",
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
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
                child: InkWell(
                  child: SmartSelect<String?>.multiple(
                      title: 'Bölge',
                      placeholder: 'Bölge Filtrele',
                      selectedValue: _bolgeFiltreler,
                      modalHeaderStyle: S2ModalHeaderStyle(
                          backgroundColor: Colors.blue.shade900),
                      onChange: (state) =>
                          setState(() => _bolgeFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: bolgeFiltreList,
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
                                  bolgeFiltreMi = false;
                                  _gridAra(_carikodFiltreler, _sektorFiltreler,
                                      _temsilciFiltreler, _bolgeFiltreler);
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
                                  if (_bolgeFiltreler.length > 0) {
                                    bolgeFiltreMi = true;
                                  } else {
                                    bolgeFiltreMi = false;
                                  }
                                });
                                v.closeModal();
                                _gridAra(_carikodFiltreler, _sektorFiltreler,
                                    _temsilciFiltreler, _bolgeFiltreler);
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
                          alignment: Alignment.center,
                          child: Text("FİLTRE BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if (bolgeFiltreMi) {
                          return Stack(
                            alignment: Alignment(8,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),Text(
                                "${_bolgeFiltreler.length}",
                                style: TextStyle(color: Colors.white),
                              ),InkWell(
                                  child: Container(
                                    child: Center(
                                      child: Text("Bölge",
                                        style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
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
                                  child: Text(
                                    "Bölge",
                                    style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
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
                            alignment: Alignment.center,
                            child: Text(
                              "Temizle",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _temsilciFiltreler = [];
                              _sektorFiltreler = [];
                              sektorFiltreMi = false;
                              temsilciFiltreMi = false;
                              _gridAra([], [], [], []);
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

  _gridAra(List<String?> a, List<String?> b, List<String?> c, List<String?> d) {
    List<SatisTahsilatlarAnaliziGridModel> arananlarList = [];

    for (var value in aramaList) {
      if ((a.contains("${value.cari} - ${value.unvan}") || a.isEmpty) &&
          (b.contains(value.sektor) || b.isEmpty) &&
          (c.contains(value.temsilci) || c.isEmpty) &&
          (d.contains(value.bolge) || d.isEmpty)) {
        print("test");
        arananlarList.add(value);
      }
    }
    setState(() {
      satisTahsilatlarAnaliziGridList = arananlarList;

      _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(
          _satisTahsilatAnaliziSayfasiController);
    });
  }
}

class SatisTahsilatlarAnaliziDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRows() {
    dataGridRows = satisTahsilatlarAnaliziGridList
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'cari', value: e.cari),
      DataGridCell<String>(columnName: 'unvan', value: e.unvan),
      DataGridCell<String>(columnName: 'sektor', value: e.sektor),
      DataGridCell<String>(columnName: 'grup', value: e.grup),
      DataGridCell<String>(columnName: 'temsilci', value: e.temsilci),
      DataGridCell<String>(columnName: 'bolge', value: e.bolge),
      DataGridCell<double>(columnName: 'netSatis', value: e.netSatis),
      DataGridCell<double>(columnName: 'kdvDahil', value: e.kdvDahil),
      DataGridCell<double>(columnName: 'nakitTahsilat', value: e.nakitTahsilat),
      DataGridCell<double>(columnName: 'cekTah', value: e.cekTah),
      DataGridCell<double>(columnName: 'senetTah', value: e.senetTah),
      DataGridCell<double>(columnName: 'toplamTahsilat', value: e.toplamTahsilat),
    ])).toList();
  }

  final DataGridController dataGridController;
  SatisTahsilatlarAnaliziDataSource(this.dataGridController) {
    buildDataGridRows();
  }
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    TextStyle getSelectionStyle() {
      if (dataGridController.selectedRows.contains(row)) {
        return (TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white));
      } else {
        return (TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black));
      }
    }

    Color getRowBackGroundColor() {
      final int index = effectiveRows.indexOf(row);
      if (index % 2 != 0) {
        return Colors.grey.shade300;
      } else {
        return Colors.white;
      }
    }

    return DataGridRowAdapter(
        color: getRowBackGroundColor(),
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: alignValue(e.value),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              e.value == null ? "" : formatValue(e.value).toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getSelectionStyle(),
            ),
          );
        }).toList());
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}
