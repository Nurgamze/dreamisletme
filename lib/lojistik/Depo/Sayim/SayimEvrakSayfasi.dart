import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../../../modeller/GridListeler.dart';
import '../../../modeller/GridModeller.dart';
import '../../../modeller/Modeller.dart';
import '../../../modeller/ProviderHelper.dart';
import '../../../stoklar/DreamCogsGif.dart';
import '../../LocalDB/DatabaseHelper.dart';
import '../../LocalDB/EvraklarDB.dart';
import '../../datagrid_utils.dart';



class SayimEvrak extends StatefulWidget {
  String evrakAdi, depoAdi;
  int evrakId;
  SayimEvrak(this.evrakId, this.evrakAdi, this.depoAdi);
  @override
  _SayimEvrakState createState() => _SayimEvrakState();
}

class _SayimEvrakState extends State<SayimEvrak> {
  TextEditingController _aramaController = TextEditingController();
  TextEditingController _rafController = TextEditingController();
  TextEditingController _miktarIlkController = TextEditingController();
  TextEditingController _miktarSonController = TextEditingController();

  final DataGridController _dataGridController = DataGridController();
  final DataGridController _stoklarGridController = DataGridController();
  //final DataGridController _sayimEvrakStoklarDtaGridController = DataGridController();

  int secilenRow = -1;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  SayimDBHelper _sayimDBHelper = SayimDBHelper();

  FocusNode textFocus = new FocusNode();
  FocusNode rafFocus = new FocusNode();

  //late GeneralGridDataSource _sayimEvrakStoklarDataGridSource;

  late GeneralGridDataSource _stoklarDataSource;
  late GeneralGridDataSource _sayimEvrakDataSource;


