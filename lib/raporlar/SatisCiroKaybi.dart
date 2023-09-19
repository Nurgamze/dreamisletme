import 'dart:async';
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
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




class SatisCiroKaybiSayfasi extends StatefulWidget {
  const SatisCiroKaybiSayfasi({Key? key}) : super(key: key);

  @override
  _SatisCiroKaybiSayfasiState createState() => _SatisCiroKaybiSayfasiState();
}

final List<Map<String, dynamic>> temsilciFiltreList = [];
List<String?> _temsilciFiltreler = [];

final List<Map<String, dynamic>> sektorFiltreList = [];
List<String?> _sektorFiltreler = [];

class _SatisCiroKaybiSayfasiState extends State<SatisCiroKaybiSayfasi> {
  bool loading = false;

  bool temsilciFiltreMi = false;
  bool sektorFiltreMi = false;

  List<SatisCiroKaybiGridModel> aramaList = [];
  final DataGridController _dataGridController = DataGridController();
  late SatisCiroKaybiDataSource _satisCiroKaybiDataSource;

  @override
  void initState() {
    super.initState();
    AutoOrientation.fullAutoMode();
    _satisCiroKaybiDataSource = SatisCiroKaybiDataSource(_dataGridController);
    Fluttertoast.showToast(
        msg: "İstediğiniz satıra çift dokunarak cari kodu kopyalayabilirsiniz.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.blue.shade900,
        fontSize: 14.0);
    satisCiroKaybiGetir();
    _temsilciFiltreler.clear();
    _sektorFiltreler.clear();
  }

