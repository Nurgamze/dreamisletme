
import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../ZiyaretlerSayfasi.dart';
import '../core/services/api_service.dart';
import '../modeller/Modeller.dart';
import '../stoklar/Dialoglar.dart';
import '../stoklar/DreamCogsGif.dart';
import '../stoklar/HorizontalPage.dart';
import '../stoklar/MailGondermePopUp.dart';
import '../stoklar/const_screen.dart';
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';
import 'FaturaDetaySayfasi.dart';
import 'models/cari.dart';
import 'models/cari_ekstre.dart';


class CariEkstreView extends StatefulWidget {
  final DateTime ekstreTarihi;
  final String? ekstreSonTarihi;
  final DreamCari data;
  const CariEkstreView({
    Key? key,required
    this.ekstreTarihi,
    this.ekstreSonTarihi,
    required this.data
  }) : super(key: key);

  @override
  State<CariEkstreView> createState() => _CariEkstreViewState();
}


final List<Map<String, dynamic>> cinsiFiltreList = [];
List<String?> _temsilciFiltreler = [];

final List<Map<String, dynamic>> evrakTipiFiltreList = [];
List<String?> _sektorFiltreler = [];

final List<Map<String, dynamic>> tipFiltreList = [];
List<String?> _carikodFiltreler = [];

DateTime? _selectedTime;

class _CariEkstreViewState extends State<CariEkstreView> {

  var sipraisJson;
  bool loading = false;
  String borc = "0",alacak = "0",bakiye = "0";
  DataGridController _dataGridController = DataGridController();
  late BaseDataGridSource _cariEkstreDataSource;

  List<CariEkstre> aramaList = [];

  late PdfImage image;
  var font;


  List<CariEkstre> _cariEkstreList = [];

  bool temsilciFiltreMi = false;
  bool sektorFiltreMi = false;
  bool carikodFiltreMi = false;
  bool timeSelected = false;