  @override
  void initState() {
    super.initState();
    print("sayım evrak sayfasına girdim.");
    _sayimEvrakDataSource = GeneralGridDataSource(_dataGridController, _sayimEvrakRows());
    _sayimKalemleriniGetir(widget.evrakId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("${widget.evrakAdi} (${widget.depoAdi})"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Column(
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  decoration: Sabitler.dreamBoxDecoration,
                  width: MediaQuery.of(context).size.width - 125,
                  height: 50,
                  padding: EdgeInsets.only(left: 5),
                  child: Center(
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        hintText: "Raf giriniz",
                        border: InputBorder.none,
                      ),
                      maxLength: 4,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _rafController,
                      focusNode: rafFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(textFocus);
                      },
                    ),
                  )),
              SizedBox(
                width: 5,
              ),
              Container(
                  decoration: Sabitler.dreamBoxDecoration,
                  height: 50,
                  width: 110,
                  padding: EdgeInsets.all(5),
                  child: Center(
                    child: Text("Kalem : ${sayimEvrakSayfasiGridList.length}", style: GoogleFonts.openSans(fontWeight: FontWeight.w600),),
                  )),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width - 75,
                  decoration: Sabitler.dreamBoxDecoration,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: SafeArea(
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        hintText: 'Stok arayın',
                        border: InputBorder.none,
                      ),
                      controller: _aramaController,
                      textInputAction: TextInputAction.search,
                      focusNode: textFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _stokAra(context);
                      },
                    ),
                  )),
              SizedBox(
                width: 2,
              ),
              InkWell(
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    decoration: Sabitler.dreamBoxDecoration,
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.camera,
                        color: Colors.blue.shade900,
                        size: 18,
                      ),
                    )),
                onTap: () {
                  scanBarcodeNormal();
                },
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
              flex: 10,
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5)),
                        color: Colors.blue[900],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text("SAYIM KALEMLERİ",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      )),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 1, left: 1, right: 1),

                      child: SfDataGridTheme(
                        data: myGridTheme,
                        child: SfDataGrid(
                          selectionMode: SelectionMode.single, //Bu seçenek, kullanıcının yalnızca bir öğeyi seçebileceği anlamına gelir.
                          columnWidthMode: ColumnWidthMode.auto,
                          columnSizer: customColumnSizer,
                          onCellTap: (value) {

                            // Tıklama olayının işlenmesinin tamamlanması için bir gecikme ekleyin
                            Future.delayed(Duration(milliseconds: 50), () {

                              // Klavyeyi kapatmak için odak noktasını temizleyin
                              FocusScope.of(context).requestFocus(new FocusNode());

                              // Seçilen satırın null olmadığını ve satır indeksinin 0'dan büyük olduğunu kontrol edin
                              if (_dataGridController.selectedRow != null && value.rowColumnIndex.rowIndex > 0) {

                                // Seçilen satırın hücrelerine erişin
                                var row = _dataGridController.selectedRow!.getCells();

                                // Satır indeksinin verinizin sınırları içinde olduğundan emin olun
                                if (value.rowColumnIndex.rowIndex < sayimEvrakSayfasiGridList.length) {

                                  // Listenizden ilgili veriyi alın
                                  SayimEvrakSayfasiDataGrid evrak = sayimEvrakSayfasiGridList.where((e) => e.stokKodu == row[2].value.toString()).first;

                                  // İlgili veri ile birlikte iletişim kutusunu gösterin
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black.withOpacity(0.5),
                                    builder: (context) => SingleChildScrollView(
                                      child: sayimKalemiDialog(
                                        evrak.stokKodu,
                                        evrak.stokAdi,
                                        evrak.birim,
                                        true,
                                        evrak.raf,
                                        miktar: evrak.miktar,
                                        id: evrak.id,
                                      ),
                                    ),
                                  );

                                  // Seçimi temizlemek için seçilen indeksi -1 olarak ayarlayın
                                  this._dataGridController.selectedIndex = -1;
                                }
                              }
                            });
                          },

                          source: _sayimEvrakDataSource,
                          columns: <GridColumn>[
                            dreamColumn(columnName: 'raf', label: "RAF"),
                            dreamColumn(columnName: 'miktar', label: "MİKTAR"),
                            dreamColumn(columnName: 'stokKodu', label: "STOK KODU",minWidth: 200),
                            dreamColumn(columnName: 'stokAdi', label: "STOK ADI"),
                            dreamColumn(columnName: 'birim', label: "BİRİM"),
                          ],
                          gridLinesVisibility: GridLinesVisibility.vertical,
                          headerGridLinesVisibility:
                          GridLinesVisibility.vertical,
                          headerRowHeight: 30,
                          allowSorting: false,
                          allowTriStateSorting: false,
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
    );
  }

  _stokAra(BuildContext context) async {
    //kalem varsa popup göster yoksa stok seç
    String aranacakKelime = _aramaController.text.trimRight();
    print("aranacakkelime: $aranacakKelime");

    var result = await _sayimDBHelper.sayimKalemVarMi(_rafController.text, aranacakKelime,widget.evrakId);
    print("result: $result");
    if (result != -1) {
      var kalem = await _sayimDBHelper.sayimKalemiBul(result);
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => SingleChildScrollView(
              child: sayimKalemiDialog(
                  kalem[0]["stokKodu"],
                  kalem[0]["stokAdi"],
                  kalem[0]["birim"], true,
                  kalem[0]["raf"],
                  miktar: kalem[0]["miktar"],
                  id: kalem[0]["id"])));
    } else {
      context.read<StateHelper>().setLoading(true);
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) =>
              sayimEvrakiStoklarDialog(aranacakKelime, context));

      setState(() {
        _aramaController.clear();
      });
    }
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
        _stokAra(context);
      }
    });
  }

  _stoklariGetir(String aranan, BuildContext context) async {
    var stoklarListesi = await _databaseHelper.sayimKalemiStoklariGetir(aranan);
    stoklarList?.clear();

    for(var stok in stoklarListesi!) {
      stoklarList.add( Stoklar(
        stok["sto_kod"],
        stok["sto_isim"],
        stok["sto_max_stok"].toString(),
        stok["sto_birim1_ad"],
        stok["sto_anagrup_kod"],
        stok["sto_altgrup_kod"],
        stok["sto_marka_kodu"],
        stok["sto_reyon_kodu"],
      ));
    }
    _stoklarDataSource = GeneralGridDataSource(_stoklarGridController, _sayimEvrakStokRows());
    context.read<StateHelper>().setLoading(false);
  }




  _secilenStokVarmi(Stoklar arananStok) async {
    Navigator.pop(context);
    showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => DreamCogs());
    var result = await _sayimDBHelper.sayimKalemVarMi(
        _rafController.text, arananStok.sto_kod ?? "",widget.evrakId);
    if (result != -1) {
      var kalem = await _sayimDBHelper.sayimKalemiBul(result);
      Navigator.pop(context);
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => SingleChildScrollView(
              child: sayimKalemiDialog(
                  kalem[0]["stokKodu"],
                  kalem[0]["stokAdi"],
                  kalem[0]["birim"],
                  true,
                  kalem[0]["raf"],
                  miktar: kalem[0]["miktar"],
                  id: kalem[0]["id"])));
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => sayimKalemiDialog(
              arananStok.sto_kod ?? "",
              arananStok.sto_isim ?? "",
              arananStok.sto_birim1_ad,
              false,
              _rafController.text));
    }
  }

  Widget sayimEvrakiStoklarDialog(String aranan, BuildContext context) {
    _stoklariGetir(aranan, context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      child: Container(
        height: 450,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: context.watch<StateHelper>().kalemPopUpLoading
            ? Center(child: DreamCogs(),) : Column(
          children: [
            Container(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text("STOK SEÇİNİZ", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text("Aranan stok : $aranan", style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  )),
            ),
            Divider(thickness: 2,),
            Expanded(
                child: Container(
                  child: SfDataGridTheme(
                    data: myGridTheme,
                    child: SfDataGrid(
                      selectionMode: SelectionMode.single,
                      allowSorting: true,
                      allowTriStateSorting: true,
                      columnWidthMode: ColumnWidthMode.auto,
                      columnSizer: customColumnSizer,
                      onCellTap: (value) {



                        Future.delayed(Duration(milliseconds: 50), () {

                          FocusScope.of(context).requestFocus(new FocusNode());

                          print("focus içindeyim");
                          if (value.rowColumnIndex.rowIndex > 0) {
                            print("value.rowColumnIndex.rowIndex ${value.rowColumnIndex.rowIndex }");
                            var row = _stoklarGridController.selectedRow!.getCells();
                            print("row $row");
                            Stoklar arananStok = stoklarList.where((e) => e.sto_kod == row[0].value.toString()).first;
                            print("arananStok $arananStok");
                            _secilenStokVarmi(arananStok);
                          }

                          this._stoklarGridController.selectedIndex = -1;
                        });
                      },
                      frozenColumnsCount: 1,
                      source: _stoklarDataSource,
                      columns: <GridColumn>[
                        dreamColumn(columnName: 'sto_kod', label: "STOK KODU"),
                        dreamColumn(columnName: 'sto_isim', label: "STOK ADI"),
                        dreamColumn(columnName: 'sto_max_stok', label: "DEPODAKİ MİKTAR"),
                        dreamColumn(columnName: 'sto_marka_kodu', label: "MARKA"),
                        dreamColumn(columnName: 'sto_reyon_kodu', label: "REYON"),
                        dreamColumn(columnName: 'sto_birim1_ad', label: "BİRİM"),
                        dreamColumn(columnName: 'sto_anagrup_kod', label: "ANA GRUP"),
                        dreamColumn(columnName: 'sto_altgrup_kod', label: "ALT GRUP"),
                      ],

                      gridLinesVisibility: GridLinesVisibility.vertical,
                      headerGridLinesVisibility: GridLinesVisibility.vertical,
                      headerRowHeight: 30,
                      rowHeight: 30,
                      controller: this._stoklarGridController,
                    ),
                  ),
                )),
            Container(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  _sayimKalemleriniGetir(int evrakId) async {
    sayimEvrakSayfasiGridList.clear();
    var result = await _sayimDBHelper.sayimKalemleriGetir(evrakId);
    for (var evrak in result) {
      setState(() {
        sayimEvrakSayfasiGridList.add(SayimEvrakSayfasiDataGrid(
            evrak["id"],
            evrak["evrakId"],
            evrak["raf"],
            evrak["miktar"],
            evrak["stokKodu"],
            evrak["stokAdi"],
            evrak["birim"]));
      });
    }
    _sayimEvrakDataSource = GeneralGridDataSource(_dataGridController, _sayimEvrakRows());
  }

  Widget sayimKalemiDialog(String stokKodu, String stokAdi, String? birim,
      bool duzenleMi, String raf,
      {String miktar = "-1", int? id}) {

    print("sayım kalemi dialog içindeyim ");

    _miktarSonController.clear();
    _miktarIlkController.clear();
    birim = birim == null ? birim = "" : birim;
    if (miktar != "-1") {
      int dot = miktar.indexOf(".");
      _miktarIlkController.text = miktar.substring(0, dot);
      _miktarSonController.text = miktar.substring(dot + 1, miktar.length);
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: ListView(
          children: [
            Container(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text("Sayım Kalemi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue.shade900)),
                    ],
                  )),
            ),
            SizedBox(height: 10,),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Raf", style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center,),),
                      Container(
                        height: 20,
                        width: 2,
                        color: Colors.grey,
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(raf, style: TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                      ),
                    ],
                  )),
            ),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Stok Kodu", style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center,),),
                      Container(
                        height: 20,
                        width: 2,
                        color: Colors.grey,
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          stokKodu,
                          style: TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Text("Stok Adı", style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        width: 2,
                        color: Colors.grey,
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          stokAdi,
                          style: TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Birim", style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                      ),
                      Container(
                        height: 20,
                        width: 2,
                        color: Colors.grey,
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          birim,
                          style: TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Miktar",
                          style: TextStyle(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 2,
                        color: Colors.grey,
                      ),
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            right: 2, left: 10, top: 0),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey)),
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        child: SafeArea(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 0),
                                              hintText: "0",
                                              hintStyle:
                                              TextStyle(color: Colors.black),
                                              border: InputBorder.none,
                                            ),
                                            controller: _miktarIlkController,
                                            textAlign: TextAlign.right,
                                            autofocus: true,
                                            keyboardType: TextInputType.number,
                                            onFieldSubmitted: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(new FocusNode());
                                            },
                                          ),
                                        )),
                                  ),
                                  Container(
                                    child: Text(".",
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                    alignment: Alignment.bottomCenter,
                                    margin: EdgeInsets.only(top: 10),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            right: 5, left: 0, top: 0),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey)),
                                        child: SafeArea(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 0),
                                              hintText: "00",
                                              hintStyle:
                                              TextStyle(color: Colors.black),
                                              border: InputBorder.none,
                                            ),
                                            controller: _miktarSonController,
                                            keyboardType: TextInputType.number,
                                            onFieldSubmitted: (value) {
                                              FocusScope.of(context)
                                                  .requestFocus(new FocusNode());
                                            },
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )),
                    ],
                  )),
            ),
            Divider(
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(color: Colors.blue.shade800)),),
                    child: Text("İptal", style: TextStyle(color: Colors.white),),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Visibility(
                  visible: duzenleMi,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: Colors.red)),),
                        child: Text("Sil", style: TextStyle(color: Colors.white),),
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          String formattedDate =
                          DateFormat('yyyy-MM-dd – kk:mm').format(now);
                          var result =
                          await _sayimDBHelper.sayimKalemiSil(id ?? 0);
                          if (result == 1) {
                            setState(() {
                              _sayimKalemleriniGetir(widget.evrakId);
                            });
                          }
                          await _sayimDBHelper.sayimEvrakTarihGuncelle(formattedDate, widget.evrakId);
                          Navigator.pop(context);
                        }),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(color: Colors.green)),),
                    child: Text("Kaydet", style: TextStyle(color: Colors.white),),
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      String formattedDate =
                      DateFormat('yyyy-MM-dd – kk:mm').format(now);
                      var raf = _rafController.text;
                      var miktarIlk = _miktarIlkController.text == "" ? 0 : int.parse(_miktarIlkController.text);
                      var miktarSon = _miktarSonController.text == "" ? 0 : int.parse(_miktarSonController.text);
                      if (miktarIlk == 0 && miktarSon <= 0) {
                        Fluttertoast.showToast(
                            msg: "Miktarı doğru girdinizden emim olup tekrar deneyin...",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            textColor: Colors.white,
                            backgroundColor: Colors.red.shade600,
                            fontSize: 16.0);
                      } else {
                        if (duzenleMi) {
                          var result = await _sayimDBHelper.sayimKalemiUpdate(
                              id ?? 0, "$miktarIlk.$miktarSon");

                          if (result > 0) {
                            Navigator.pop(context);
                            setState(() {
                              _sayimKalemleriniGetir(widget.evrakId);
                            });
                            await _sayimDBHelper.sayimEvrakTarihGuncelle(
                                formattedDate, widget.evrakId);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Kalem kaydedilirken sorun oluştu.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                          }
                        } else {
                          var result = await _sayimDBHelper.sayimKalemEkle(_rafController.text, stokKodu, stokAdi, widget.evrakId, "$miktarIlk.$miktarSon", birim ?? "");

                          if (result > 0) {
                            Navigator.pop(context);
                            setState(() {
                              _sayimKalemleriniGetir(widget.evrakId);
                            });
                            await _sayimDBHelper.sayimEvrakTarihGuncelle(formattedDate, widget.evrakId);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Kalem kaydedilirken sorun oluştu.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.white,
                                backgroundColor: Colors.red.shade600,
                                fontSize: 16.0);
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  List<DataGridRow> _sayimEvrakStokRows() {
    List<DataGridRow> rows = [];

    rows = stoklarList.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'sto_kod', value: e.sto_kod),
      DataGridCell<String>(columnName: 'sto_isim', value: e.sto_isim),
      DataGridCell<String>(columnName: 'sto_max_stok', value: e.sto_max_stok.toString()),
      DataGridCell<String>(columnName: 'sto_marka_kodu', value: e.sto_marka_kodu),
      DataGridCell<String>(columnName: 'sto_reyon_kodu', value: e.sto_reyon_kodu),
      DataGridCell<String>(columnName: 'sto_birim1_ad', value: e.sto_birim1_ad),
      DataGridCell<String>(columnName: 'sto_anagrup_kod', value: e.sto_anagrup_kod),
      DataGridCell<String>(columnName: 'sto_altgrup_kod', value: e.sto_altgrup_kod),

    ])).toList();
    return rows;
  }


  List<DataGridRow> _sayimEvrakRows() {
    List<DataGridRow> rows = [];
    rows = sayimEvrakSayfasiGridList.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'raf', value: e.raf),
      DataGridCell<String>(columnName: 'miktar', value: e.miktar),
      DataGridCell<String>(columnName: 'stokKodu', value: e.stokKodu),
      DataGridCell<String>(columnName: 'stokAdi', value: e.stokAdi),
      DataGridCell<String>(columnName: 'birim', value: e.birim),
    ]))
        .toList();

    return rows;
  }
}