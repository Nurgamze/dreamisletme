import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../modeller/GridListeler.dart';
import '../../modeller/GridModeller.dart';
import '../../modeller/Modeller.dart';
import '../../modeller/ProviderHelper.dart';
import '../Depo/Sayim/SayimEvrakSayfasi.dart';
import '../LocalDB/DatabaseHelper.dart';
import '../LocalDB/EvraklarDB.dart';
import '../datagrid_utils.dart';

class SarfCikis extends StatefulWidget {
  @override
  _SarfCikisState createState() => _SarfCikisState();
}

class _SarfCikisState extends State<SarfCikis> {
  TextEditingController _aramaController = TextEditingController();
  TextEditingController _yeniSayimController = TextEditingController();
  final DataGridController _dataGridController = DataGridController();
  List gidenVeriler = [];

  List file = [];
  String directory = "";
  int secilenRow = -1;
  bool loading = true;
  bool stokBulunamadi = false;
  bool aktarildiGostersinMi = false;
  String depoSecinizTitle = "DEPO SEÇİNİZ";
  DatabaseHelper _databaseHelper = DatabaseHelper();
  SayimDBHelper _sayimDBHelper = SayimDBHelper();
  var depolar = [];
  FocusNode textFocus = new FocusNode();

  late GeneralGridDataSource _sayimDataGridSource;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sayimDataGridSource =
        GeneralGridDataSource(_dataGridController, _sayimlarRows());
    _initializeSayimDB();
    _sayimEvraklariniGetir(false);
    _databaseHelper.initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Sarf Çıkış (T)"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                right: 5, left: 5, top: 5, bottom: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            padding: EdgeInsets.only(left: 10),
                            height: 60,
                            width: MediaQuery.of(context).size.width - 80,
                            child: Center(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Evrak ara',
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.blue.shade900,
                                      ),
                                      onPressed: () {
                                        //_dataGridController.selectedRow = null;
                                        _aramaController.text = "";
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        _sayimEvrakAra(_aramaController.text);
                                      },
                                    )),
                                controller: _aramaController,
                                textInputAction: TextInputAction.search,
                                focusNode: textFocus,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  _sayimEvrakAra(_aramaController.text);
                                },
                              ),
                            )),
                        InkWell(
                          child: Container(
                              height: 60,
                              width: 60,
                              margin: EdgeInsets.only(
                                  left: 3, right: 5, top: 2, bottom: 2),
                              decoration: Sabitler.dreamBoxDecoration,
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.search,
                                  color: Colors.blue.shade900,
                                  size: 18,
                                ),
                              )),
                          onTap: () async {
                            setState(() {
                              _sayimEvrakAra(_aramaController.text);
                            });
                          },
                        ),
                      ],
                    ),
                    Container(
                      height: 45,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                              height: 50,
                              margin: EdgeInsets.only(left: 10),
                              child: Center(
                                child: Text("Gönderilenler ?"),
                              )),
                          Container(
                            height: 50,
                            child: CupertinoSwitch(
                                value: aktarildiGostersinMi,
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    aktarildiGostersinMi = value;
                                    _dataGridController.selectedRows = [];
                                    secilenRow = -1;
                                    _sayimEvraklariniGetir(
                                        aktarildiGostersinMi);
                                  });
                                }),
                            margin: EdgeInsets.only(left: 20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 14,
                        child: !loading
                            ? Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ))
                            : Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      topLeft: Radius.circular(5)),
                                  color: Colors.blue[900],
                                ),
                                margin:
                                EdgeInsets.symmetric(horizontal: 1),
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text("SAYIM EVRAKLARI",
                                      style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight:
                                              FontWeight.bold))),
                                )),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: 1, left: 1, right: 1),
                                child: SfDataGridTheme(
                                  data: myGridTheme,
                                  child: SfDataGrid(
                                    selectionMode: SelectionMode.multiple,
                                    columnWidthMode: ColumnWidthMode.auto,
                                    columnSizer: customColumnSizer,
                                    onCellTap: (value) {
                                      Future.delayed(
                                          Duration(milliseconds: 50), () {
                                        FocusScope.of(context)
                                            .requestFocus(
                                            new FocusNode());
                                        secilenRow =
                                            value.rowColumnIndex.rowIndex;
                                      });
                                    },
                                    source: _sayimDataGridSource,
                                    columns: <GridColumn>[
                                      dreamColumn(
                                          columnName: 'id',
                                          label: "id",
                                          visible: true),
                                      dreamColumn(
                                          columnName: 'evrakAdi',
                                          label: "EVRAK ADI"),
                                      dreamColumn(
                                          columnName: 'depoAdi',
                                          label: "DEPO ADI"),
                                      dreamColumn(columnName: 'basTarihi', label: "BAŞLANGIÇ TARİHİ",minWidth: 140),
                                      dreamColumn(
                                          columnName: 'sonIslemTarihi',
                                          label: "SON İŞLEM TARİHİ",minWidth: 140),
                                    ],
                                    gridLinesVisibility:
                                    GridLinesVisibility.vertical,
                                    headerGridLinesVisibility:
                                    GridLinesVisibility.vertical,
                                    headerRowHeight: 30,
                                    rowHeight: 30,
                                    controller: this._dataGridController,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                            height: 60,
                            width: sWidth / 2 - 10,
                            margin: EdgeInsets.only(left: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.plus,
                                      color: Colors.blue.shade900,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "YENİ",
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ))),
                        onTap: () async {
                          context.read<StateHelper>().setDepoName("Depo Seçiniz");
                          _yeniSayimController.clear();
                          List<dynamic> depoList = [];
                          String depolarData = "";
                          depolar = (await _databaseHelper.depolarGetir2())!.cast<Depolar>();
                          for (var depo in depolar) {
                            depolarData += '''"${depo["depoAdi"]}",''';
                          }
                          if ((depolarData != null) &&
                              (depolarData.length > 0)) {
                            depolarData = depolarData.substring(
                                0, depolarData.length - 1);
                          }
                          depoList = [
                            [depolarData]
                          ];
                          showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (context) =>
                                  yeniSayimDialog(context, depoList));
                        },
                      ),
                      InkWell(
                        child: Container(
                          height: 60,
                          width: sWidth / 2 - 10,
                          margin: EdgeInsets.only(right: 5),
                          decoration: Sabitler.dreamBoxDecoration,
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.boxOpen,
                                    color: Colors.blue.shade900,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "AÇ",
                                    style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        ),
                        onTap: () {
                          if (aktarildiGostersinMi) {
                            Fluttertoast.showToast(
                                msg:
                                "Gönderilen evraklar üzerinde işlem yapamazsınız.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                            return;
                          }
                          if (sayimlarSayfasiGridList.isEmpty) return;
                          if (secilenRow < 0) {
                            Fluttertoast.showToast(
                                msg:
                                "Tablodan açmak istediğiniz evrağı seçiniz.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                          } else {
                            _dataGridController.selectedIndex = -1;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SayimEvrak(
                                        sayimlarSayfasiGridList[secilenRow - 1]
                                            .id ??
                                            0,
                                        sayimlarSayfasiGridList[secilenRow - 1]
                                            .evrakAdi ??
                                            "",
                                        sayimlarSayfasiGridList[secilenRow - 1]
                                            .depoAdi ??
                                            "")));
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                            height: 60,
                            width: sWidth / 2 - 10,
                            margin: EdgeInsets.only(left: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.trash,
                                      color: Colors.blue.shade900,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "SİL",
                                      style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ))),
                        onTap: () {
                          if (aktarildiGostersinMi) {
                            Fluttertoast.showToast(
                                msg:
                                "Gönderilen evraklar üzerinde işlem yapamazsınız.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                            return;
                          }
                          if (sayimlarSayfasiGridList.isEmpty) return;
                          if (secilenRow < 0) {
                            Fluttertoast.showToast(
                                msg:
                                "Tablodan silmek istediğiniz evrağı seçiniz.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                          } else {
                            setState(() {
                              showDialog(
                                  context: context,
                                  builder: (context) => _silOnayDialog());
                            });
                          }
                        },
                      ),
                      InkWell(
                        child: Container(
                          height: 60,
                          width: sWidth / 2 - 10,
                          margin: EdgeInsets.only(right: 5),
                          decoration: Sabitler.dreamBoxDecoration,
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.solidPaperPlane,
                                    color: Colors.blue.shade900,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "GÖNDER",
                                    style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        ),
                        onTap: () async {
                          if (aktarildiGostersinMi) {
                            Fluttertoast.showToast(
                                msg:
                                "Gönderilen evrakları tekrar gönderemezsiniz. Gönderilmeyen evraklardan seçip işleme öyle devam ediniz.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                            return;
                          }
                          if (_dataGridController.selectedRows.length == 0) {
                            Fluttertoast.showToast(
                                msg:
                                "Tablodan göndermek istediğiniz evrakları seçiniz",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                            return;
                          }
                          showDialog(
                              context: context,
                              builder: (context) => _gonderOnayDialog());
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _gonderOnayDialog() {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 5),
          child: Container(
            height: 220,
            child: Column(
              children: [
                Container(
                    height: 150,
                    child: Text(
                      "Seçtiğiniz evraklar gönderilecek artık işlem yapamayacaksınız, sayımı bitirdiyseniz gönderin.\nGöndermek istediğinize emin misiniz?",
                      style: TextStyle(color: Colors.black, fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                    margin: EdgeInsets.only(top: 2, bottom: 5),
                    padding: EdgeInsets.only(
                        left: 5, top: 20, bottom: 10, right: 5)),
                Container(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            child: Text(
                              "İptal Et",
                              style: TextStyle(color: Colors.grey.shade200),
                            ),
                            style: ElevatedButton.styleFrom(backgroundColor:Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(
                                    color: Colors.red,
                                  )),),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              child: Text("Gönder", style: TextStyle(color: Colors.grey.shade200),),
                              style: ElevatedButton.styleFrom(backgroundColor:Colors.green ,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.green)),),
                              onPressed: () async {
                                bool intVarMi =
                                await Foksiyonlar.internetDurumu(context);
                                if (!intVarMi) return;
                                Navigator.pop(context);
                                _evrakGonder();
                              },
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _silOnayDialog() {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 5),
          child: Container(
            height: 175,
            child: Column(
              children: [
                Container(
                    height: 105,
                    child: Text(
                      "${sayimlarSayfasiGridList[secilenRow - 1].evrakAdi} adlı evrağı silmek üzeresiniz!\nSilmek istediğinize emin misiniz?",
                      style: TextStyle(color: Colors.black, fontSize: 17),
                      maxLines: 4,
                      textAlign: TextAlign.center,
                    ),
                    margin: EdgeInsets.only(top: 2, bottom: 5),
                    padding: EdgeInsets.only(
                        left: 5, top: 20, bottom: 10, right: 5)),
                Container(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            child: Text(
                              "İptal Et",
                              style: TextStyle(color: Colors.grey.shade200),
                            ),
                            style: ElevatedButton.styleFrom(backgroundColor:Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(
                                    color: Colors.red,
                                  )),),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              child: Text(
                                "Sil",
                                style: TextStyle(color: Colors.grey.shade200),
                              ),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.green)),),
                              onPressed: () async {
                                var result = await _sayimDBHelper.sayimEvrakSil(
                                    sayimlarSayfasiGridList[secilenRow - 1]
                                        .evrakAdi ??
                                        "");
                                if (result > 0) {
                                  setState(() {
                                    sayimlarSayfasiGridList.removeAt(secilenRow - 1);
                                  });
                                  _sayimDataGridSource = GeneralGridDataSource(
                                      _dataGridController, _sayimlarRows());
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _evrakGonder() async {
    List<int> aktarilacakEvrakIds = [];
    gidenVeriler = [];

    for (var evrakin in _dataGridController.selectedRows) {
      var row = evrakin.getCells();
      SayimlarSayfasiDataGrid eklenecekEvrak =
          sayimlarSayfasiGridList.where((e) => e.id == row[0].value).first;
      print("eklenecek evrak ${eklenecekEvrak.aktarildiMi}${eklenecekEvrak.id}");

      if (eklenecekEvrak.aktarildiMi == 1) continue;
      var kalemler =
      await _sayimDBHelper.sayimKalemleriGetir(eklenecekEvrak.id ?? 0);
      print("kalemler $kalemler");
      if (kalemler.length == 0) {
        Fluttertoast.showToast(
            msg:
            "${eklenecekEvrak.id} no'lu evrağın satırı bulunmamaktadır seçimden çıkarınız yada satır ekleyiniz.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
            backgroundColor: Colors.red.shade600,
            fontSize: 16.0);
        return;
      }
      aktarilacakEvrakIds.add(eklenecekEvrak.id ?? 0); //Aktarılacak id leri api işlemi başarılı olursa aktarıldı işaretlicez.
      for (var kalem in kalemler) {
        GonderilecekVeriModel gonderilecekVeri = GonderilecekVeriModel(
            eklenecekEvrak.id.toString(),
            eklenecekEvrak.evrakAdi ?? "",
            eklenecekEvrak.basTarihi ?? "",
            eklenecekEvrak.sonIslemTarihi ?? "",
            eklenecekEvrak.depoKod.toString(),
            kalem["stokKodu"],
            kalem["miktar"],
            kalem["raf"]);
        print(gonderilecekVeri.depoKodu);

        Map<String, dynamic> map = {
          'evrakId': gonderilecekVeri.evrakId,
          'evrakAdi': gonderilecekVeri.evrakAdi,
          'basTarih': gonderilecekVeri.basTarih,
          'sonTarih': gonderilecekVeri.sonTarih,
          'depoKodu': gonderilecekVeri.depoKodu,
          'stokKodu': gonderilecekVeri.stokKodu,
          'miktar': gonderilecekVeri.miktar,
          'raf': gonderilecekVeri.raf,
          'mikroUserKod': '2'
        };
        String rawJson = jsonEncode(map);
        gidenVeriler.add(rawJson);
      }
    }
    print(gidenVeriler.toString());
    var body = jsonEncode({
      "data": gidenVeriler.toString(),
    });
    if (gidenVeriler.isEmpty) return;
    var response = await http.post(Uri.parse("${Sabitler.url}/api/SayimAktar"),
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    if (response.statusCode == 200) {
      for (var id in aktarilacakEvrakIds) {
        await _sayimDBHelper.sayimEvrakAktarGuncelle(id);
        await _sayimEvraklariniGetir(true);
        setState(() {
          aktarildiGostersinMi = true;
        });
      }
      Fluttertoast.showToast(
          msg: "Gönderme işlemi başarıyla tamamlandı.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
          backgroundColor: Colors.green.shade600,
          fontSize: 16.0);
    } else {
      print(response.body);
      print("response.body");
      Clipboard.setData((ClipboardData(text: response.body)));
      Fluttertoast.showToast(
          msg:
          "Gönderme işleminde bir problem oluştu. İnternetinizi kontrol ediniz sorun devam ederse talep açabilirsiniz.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
          backgroundColor: Colors.red.shade600,
          fontSize: 16.0);
    }
  }

  _sayimEvraklariniGetir(bool aktrilanlarMi) async {
    sayimlarSayfasiGridList.clear();
    var result = await _sayimDBHelper.sayimEvrakGetir();
    for (var evrak in result) {
      if (aktrilanlarMi) {
        if (evrak["aktarildiMi"] == 1) {
          setState(() {
            sayimlarSayfasiGridList.add(SayimlarSayfasiDataGrid(
                evrak["id"],
                evrak["evrakAdi"],
                evrak["depNo"],
                evrak["depoAdi"],
                evrak["baslangicTarihi"],
                evrak["sonIslemTarihi"],
                evrak["userId"]));
          });
        }
      } else {
        if (evrak["aktarildiMi"] == 0) {
          setState(() {
            sayimlarSayfasiGridList.add(SayimlarSayfasiDataGrid(
                evrak["id"],
                evrak["evrakAdi"],
                evrak["depNo"],
                evrak["depoAdi"],
                evrak["baslangicTarihi"],
                evrak["sonIslemTarihi"],
                evrak["userId"]));
          });
        }
      }
    }
    _sayimDataGridSource = GeneralGridDataSource(_dataGridController, _sayimlarRows());
    setState(() {});
  }

  _sayimEvrakAra(String aranacakKelime) async {
    sayimlarSayfasiGridList.clear();
    var result = await _sayimDBHelper.sayimEvrakAra(aranacakKelime);
    for (var evrak in result) {
      if (aktarildiGostersinMi) {
        if (evrak["aktarildiMi"] == 1) {
          setState(() {
            sayimlarSayfasiGridList.add(SayimlarSayfasiDataGrid(
                evrak["id"],
                evrak["evrakAdi"],
                evrak["depNo"],
                evrak["depoAdi"],
                evrak["baslangicTarihi"],
                evrak["sonIslemTarihi"],
                evrak["userId"]));
          });
        }
      } else {
        if (evrak["aktarildiMi"] == 0) {
          setState(() {
            sayimlarSayfasiGridList.add(SayimlarSayfasiDataGrid(
                evrak["id"],
                evrak["evrakAdi"],
                evrak["depNo"],
                evrak["depoAdi"],
                evrak["baslangicTarihi"],
                evrak["sonIslemTarihi"],
                evrak["userId"]));
          });
        }
      }
    }
    _sayimDataGridSource = GeneralGridDataSource(_dataGridController, _sayimlarRows());
    setState(() {});
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "İptal", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (barcodeScanRes != "-1") {
        _aramaController.text = barcodeScanRes;
      }
    });
  }

  int depoNo = 0;
  Widget yeniSayimDialog(BuildContext context, List<dynamic> depoList) {
    String secilenDepo = context.watch<StateHelper>().depoSecinizTitle;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 5),
      child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: ListView(
            children: [
              Container(
                child: Center(
                  child: Text(
                    "SAYIM EVRAĞI OLUŞTUR",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                margin: EdgeInsets.only(top: 10),
              ),
              Container(
                height: 205,
                padding:
                EdgeInsets.only(top: 10, bottom: 10, right: 25, left: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Depo",
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.indigo.shade800),
                                  borderRadius: BorderRadius.circular(5)),
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: ElevatedButton(
                                child: Text(context
                                    .watch<StateHelper>()
                                    .depoSecinizTitle),
                                onPressed: () {
                                  Picker(
                                      adapter: PickerDataAdapter<String>(
                                        pickerData: JsonDecoder()
                                            .convert(depoList.toString()),
                                        isArray: true,
                                      ),
                                      hideHeader: true,
                                      height: 220,
                                      title: Text("Depo Seçiniz"),
                                      textAlign: TextAlign.center,
                                      confirmText: "Tamam",
                                      selectedTextStyle: TextStyle(
                                          color: Colors.indigo.shade800),
                                      cancel: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("İptal")),
                                      onConfirm: (Picker picker, List value) {
                                        context.read<StateHelper>().setDepoName(
                                            picker.getSelectedValues().first);
                                        secilenDepo =
                                            picker.getSelectedValues().first;
                                        print(depolar[picker.selecteds[0]]);
                                        depoNo = depolar[picker.selecteds[0]]
                                        ["depNo"];
                                      }).showDialog(context);
                                },
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.indigo.shade800)),
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: SafeArea(
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              hintText: 'Evrak adı giriniz',
                              border: InputBorder.none,
                            ),
                            controller: _yeniSayimController,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                          ),
                        )),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor:Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.red)), ),
                              child: Text(
                                "İptal",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor:Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(color: Colors.green)),),
                            child: Text(
                              "Oluştur",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (secilenDepo == "Depo Seçiniz" ||
                                  _yeniSayimController.text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg:
                                    "Evrak oluşturabilmek için depo seçmeli ve evrak adını girmeniz gerekli.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.red.shade600,
                                    fontSize: 16.0);
                              } else {
                                DateTime now = DateTime.now();
                                String formattedDate =
                                DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(now);
                                int result =
                                await _sayimDBHelper.sayimEvrakEkle(
                                    _yeniSayimController.text.replaceAll("'", "''"),
                                    depoNo,
                                    secilenDepo,
                                    formattedDate,
                                    formattedDate,
                                    "21331");
                                if (result > 0) {
                                  setState(() {
                                    _sayimEvraklariniGetir(
                                        aktarildiGostersinMi);
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SayimEvrak(
                                                result,
                                                _yeniSayimController.text,
                                                secilenDepo)));
                                  });
                                } else if (result == -1) {
                                  Fluttertoast.showToast(
                                      msg:
                                      "Seçtiğiniz depoda bu evrak zaten var tablodan evrağı açıp işleme devam edebilirsiniz.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.red.shade600,
                                      fontSize: 16.0);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Evrak oluşturulamadı.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.red.shade600,
                                      fontSize: 16.0);
                                }
                              }
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  _initializeSayimDB() async {
    _sayimDBHelper.initializeDatabase().then((value) {
      print(value);
    });
  }

  List<DataGridRow> _sayimlarRows() {
    List<DataGridRow> rows = [];

    rows = sayimlarSayfasiGridList
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<int>(columnName: 'id', value: e.id),
      DataGridCell<String>(columnName: 'evrakAdi', value: e.evrakAdi),
      DataGridCell<String>(columnName: 'depoAdi', value: e.depoAdi),
      DataGridCell<String>(
          columnName: 'basTarihi',
          value: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(
              e.basTarihi.toString().replaceAll(' – ', ' ') + ":00"))),
      DataGridCell<String>(
          columnName: 'sonIslemTarihi',
          value: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(
              e.sonIslemTarihi.toString().replaceAll(' – ', ' ') +
                  ":00"))),
    ]))
        .toList();

    return rows;
  }
}

class GonderilecekVeriModel {
  String evrakId;
  String evrakAdi;
  String basTarih;
  String sonTarih;
  String depoKodu;
  String stokKodu;
  String miktar;
  String raf;

  GonderilecekVeriModel(this.evrakId, this.evrakAdi, this.basTarih,
      this.sonTarih, this.depoKodu, this.stokKodu, this.miktar, this.raf);
}