  @override
  void dispose() {
    super.dispose();
    if (!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
    portfoydekiCeklerGridList.clear();
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
            title: const Text("Satış/Ciro Kaybı"),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
            actions: [
              temsilciFiltreMi || sektorFiltreMi
                  ? Stack(
                alignment: Alignment(0,5),
                children: [
                  Container(
                    color: Colors.red,
                  ),
                  Text(
                      "${_sektorFiltreler.length + _temsilciFiltreler.length}",
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
          body: !loading
              ? Container(
            child: DreamCogs(),
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 4),
          )
              : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _grid(),
          ),
        ));
  }

  _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _satisCiroKaybiDataSource,
        allowSorting: true,
        allowTriStateSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        columns: <GridColumn>[
          dreamColumn(
              columnName: 'CARİ KOD',
              label: "CARİ KODU",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'CARI ISMI',
              label: "CARİ ÜNVAN",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'TEMSİLCİ',
              label: "CARİ TEMSİLCİ",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'SEKTÖR KODU',
              label: "SEKTÖR KODU",
              alignment: Alignment.centerLeft),
          dreamColumn(
            columnName: 'CİRO',
            label: "CİRO",
          ),
          dreamColumn(
            columnName: 'HareketliAySayisi',
            label: "HAREKETLİ AY SAYISI",
          ),
          dreamColumn(
            columnName: 'Hareketli Aylar Ortalaması',
            label: "HAREKETLİ AYLAR ORTALAMASI",
          ),
          dreamColumn(
            columnName: 'Hareket Bağımsız 12 Aylık Ortalama',
            label: "HAREKET BAĞIMSIZ 12 AYLIK ORTALAMA",
          ),
          dreamColumn(
            columnName: 'Ağırlıklı Ortalama Ciro Beklentisi',
            label: "AĞIRLIKLI ORTALAMA CİRO BEKLENTİSİ",
          ),
          dreamColumn(
            columnName: 'Son3AylıkOrtalamaCiro',
            label: "SON 3 AYLIK ORTALAMA CİRO",
          ),
          dreamColumn(
              columnName: 'Ciro Kaybı %',
              label: "SON 3 AYLIK CİRO KAYBI % YÜZDE",
              minWidth: 210),
          dreamColumn(
            columnName: 'Son6AylıkOrtalamaCiro',
            label: "SON 6 AYLIK ORTALAMA CİRO",
          ),
          dreamColumn(
              columnName: 'Ciro Kaybı % 6Ay',
              label: "SON 6 AYLIK CİRO KAYBI % YÜZDE",
              minWidth: 210),
        ],
        controller: this._dataGridController,
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async {
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
        onCellDoubleTap: (v) {
          Future.delayed(Duration(milliseconds: 100), () async {
            var row = _dataGridController.selectedRow!.getCells();
            String cariKod = row[0].value;
            FocusScope.of(context).requestFocus(new FocusNode());
            Clipboard.setData((new ClipboardData(text: cariKod)));
            Fluttertoast.showToast(
                msg: "$cariKod panoya kopyalandı.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                backgroundColor: Colors.blue.shade900,
                fontSize: 16.0);
          });
        },
      ),
    );
  }

  satisCiroKaybiGetir() async {
    late http.Response response;
    try {
      response = await http.get(
          Uri.parse("${Sabitler.url}/api/SatisCiroKaybi?"
              "FullAccess=${UserInfo.fullAccess}&"
              "Mobile=true&"
              "DevInfo=${TelefonBilgiler.userDeviceInfo}&"
              "AppVer=${TelefonBilgiler.userAppVersion}&"
              "UserId=${UserInfo.activeUserId}&"
              "dbName=${UserInfo.activeDB}"),
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
      setState(() {
        temsilciFiltreList.clear();
        sektorFiltreList.clear();
        satisCiroKaybiGridList.clear();
        var grid = jsonDecode(response.body);
        for (var detay in grid) {
          satisCiroKaybiGridList.add(SatisCiroKaybiGridModel(
              detay["CARİ KOD"],
              detay["CARI ISMI"],
              detay["TEMSİLCİ"],
              detay["SEKTÖR KODU"],
              detay["CİRO"],
              detay["HareketliAySayisi"],
              detay["Hareketli Aylar Ortalaması"],
              detay["Hareket Bağımsız 12 Aylık Ortalama"],
              detay["Ağırlıklı Ortalama Ciro Beklentisi"],
              detay["Son3AylıkOrtalamaCiro"],
              detay["Ciro Kaybı %"],
              detay["Son6AylıkOrtalamaCiro"],
              detay["Ciro Kaybı % 6Ay"]));
          bool addT = true;
          bool addS = true;
          for (var map in temsilciFiltreList) {
            if (map["value"] == detay["TEMSİLCİ"]) addT = false;
          }
          for (var map in sektorFiltreList) {
            if (map["value"] == detay["SEKTÖR KODU"]) addS = false;
          }
          if (addS) {
            sektorFiltreList
                .add({"grup": "Sektör Kodu", "value": detay["SEKTÖR KODU"]});
          }
          if (addT) {
            temsilciFiltreList
                .add({"grup": "Temsilci", "value": detay["TEMSİLCİ"]});
          }
        }
        aramaList = satisCiroKaybiGridList;
        _satisCiroKaybiDataSource =
            SatisCiroKaybiDataSource(_dataGridController);
        loading = !loading;
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
                                    _gridAra([], _sektorFiltreler);
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
                                  _gridAra(
                                      _temsilciFiltreler, _sektorFiltreler);
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
                              alignment: Alignment(15,20),
                              children: [
                                Container(
                                  color:Colors.red,
                                ),
                                Text("${_temsilciFiltreler.length}",
                                    style: TextStyle(color: Colors.white)),
                                InkWell(
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
                                      "Temsilci",
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
                                    _gridAra(_temsilciFiltreler, []);
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
                                  _gridAra(
                                      _temsilciFiltreler, _sektorFiltreler);
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
                          if (sektorFiltreMi) {
                            return Stack(
                              alignment: Alignment(10,20),
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
                                          "Sektör Kodu",
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
                                      "Sektör Kodu",
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
                              _temsilciFiltreler = [];
                              _sektorFiltreler = [];
                              sektorFiltreMi = false;
                              temsilciFiltreMi = false;
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
                          )
                      )
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
    List<SatisCiroKaybiGridModel> arananlarList = [];
    if (a.isEmpty && b.isEmpty) {
      print("dsa");
      print(aramaList);
      setState(() {
        satisCiroKaybiGridList = aramaList;

        _satisCiroKaybiDataSource =
            SatisCiroKaybiDataSource(_dataGridController);
      });
      return;
    }
    if (a.isNotEmpty && b.isEmpty) {
      for (var value in aramaList) {
        if (a.contains(value.cariTemsilci)) {
          print("test");
          arananlarList.add(value);
        }
      }
      setState(() {
        satisCiroKaybiGridList = arananlarList;

        _satisCiroKaybiDataSource =
            SatisCiroKaybiDataSource(_dataGridController);
      });
      return;
    }
    if (a.isEmpty && b.isNotEmpty) {
      for (var value in aramaList) {
        if (b.contains(value.sektor)) {
          arananlarList.add(value);
        }
      }
      setState(() {
        satisCiroKaybiGridList = arananlarList;

        _satisCiroKaybiDataSource =
            SatisCiroKaybiDataSource(_dataGridController);
      });
      return;
    }
    for (var value in aramaList) {
      if (a.contains(value.cariTemsilci) && b.contains(value.sektor)) {
        print("test");
        arananlarList.add(value);
      }
    }
    setState(() {
      satisCiroKaybiGridList = arananlarList;

      _satisCiroKaybiDataSource = SatisCiroKaybiDataSource(_dataGridController);
    });
  }
}

class SatisCiroKaybiDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRows() {
    dataGridRows = satisCiroKaybiGridList
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'CARİ KOD', value: e.cariKod),
      DataGridCell<String>(columnName: 'CARI ISMI', value: e.cariUnvan),
      DataGridCell<String>(
          columnName: 'TEMSİLCİ', value: e.cariTemsilci),
      DataGridCell<String>(columnName: 'SEKTÖR KODU', value: e.sektor),
      DataGridCell<double>(columnName: 'CİRO', value: e.ciro),
      DataGridCell<int>(
          columnName: 'HareketliAySayisi', value: e.hareketliAySayisi),
      DataGridCell<double>(
          columnName: 'Hareketli Aylar Ortalaması',
          value: e.hareketliAylarOrt),
      DataGridCell<double>(
          columnName: 'Hareket Bağımsız 12 Aylık Ortalama',
          value: e.hareketBagimsiz12AyOrt),
      DataGridCell<double>(
          columnName: 'Ağırlıklı Ortalama Ciro Beklentisi',
          value: e.agirlikliOrtCiroBeklentisi),
      DataGridCell<double>(
          columnName: 'Son3AylıkOrtalamaCiro',
          value: e.son3AylikOrtCiro),
      DataGridCell<double>(
          columnName: 'Ciro Kaybı %', value: e.son3AylikCiroKaybi),
      DataGridCell<double>(
          columnName: 'Son6AylıkOrtalamaCiro',
          value: e.son6AylikOrtCiro),
      DataGridCell<double>(
          columnName: 'Ciro Kaybı % 6Ay', value: e.son6AylikCiroKaybi),
    ]))
        .toList();
  }

  final DataGridController dataGridController;
  SatisCiroKaybiDataSource(this.dataGridController) {
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