  @override
  void initState() {
    // TODO: implement initState
    _cariEkstreDataSource = BaseDataGridSource(_dataGridController,CariEkstre.buildDataGridRows(_cariEkstreList));
    _ekstreGetir();
    super.initState();
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cariEkstreList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/dreambg.jpg"), fit: BoxFit.cover)),
          child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid()) : Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.blue.shade900,
              centerTitle: true,
              title: Container(
                  child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
              ),
              actions: <Widget>[
                temsilciFiltreMi || sektorFiltreMi ||carikodFiltreMi || timeSelected ?
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: Colors.red,),
                    Text("${_sektorFiltreler.length + _temsilciFiltreler.length + _carikodFiltreler.length + (_selectedTime == null ? 0 : 1)}", style: TextStyle(color: Colors.white)),
                    IconButton(
                        icon: const FaIcon(FontAwesomeIcons.filter),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) => _filtreDialog()).then((value) => setState((){}));
                        }),
                  ],
                  //position: BadgePosition.topEnd(top: 0, end: 5),
                ) :
                IconButton(
                    icon: const FaIcon(FontAwesomeIcons.filter),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) => _filtreDialog()).then((value) => setState((){}));
                    }),
                Row(
                  children: <Widget>[
                    widget.ekstreSonTarihi == null ? IconButton(
                      icon: FaIcon(FontAwesomeIcons.envelopeOpenText,color: Colors.white,),
                      tooltip: "Mail Gönder",
                      onPressed: () async {
                        if(temsilciFiltreMi || sektorFiltreMi ||carikodFiltreMi || timeSelected){
                          Fluttertoast.showToast(
                              msg: "Ekstreyi paylaşmak için filtreleri temizleyiniz",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              textColor: Colors.white,
                              backgroundColor: Colors.red.shade900,
                              fontSize: 14.0);
                          return;
                        }
                        showDialog(context: context,builder: (_) => _mailSecenekDialog());

                      },) : Container(),
                  ],
                )
              ],
            ),
            body: !loading ? DreamCogs() :
            Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Visibility(child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width/3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height: 22,
                            child: Center(child: Text("Borç",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                              color: Colors.red,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height:33,
                            child: Center(child: Text(borc,style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                border: Border.all(color: Colors.red,width: 2),color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width/3,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              height: 22,
                              child: Center(child: Text("Alacak",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                color: Colors.green,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              height:33,
                              child: Center(child: Text(alacak,style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                  border: Border.all(color: Colors.green,width: 2)
                              ),
                            ),
                          ],
                        )
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width/3,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height: 22,
                            child: Center(child: Text("Bakiye",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                              color: Colors.blue.shade900,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height:33,
                            child: Center(child: Text(bakiye,style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                border: Border.all(color: Colors.blue.shade900,width: 2)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),visible: widget.ekstreSonTarihi == null ? true : false,),
                SizedBox(height: 4,),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                      color: Colors.blue.shade900,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: Text("CARİ EKSTRE HAREKETLERİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                ),
                Expanded(child: Container(
                    margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                    child: _grid()
                ),)
              ],
            ),
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
        source: _cariEkstreDataSource,
        columns: <GridColumn> [
          GridColumn(columnName: 'tip',label:  Container(child: Text("TİP",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'isTarihi',label:  Container(child: Text("İŞ TARİHİ",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'meblag',label:  Container(child: Text("MEBLAG",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'bakiye',label:  Container(child: Text("BAKİYE",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'cinsi',label:  Container(child: Text("CİNSİ",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'normalIade',label:  Container(child: Text("TÜR",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'evrakSeri',label:  Container(child: Text("SERİ",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'evrakSira',label:  Container(child: Text("SIRA",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'belgeTarihi',label:  Container(child: Text("BELGE TARİHİ",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'vadeTarihi',label:  Container(child: Text("VADE TARİHİ",style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'evrakTipi',label: Container(child: Text('EVRAK TİPİ',style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center)),
          GridColumn(columnName: 'kayit',label: Container(child: Text('kayit',style:  headerStyle),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center,),visible: false),
        ],
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), (){
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex > 0){
              var row = _dataGridController.selectedRow!.getCells();
              _dataGridController.selectedIndex = -1;
              Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: FaturaDetaySayfasi(row[7].value,row[6].value,row[11].value)));

            }
          });
        },
      ),
    );
  }
  _ekstreGetir() async {
    var queryParameters = {
      "VtIsim" : UserInfo.activeDB,
      "Customer" : false,
      "cariKod" : widget.data.kod,
      "ekstreTarihi" : "${widget.ekstreTarihi.month}.${widget.ekstreTarihi.day}.${widget.ekstreTarihi.year}" ,
      "ekstreSonTarihi" : widget.ekstreSonTarihi,
      "ozet" : false,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId,
    };
    var serviceData = await APIService.getDataWithModel<List<CariEkstre>,CariEkstre>("CariHesapEkstresi", queryParameters, CariEkstre());
    if(serviceData.statusCode == 200) {

      _cariEkstreList = serviceData.responseData ?? [];

      alacak = _cariEkstreList[_cariEkstreList.length-3].cinsi ?? "";
      borc = _cariEkstreList[_cariEkstreList.length-2].cinsi ?? "";
      bakiye = _cariEkstreList[_cariEkstreList.length-1].cinsi ?? "";
      _cariEkstreList.removeRange(_cariEkstreList.length-4, _cariEkstreList.length);

      evrakTipiFiltreList.clear();
      tipFiltreList.clear();
      cinsiFiltreList.clear();
      for(var cariEkstre in _cariEkstreList){
        bool addC = true;
        bool addS = true;
        bool addT = true;
        for (var map in tipFiltreList) {
          if (map["value"] == cariEkstre.tip) addC = false;
        }
        for (var map in evrakTipiFiltreList) {
          if (map["value"] == cariEkstre.evrakTipi) addS = false;
        }
        for (var map in cinsiFiltreList) {
          if (map["value"] == cariEkstre.cinsi) addT = false;
        }

        if (addC && cariEkstre.tip != "") {
          tipFiltreList.add({"grup": "Tip", "value": cariEkstre.tip});
        }
        if (addS && cariEkstre.evrakTipi != "") {
          evrakTipiFiltreList.add({"grup": "Evrak Tipi", "value":cariEkstre.evrakTipi});
        }
        if (addT && cariEkstre.cinsi != "") {
          cinsiFiltreList.add({"grup": "Cinsi", "value":cariEkstre.cinsi});
        }
      }
      aramaList = _cariEkstreList;
      _carikodFiltreler.clear();
      _sektorFiltreler.clear();
      _temsilciFiltreler.clear();
      carikodFiltreMi = false;
      sektorFiltreMi = false;
      temsilciFiltreMi = false;
      timeSelected = false;
      loading = !loading;
      _cariEkstreDataSource = BaseDataGridSource(_dataGridController,CariEkstre.buildDataGridRows(_cariEkstreList));

      setState(() {});
    }else{
      showDialog(context: context,builder: (context) => BilgilendirmeDialog("Cari hareketiniz bulunamamıştır")).then((value) {
        setState(() {
          loading = !loading;
        });
      });
    }
  }


  Future<void> generateReport() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle

    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    final PdfGrid babGrid = getBABGrid();
    final PdfGrid leftGrid = getLEFTGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult? result = drawHeader(page, pageSize, grid);
    //Draw grid
    grid.repeatHeader = true;
    drawGrid(page, grid, result!);
    drawBABGrid(page, babGrid, result);
    drawLEFTGrid(page, leftGrid, result);
    //Add invoice footer
    //drawFooter(page, pageSize);
    //Save and launch the document
    final List<int> bytes = await document.save();

    //Dispose the document.
    document.dispose();
    //Get the storage folder location using path_provider package.
    final Directory directory =
    await p.getTemporaryDirectory();
    final String path = directory.path;
    String name = "${DateFormat("dd_MM_yyyy").format(widget.ekstreTarihi)}-${DateFormat("dd_MM_yyyy").format(DateTime.now())} Ekstre.pdf";
    final File file = File('$path/$name');
    await file.writeAsBytes(bytes);


    await send('$path/$name');

    //await open_file.OpenFile.open('$path/$name');
  }
  Future<List<int>> _readImageData() async {
    if(UserInfo.activeDB == "MikroDB_V16_12"){
      final ByteData data = await rootBundle.load('assets/images/ZenitLed_logo.png');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }else{
      final ByteData data = await rootBundle.load('assets/images/sdslogo2.jpg');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
  }

  Future<List<int>> _readFontData() async {
    final ByteData data = await rootBundle.load('assets/images/arial.ttf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  //Draws the invoice header
  PdfLayoutResult? drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {

    String footerSirket = UserInfo.activeDB == "MikroDB_V16_12" ? "ZENİTLED" : "SDS";
    double imageWidth = UserInfo.activeDB == "MikroDB_V16_12" ? 120: 75;
    double imageHeight = UserInfo.activeDB == "MikroDB_V16_12" ? 50: 75;
    double imageTop = UserInfo.activeDB == "MikroDB_V16_12" ? 0: 0;
    page.graphics.drawImage(
        image, Rect.fromLTWH(20, imageTop, imageWidth, imageHeight));
    //Draw text
    page.graphics.drawString('Alıcı: ${widget.data.unvan}',
        PdfTrueTypeFont(font, 11),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(100, 0, pageSize.width - 120, 50),format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle));
    /*
    page.graphics.drawString(,
        PdfTrueTypeFont(font, 11),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(100, 20, pageSize.width - 120, 100),format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle));*/

    return PdfTextElement(text: '${DateFormat("dd.MM.yyyy").format(widget.ekstreTarihi)} ile ${DateFormat("dd.MM.yyyy").format(DateTime.now())} Arasındaki Cari Ekstreniz Aşağıdaki Gibidir.', font: PdfTrueTypeFont(font, 11),).draw(
      page: page,
      bounds: Rect.fromLTWH(80, 100, pageSize.width - 130, 100),);
  }

  //Draws the grid
  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 20, 550, 0))!;
  }

  void drawBABGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(page.size.width-325, 49, 650, 0))!;
  }
  void drawLEFTGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(page.size.width-480, 50, 650, 0))!;
  }

  PdfGrid getLEFTGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 2);
    final PdfGridRow headerRow = grid.headers.add(1)[0];

    PdfFont myFont = PdfTrueTypeFont(font, 8);
    PdfFont myHeaderFont = PdfTrueTypeFont(font, 9);
    PdfGridStyle gridStyle = PdfGridStyle(
      borderOverlapStyle: PdfBorderOverlapStyle.inside,
      //backgroundBrush: PdfBrushes.dimGray,
      font: myFont,
    );
    grid.rows.applyStyle(gridStyle);
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'GÖNDERİM TARİHİ:';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.right;
    headerRow.cells[1].value = DateFormat("dd.MM.yyyy").format(widget.ekstreTarihi);
    headerRow.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    final PdfGridRow row2 = grid.rows.add();
    row2.cells[0].value = "TANIMLI VADE:";
    row2.cells[0].stringFormat.alignment = PdfTextAlignment.right;
    row2.cells[1].value = widget.data.vade;
    row2.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[0].width = 85;
    grid.columns[0].format = PdfStringFormat(textDirection: PdfTextDirection.leftToRight,alignment: PdfTextAlignment.right);
    grid.columns[1].width = 60;
    grid.columns[1].format = PdfStringFormat(textDirection: PdfTextDirection.leftToRight,alignment: PdfTextAlignment.right);
    return grid;
  }



  PdfGrid getBABGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 3);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    PdfFont myFont = PdfTrueTypeFont(font, 8);
    PdfFont myHeaderFont = PdfTrueTypeFont(font, 9);
    PdfGridStyle gridStyle = PdfGridStyle(
      borderOverlapStyle: PdfBorderOverlapStyle.inside,
      cellSpacing: 0.5,
      //backgroundBrush: PdfBrushes.dimGray,
      font: myFont,
    );
    grid.rows.applyStyle(gridStyle);
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'BORÇ';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'ALACAK';
    headerRow.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[2].value = 'BAKİYE*';
    headerRow.cells[2].stringFormat.alignment = PdfTextAlignment.center;


    late double devirMeblag;
    if(_cariEkstreList[0].tip == "Alacak"){
      devirMeblag = _cariEkstreList[0].bakiye! + _cariEkstreList[0].meblag!;
    }else if(_cariEkstreList[0].tip == "Borç") {
      devirMeblag = _cariEkstreList[0].bakiye! - _cariEkstreList[0].meblag!;
    }
    double toplamBorc = devirMeblag;
    double toplamAlacak = 0.0;
    for(int i = 0; i < _cariEkstreList.length; i++){

      if(_cariEkstreList[i].tip == "Alacak") toplamAlacak+= _cariEkstreList[i].meblag!;
      if(_cariEkstreList[i].tip == "Borç") toplamBorc+= _cariEkstreList[i].meblag!;
    }
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = Foksiyonlar.formatMoney(toplamBorc);
    row.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[1].value = Foksiyonlar.formatMoney(toplamAlacak);
    row.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[2].value = bakiye;
    row.cells[2].stringFormat.alignment = PdfTextAlignment.center;
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[0].width = 75;
    grid.columns[0].format = PdfStringFormat(textDirection: PdfTextDirection.leftToRight,alignment: PdfTextAlignment.center);
    grid.columns[1].width = 75;
    grid.columns[1].format = PdfStringFormat(textDirection: PdfTextDirection.leftToRight,alignment: PdfTextAlignment.center);
    grid.columns[2].width = 75;
    grid.columns[2].format = PdfStringFormat(textDirection: PdfTextDirection.leftToRight,alignment: PdfTextAlignment.center);
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 1, left: 1, right: 1, top: 1);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 1, left: 1, right: 1, top: 1);
      }
    }
    return grid;
  }

  //Create PDF grid and return
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.

    grid.columns.add(count: 8);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    PdfFont myFont = PdfTrueTypeFont(font, 8);
    PdfFont myHeaderFont = PdfTrueTypeFont(font, 9);
    PdfGridStyle gridStyle = PdfGridStyle(
      cellSpacing: 0.5,
      cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
      borderOverlapStyle: PdfBorderOverlapStyle.inside,
      //backgroundBrush: PdfBrushes.dimGray,
      textBrush: PdfBrushes.black,
      font: myFont,
    );
    grid.rows.applyStyle(gridStyle);
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'TİP';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'EVRAK TİPİ';
    headerRow.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[2].value = 'SERİ-SIRA NO';
    headerRow.cells[2].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[3].value = 'TARİH';
    headerRow.cells[3].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[4].value = 'MEBLAĞ';
    headerRow.cells[4].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[5].value = 'BAKİYE';
    headerRow.cells[5].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[6].value = 'VADE';
    headerRow.cells[6].stringFormat.alignment = PdfTextAlignment.center;

    for(int i = 0; i < _cariEkstreList.length; i++){
      var formatMeblag= Foksiyonlar.formatMoney(_cariEkstreList[i].meblag);
      var formatbakiye= Foksiyonlar.formatMoney(_cariEkstreList[i].bakiye);
      var formatBelgeTarihi = DateFormat('dd.MM.yyyy').format(_cariEkstreList[i].belgeTarihi!);
      var formatVadeTarihi = DateFormat('dd.MM.yyyy').format(_cariEkstreList[i].vadeTarihi!);
      if(i == 0 ){
        if(_cariEkstreList[i].tip == "Alacak"){
          double devirBakiye = _cariEkstreList[0].bakiye! + _cariEkstreList[0].meblag!;
          addProducts("----","DEVİR BAKİYE","-----","-----", Foksiyonlar.formatMoney(devirBakiye),Foksiyonlar.formatMoney(devirBakiye),"----" ,grid);
        }else if(_cariEkstreList[0].tip == "Borç") {
          double devirBakiye = _cariEkstreList[0].bakiye! - _cariEkstreList[0].meblag!;
          addProducts("----","DEVİR BAKİYE","-----","-----", Foksiyonlar.formatMoney(devirBakiye),Foksiyonlar.formatMoney(devirBakiye),"----" ,grid);
        }
      }
      addProducts(_cariEkstreList[i].tip ?? "", _cariEkstreList[i].evrakTipi ?? "", "${_cariEkstreList[i].evrakSeri}-${_cariEkstreList[i].evrakSira}", formatBelgeTarihi, formatMeblag, formatbakiye, formatVadeTarihi, grid);
    }
    addProducts("","","","..", "","",".." ,grid);
    addProducts("","","","..", "","",".." ,grid);
    addProducts("","${DateFormat("dd.MM.yyyy").format(DateTime.now())} İtibariyle Güncel Bakiye*","","..", "","$bakiye",".." ,grid);
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[0].width = 40;
    grid.columns[1].width = 135;
    grid.columns[2].width = 70;
    grid.columns[3].width = 60;
    grid.columns[4].width = 75;
    grid.columns[5].width = 75;
    grid.columns[6].width = 60;

    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 2, left: 2, right: 2, top: 2);
      headerRow.cells[i].style.font = myHeaderFont;
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      row.style.font = myFont;
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 2, left: 2, right: 2, top: 2);
      }
    }
    return grid;
  }

  void addProducts(String tip,String evrakTipi,String seriSira,String belgeTarihi,String meblag,String bakiye,String vadeTarihi, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = tip;
    row.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[1].value = evrakTipi;
    row.cells[1].stringFormat.alignment = PdfTextAlignment.left;
    row.cells[2].value = seriSira;
    row.cells[2].stringFormat.alignment = PdfTextAlignment.left;
    row.cells[3].value = belgeTarihi;
    row.cells[3].stringFormat.alignment = PdfTextAlignment.center;
    row.cells[4].value = meblag;
    row.cells[4].stringFormat.alignment = PdfTextAlignment.right;
    row.cells[5].value = bakiye;
    row.cells[5].stringFormat.alignment = PdfTextAlignment.right;
    row.cells[6].value = vadeTarihi;
    row.cells[6].stringFormat.alignment = PdfTextAlignment.center;

  }

  Future<void> send(String path) async {

    Share.shareXFiles([XFile(path)]);


  }




  Widget _mailSecenekDialog(){
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 100,
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
                    alignment: Alignment.center,
                    child: Text("Mail(Eski)",style: GoogleFonts.roboto(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.bold),),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(context: context,builder: (context) => MailGonderPopUp(context,"Basit",ekstreTarihi: "${widget.ekstreTarihi.month}.${widget.ekstreTarihi.day}.${widget.ekstreTarihi.year}",data: widget.data,));
                  },
                ),),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(
                child: InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    child:  Text("PDF(Yeni)",style: GoogleFonts.roboto(color: Colors.blue.shade900,fontSize: 18,fontWeight: FontWeight.bold)),
                  ),
                  onTap: ()async {
                    Navigator.pop(context);
                    image =
                        PdfBitmap(await _readImageData());
                    font = await _readFontData();
                    generateReport();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                      title: 'Tip Filtre',
                      placeholder: 'Tip Filtrele',
                      selectedValue: _carikodFiltreler,
                      modalHeaderStyle: S2ModalHeaderStyle(
                          backgroundColor: Colors.blue.shade900),
                      onChange: (state) =>
                          setState(() => _carikodFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: tipFiltreList,
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
                                  _gridAra(_carikodFiltreler, _sektorFiltreler, _temsilciFiltreler);
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
                                _gridAra(_carikodFiltreler, _sektorFiltreler,_temsilciFiltreler);
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
                            alignment: Alignment(5, 20),

                            children: [
                              Container(
                                color: Colors.red,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Text("${_carikodFiltreler.length}", style: TextStyle(color: Colors.white)),
                              InkWell(
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        "Tip",
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
                                    "Tip",
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
                      title: 'Cins Filtre',
                      placeholder: 'Cins Filtrele',
                      selectedValue: _temsilciFiltreler,
                      modalHeaderStyle: S2ModalHeaderStyle(
                          backgroundColor: Colors.blue.shade900),
                      onChange: (state) => setState(() => _temsilciFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: cinsiFiltreList,
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
                                  _gridAra(_carikodFiltreler, _sektorFiltreler,_temsilciFiltreler);
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
                                _gridAra(_carikodFiltreler, _sektorFiltreler, _temsilciFiltreler);
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
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Text("${_temsilciFiltreler.length}",
                                  style: TextStyle(color: Colors.white)),
                              InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Cins",
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
                                    "Cins",
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
                        title: 'Evrak Tipi Filtre',
                        placeholder: 'Evrak Tipi Filtrele',
                        selectedValue: _sektorFiltreler,
                        modalHeaderStyle: S2ModalHeaderStyle(
                            backgroundColor: Colors.blue.shade900),
                        onChange: (state) =>
                            setState(() => _sektorFiltreler = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: evrakTipiFiltreList,
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
                                        _temsilciFiltreler);
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
                                      _temsilciFiltreler);
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
                                ),
                                InkWell(
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          "Evrak Tipi",
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
                                      "Evrak Tipi",
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
                  child: !timeSelected ?
                  InkWell(
                    onTap: () => callDatePicker().then((value) => setState((){_selectedTime = value;if(value != null) timeSelected = true;print(timeSelected);})),
                    child: Container(
                        child:  Center(
                          child: Text(
                            "Tarih",
                            style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                        )
                    ),
                  ) :
                  Stack(
                    alignment: Alignment(8,20),
                    children: [
                      Container(
                        color:  Colors.red,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Text(
                        "1",
                        style: TextStyle(color: Colors.white),
                      ),
                      InkWell(
                        onTap: () => callDatePicker().then((value) => setState((){_selectedTime = value;if(value != null) timeSelected = true;})),
                        child: Container(
                            child:  Center(
                              child: Text(
                                "Tarih",
                                style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ),
                            )
                        ),
                      ) ,
                    ],
                  )
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
                              _carikodFiltreler = [];
                              sektorFiltreMi = false;
                              temsilciFiltreMi = false;
                              carikodFiltreMi = false;
                              timeSelected = false;
                              _selectedTime = null;
                              _gridAra([], [], []);
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

  _gridAra(List<String?> a, List<String?> b, List<String?> c,) {
    List<CariEkstre> arananlarList = [];

    double toplamMeblag = 0;
    for (var value in aramaList) {
      if ((a.contains(value.tip) || a.isEmpty) &&
          (b.contains(value.evrakTipi) || b.isEmpty) &&
          (c.contains(value.cinsi) || c.isEmpty)){
        if(_selectedTime != null && value.isTarihi != null){
          if(value.isTarihi!.isBefore(_selectedTime!.add(Duration(days: 1)))){
            arananlarList.add(value);
            toplamMeblag += (value.meblag ?? 0);
          }
        }else{
          arananlarList.add(value);
          toplamMeblag += (value.meblag ?? 0);
        }
      }

    }
    setState(() {

      _cariEkstreList = arananlarList;
      if(arananlarList.isNotEmpty && (a.isNotEmpty || b.isNotEmpty || c.isNotEmpty || _selectedTime != null)){
        _cariEkstreList.add(CariEkstre.name(0, null, "", "", "", "", null, "", toplamMeblag, "", "Toplam", null));
      }

      _cariEkstreDataSource = BaseDataGridSource(_dataGridController,CariEkstre.buildDataGridRows(_cariEkstreList));
    });
  }

  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "BİTİŞ TARİHİ SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: _selectedTime ?? DateTime.now(),
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
  Future<DateTime?> callDatePicker() async {
    var order = await getDate();
    if(order != null){
      _selectedTime = order;
      print(order);
      setState((){});
      _gridAra(_carikodFiltreler, _sektorFiltreler,_temsilciFiltreler);
    }
    return order;
  }
}
