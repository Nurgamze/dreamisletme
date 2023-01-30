import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
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
import 'package:sdsdream_flutter/yeni_formlar/YeniAdayCariForm.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'AdayCariDetaySayfasi.dart';

class AdayCarilerSayfasi extends StatefulWidget {
  @override
  _AdayCarilerSayfasiState createState() => _AdayCarilerSayfasiState();
}

class _AdayCarilerSayfasiState extends State<AdayCarilerSayfasi> {
  bool loading = true;
  TextEditingController _cariAramaController = new TextEditingController();
  String? arananKelime;
  String? secilenArama;
  List<String> aramaHelperList = [];

  final DataGridController _dataGridController = DataGridController();
  late AdayCarilerDataSource _adayCarilerDataSource;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    adayCarilerGridList.clear();
    if (!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _adayCarilerDataSource = AdayCarilerDataSource(_dataGridController);
    AutoOrientation.fullAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: currentOrientation == Orientation.landscape &&
                !TelefonBilgiler.isTablet
            ? HorizontalPage(_grid())
            : Scaffold(
                appBar: AppBar(
                  title: Container(
                      child: Image(
                    image: AssetImage("assets/images/b2b_isletme_v3.png"),
                    width: 150,
                  )),
                  centerTitle: true,
                  backgroundColor: Colors.blue.shade900,
                ),
                body: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5, left: 5),
                          child: Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Aday Cari arayın.',
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.blue.shade900,
                                      ),
                                      onPressed: () {
                                        //_dataGridController.selectedRow = null;
                                        _cariAramaController.text = "";
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      },
                                    )),
                                controller: _cariAramaController,
                              )),
                          decoration: Sabitler.dreamBoxDecoration,
                          width: screenWidth / 3 * 2 - 5,
                          height: 50,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          child: Container(
                              margin: EdgeInsets.only(top: 5),
                              decoration: Sabitler.dreamBoxDecoration,
                              width: screenWidth / 3 * 0.35,
                              height: 50,
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.search,
                                  color: Colors.blue.shade900,
                                  size: 18,
                                ),
                              )),
                          onTap: () async {
                            if (await Foksiyonlar.internetDurumu(context)) {
                              setState(() {
                                loading = false;
                                if (_cariAramaController.text == "") {
                                  arananKelime = "*";
                                } else {
                                  arananKelime = _cariAramaController.text;
                                }
                              });
                              adayCarilerGridList = [];
                              _adayCarilerGetir();
                            }
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            width: screenWidth / 3 * 0.65 - 10,
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.userPlus,
                                  color: Colors.blue.shade900,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "YENİ",
                                  style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => YeniAdayCariForm()));
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
                          color: Colors.blue.shade900,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text("ADAY CARİLER LİSTESİ",
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
                                child: _grid()),
                          ),
                  ],
                ),
              ));
  }

  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _adayCarilerDataSource,
        allowSorting: true,
        allowTriStateSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        controller: this._dataGridController,
        columns: <GridColumn>[
          dreamColumn(
              columnName: 'Kod',
              label: "ADAY KODU",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'unvan',
              label: "ÜNVAN",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'Yetkili',
              label: "YETKİLİ",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'YetkiliCep',
              label: "YETKİLİ CEP NO",
              alignment: Alignment.centerLeft),
          dreamColumn(
              columnName: 'Telefon',
              label: "TELEFON",
              alignment: Alignment.centerLeft),
        ],
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (value.rowColumnIndex.rowIndex > 0) {
              var row = _dataGridController.selectedRow!.getCells();
              AdayCarilerGridModel cari = adayCarilerGridList
                  .where((e) => e.Kod == row[0].value.toString())
                  .first;
              _dataGridController.selectedIndex = -1;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdayCariDetaySayfasi(data: cari),
                  ));
            }
          });
        },
      ),
    );
  }

  _adayCarilerGetir() async {
    var body = jsonEncode({
      "VtIsim": UserInfo.activeDB,
      "Arama": arananKelime!.replaceAll("*", "%").replaceAll("\'", "\''"),
      "Sektor": "",
      "Bolge": "",
      "Grup": "",
      "Temsilci": "",
      "Mobile": true,
      "DevInfo": TelefonBilgiler.userDeviceInfo,
      "AppVer": TelefonBilgiler.userAppVersion,
      "UserId": UserInfo.activeUserId
    });
    adayCarilerGridList.clear();
    late http.Response response;
    try {
      response = await http
          .post(Uri.parse("${Sabitler.url}/api/AdayCariler"),
              headers: {
                "apiKey": Sabitler.apiKey,
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: body)
          .timeout(Duration(seconds: 15));
    } on TimeoutException {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          });
    } on Error catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BilgilendirmeDialog(
                "Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          });
    }
    if (response.statusCode == 200) {
      var adayCariDetay = jsonDecode(response.body);
      for (var adayCari in adayCariDetay) {
        AdayCarilerGridModel adayCarilerGridModel = new AdayCarilerGridModel(
            adayCari["Sektor"],
            adayCari["Bolge"],
            adayCari["VergiDaireNo"],
            adayCari["KayID"].toString(),
            adayCari["Temsilci"],
            adayCari["unvan"],
            adayCari["Grup"],
            adayCari["KOD"],
            adayCari["Web"],
            adayCari["EMAIL"],
            adayCari["Yetkili"],
            adayCari["Telefon"],
            adayCari["TelBolge"],
            adayCari["YetkiliCep"],
            adayCari["Adres"],
            adayCari["YetkiliEPosta"]);
        adayCarilerGridList.add(adayCarilerGridModel);
      }
      setState(() {
        _adayCarilerDataSource = AdayCarilerDataSource(_dataGridController);
        loading = !loading;
      });
    }
    Future.delayed(Duration(milliseconds: 50), () async {
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
}

class AdayCarilerDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  final DataGridController dataGridController;

  AdayCarilerDataSource(this.dataGridController) {
    buildDataGridRows();
  }

  void buildDataGridRows() {
    dataGridRows = adayCarilerGridList
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'Kod', value: e.Kod),
              DataGridCell<String>(columnName: 'unvan', value: e.unvan),
              DataGridCell<String>(columnName: 'Yetkili', value: e.Yetkili),
              DataGridCell<String>(
                  columnName: 'YetkiliCep', value: e.YetkiliCep),
              DataGridCell<String>(
                  columnName: 'Telefon', value: "${e.TelBolge}${e.Telefon}"),
            ]))
        .toList();
    notifyListeners();
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
        return Colors.transparent;
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
