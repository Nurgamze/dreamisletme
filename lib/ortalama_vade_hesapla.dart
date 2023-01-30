import 'dart:async';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../modeller/GridModeller.dart';
import '../modeller/Listeler.dart';
import '../modeller/Modeller.dart';
import '../widgets/DreamCogsGif.dart';

class OVHSayfasi extends StatefulWidget {
  const OVHSayfasi({Key? key}) : super(key: key);

  @override
  _OVHSayfasiState createState() => _OVHSayfasiState();
}

class _OVHSayfasiState extends State<OVHSayfasi> {
  bool loading = true;
  DateTime secilenTarih1 =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  double toplam = 0;

  String vade = "0 Gün";

  final DataGridController _OVHSayfasiController = DataGridController();
  late OVHDataSource _ovhDataSource;

  final TextEditingController _tutarController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey.shade200,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
                (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "TAMAM",
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }



  @override
  void initState() {
    super.initState();
    _ovhDataSource = OVHDataSource(_OVHSayfasiController);
    Fluttertoast.showToast(
        msg: "Satır silmek için üstüne dokununuz",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
        backgroundColor: Colors.blue.shade900,
        fontSize: 14.0);
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    super.dispose();
    ovhGridList.clear();
    if (!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    return ConstScreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Image(
              image: AssetImage("assets/images/b2b_isletme_v3.png"),
              width: 150,
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: KeyboardActions(
              autoScroll: false,
              config: _buildConfig(context),
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    decoration: Sabitler.dreamBoxDecoration,
                    height: 55,
                    width: double.infinity,
                    child: Row(children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: 45,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Toplam",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(NumberFormat("#,##0.00").format(toplam))
                            ]),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: 45,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Ort. Vade",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(vade)
                            ]),
                      ),
                    ]),
                  ),
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
                              width: MediaQuery.of(context).size.width / 2.2 - 25,
                              child: Center(
                                child: Text(
                                    DateFormat('dd.MM.yyyy').format(secilenTarih1),
                                    style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue.shade900,
                                            fontWeight: FontWeight.bold))),
                              )),
                          onTap: () => callDatePicker(),
                        ),
                        Container(
                            decoration: Sabitler.dreamBoxDecoration,
                            padding: EdgeInsets.only(left: 5, right: 5, bottom: 7),
                            alignment: Alignment.center,
                            height: 50,
                            width: MediaQuery.of(context).size.width / 2.2 - 25,
                            child: TextFormField(
                              controller: _tutarController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              scrollPadding: EdgeInsets.all(0),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.]+')),],
                              decoration: InputDecoration(
                                hintText: "0.00",
                                border: InputBorder.none,
                              ),
                            )),
                        InkWell(
                            child: Container(
                                decoration: Sabitler.dreamBoxDecoration,
                                margin: EdgeInsets.only(right: 1),
                                height: 50,
                                width: 50,
                                child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.blue.shade900,
                                    ))),
                            onTap: () {
                              late double tutar;

                              try {
                                tutar = double.parse(_tutarController.text);
                                add(secilenTarih1, tutar);
                                _tutarController.clear();
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: "Tutar formatı yanlış",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.blue.shade900,
                                    fontSize: 14.0);
                              }
                            }),
                      ],
                    ),
                  ),
                  !loading
                      ? Container(
                    child: DreamCogs(),
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 4),
                  )
                      : Expanded(
                      child: Container(
                          margin: EdgeInsets.only(bottom: 1, left: 1, right: 1),
                          child: _grid()))
                ],
              ),
            ),
          ),
        )
    );
  }

  _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _ovhDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: false,
        allowTriStateSorting: false,
        controller: _OVHSayfasiController,
        columns: <GridColumn>[
          dreamColumn(
              columnName: 'tarih', label: "TARİH", alignment: Alignment.center),
          dreamColumn(
              columnName: 'tutar', label: "TUTAR", alignment: Alignment.center),
        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async {
            if (v.rowColumnIndex.rowIndex > 0) {
              FocusScope.of(context).requestFocus(FocusNode());
             print(v.rowColumnIndex.rowIndex);
             ovhGridList.removeAt(v.rowColumnIndex.rowIndex-1);
             if(ovhGridList.isEmpty) {
               setState(() {
                 vade = "0 Gün";
                 toplam = 0;
               });
             }
             vadeHesapla();
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
      initialDate: secilenTarih1,
      firstDate: DateTime.now(),
      lastDate: DateTime(2055),
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

  void callDatePicker() async {
    var order = await getDate();
    if (order != null) {
      setState(() {
        secilenTarih1 = order;
      });
    }
  }

  add(DateTime dt, double tutar) {
    ovhGridList.add(OrtalamaVadeHesapla(tarih: dt, tutar: tutar));
    _ovhDataSource = OVHDataSource(_OVHSayfasiController);
    vadeHesapla();
    setState(() {});
  }

  void vadeHesapla() {
    if(ovhGridList.isNotEmpty){
      double topTutar = 0;
      double topToplamSayi = 0;
      for (var t in ovhGridList) {
        topTutar += t.tutar;
        topToplamSayi += toOADate(t.tarih).floor() * t.tutar;
      }

      var vadeSayi = topToplamSayi / topTutar;
      var date = fromOADate(vadeSayi.floor());
      vade = "${DateFormat("dd/MM/yyyy").format(date.add(const Duration(days: 1)))} ${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).difference(date.add(const Duration(days: 1))).inDays.abs()} GÜN";
      toplam = topTutar;
    }
    _ovhDataSource = OVHDataSource(_OVHSayfasiController);
    setState(() {

    });
  }

}

class OVHDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRows() {
    dataGridRows = ovhGridList
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<DateTime>(columnName: 'tarih', value: e.tarih),
              DataGridCell<double>(columnName: 'tutar', value: e.tutar),
            ]))
        .toList();
  }

  final DataGridController dataGridController;

  OVHDataSource(this.dataGridController) {
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
