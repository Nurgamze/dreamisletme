
import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/core/models/base_data_grid_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../core/services/api_service.dart';
import 'cari_ekstre_view.dart';
import 'models/cari.dart';
import 'models/cari_donemsel_bakiye.dart';


class CariDonemselBakiyeView extends StatefulWidget {
  final String maliYili;
  final DreamCari data;
  CariDonemselBakiyeView({Key? key,required this.maliYili,required this.data});
  @override
  State<CariDonemselBakiyeView> createState() => _CariDonemselBakiyeViewState();
}

class _CariDonemselBakiyeViewState extends State<CariDonemselBakiyeView> {

  bool loading = false;
  late PdfImage image;
  var font;

  DataGridController _dataGridController = DataGridController();
  late BaseDataGridSource _cariDonemselBakiyeDataSource;
  
  List<CariDonemselBakiye> _cariDonemselBakiyeList = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Fluttertoast.showToast(
        msg: "İstediğiniz ayın satırına dokunarak faturaları görebilirsiniz",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.blue.shade900,
        fontSize: 14.0
    );
    _cariDonemselBakiyeDataSource = BaseDataGridSource(_dataGridController,CariDonemselBakiye.buildDataGridRows(_cariDonemselBakiyeList));
    _raporGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    return ConstScreen(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue.shade900,
            title: Text("Dönemsel Bakiye"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.envelopeOpenText,color: Colors.white,),
                    tooltip: "Mail Gönder",
                    onPressed: () async {
                      _auditRequest();
                      image =
                          PdfBitmap(await _readImageData());
                      font = await _readFontData();
                      generateReport();

                    },),
                ],
              )
            ],
          ),
          body: !loading ? DreamCogs() :
          SfDataGridTheme(
            data: myGridTheme,
            child: SfDataGrid(
              selectionMode: SelectionMode.single,
              columnWidthMode: ColumnWidthMode.auto,
              columnSizer: customColumnSizer,
              gridLinesVisibility: GridLinesVisibility.vertical,
              headerGridLinesVisibility: GridLinesVisibility.vertical,
              headerRowHeight: 35,
              rowHeight: 35,
              controller: _dataGridController,
              source: _cariDonemselBakiyeDataSource,
              allowSorting: true,
              allowTriStateSorting: true,
              columns: <GridColumn> [
                dreamColumn(columnName: 'id', label: 'ID',alignment: Alignment.center),
                dreamColumn(columnName: 'donem', label: 'Dönem',alignment: Alignment.center),
                dreamColumn(columnName: 'borc', label: 'Borç',alignment: Alignment.center),
                dreamColumn(columnName: 'alacak',label:'Alacak',alignment: Alignment.center),
                dreamColumn(columnName: 'bakiye', label: 'Bakiye',alignment: Alignment.center),

              ],
              onCellTap: (v) {
                Future.delayed(Duration(milliseconds: 50), () async{
                  var row = _dataGridController.selectedRow!.getCells();
                  int selectedMonth = row[0].value;
                  if(selectedMonth >0 && selectedMonth < 13){
                    int lastday = DateTime(int.parse(widget.maliYili), selectedMonth + 1, 0).day;
                    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: CariEkstreView(ekstreTarihi: DateTime(int.parse(widget.maliYili),selectedMonth,1),ekstreSonTarihi: "$selectedMonth.$lastday.${widget.maliYili}", data: widget.data,)));
                  }
                  FocusScope.of(context).requestFocus(new FocusNode());
                });
              },
            ),
          ),
        )
    );

  }

  _raporGetir() async {
    var queryParameters = {
      "VtIsim" : UserInfo.activeDB,
      "Customer" : false,
      "cariKod" : widget.data.kod,
      "maliYil" : widget.maliYili,
      "ozet" : false,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId,
    };
    var serviceData = await APIService.getDataWithModel<List<CariDonemselBakiye>,CariDonemselBakiye>("DonemselBakiyelerRaporu", queryParameters, CariDonemselBakiye());
    print(serviceData.statusCode);
    if(serviceData.statusCode == 200){
      _cariDonemselBakiyeList = serviceData.responseData ?? [];
      
    }else if(serviceData.statusCode == 404) {
      _cariDonemselBakiyeList.clear();
    }
    loading = true;
    setState(() {});
    _cariDonemselBakiyeDataSource = BaseDataGridSource(_dataGridController,CariDonemselBakiye.buildDataGridRows(_cariDonemselBakiyeList));
  }

  _auditRequest() async {
    var queryParameters = {
      "VtIsim" : UserInfo.activeDB,
      "Customer" : false,
      "cariKod" : widget.data.kod,
      "maliYil" : widget.maliYili,
      "ozet" : false,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId,
    };
    await APIService.getData("MailGondermeAudit", queryParameters);
  }

  bool checkIsMail(String mailAdress){
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(mailAdress)) ? false : true;
  }

  Future<void> generateReport() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult? result = drawHeader(page, pageSize, grid);
    //Draw grid
    drawGrid(page, grid, result!);
    //Add invoice footer
    //drawFooter(page, pageSize);
    //Save and launch the document
    final List<int> bytes = await document.save();
    //Dispose the document.
    document.dispose();
    //Get the storage folder location using path_provider package.
    final Directory directory =
    await path_provider.getTemporaryDirectory();
    final String path = directory.path;
    final File file = File('$path/Donemsel_Bakiye_${widget.maliYili}.pdf');
    await file.writeAsBytes(bytes);


    await send('$path/Donemsel_Bakiye_${widget.maliYili}.pdf');

    //await open_file.OpenFile.open('$path/output.pdf');
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
    double imageTop = UserInfo.activeDB == "MikroDB_V16_12" ? 60: 20;
    page.graphics.drawImage(
        image, Rect.fromLTWH(20, imageTop, imageWidth, imageHeight));
    //Draw text
    page.graphics.drawString('Alıcı: ${widget.data.unvan}',
        PdfTrueTypeFont(font, 11),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(100, 0, pageSize.width - 120, 100),format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString('Bu belgedeki bilgiler size özeldir ve 3. şahıslarla paylaşılmamalıdır.\nSadece bilgi amaçlı olup farklılık olması durumunda $footerSirket kayıtları geçerlidir.',
        PdfTrueTypeFont(font, 11),
        brush: PdfBrushes.black, bounds: Rect.fromLTWH(100, pageSize.height-100, pageSize.width - 110, 100),format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle));


    return PdfTextElement(text: "${widget.maliYili} Yılına Ait Dönemsel Bakiyeniz Aşağıdaki Gibidir.", font: PdfTrueTypeFont(font, 11),).draw(
      page: page,
      bounds: Rect.fromLTWH(125, 100, pageSize.width - 130, 100),);
  }

  //Draws the grid
  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(10, result.bounds.bottom + 20, 800, 0))!;
  }

  //Create PDF grid and return
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 12);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Dönem';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Borç';
    headerRow.cells[1].stringFormat.alignment = PdfTextAlignment.right;
    headerRow.cells[2].value = 'Alacak';
    headerRow.cells[2].stringFormat.alignment = PdfTextAlignment.right;
    headerRow.cells[3].value = 'Bakiye';
    headerRow.cells[3].stringFormat.alignment = PdfTextAlignment.right;
    //Add rows
    for(var addRow in _cariDonemselBakiyeList){
      addProducts(addRow.donem ?? "",addRow.borc ?? 0,addRow.alacak ?? 0,addRow.bakiye ?? 0,grid);
    }
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[0].width = 80;
    grid.columns[0].format = PdfStringFormat(textDirection: PdfTextDirection.leftToRight,alignment: PdfTextAlignment.left);
    grid.columns[1].width = 80;
    grid.columns[2].width = 80;
    grid.columns[3].width = 80;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void addProducts(String donem, double borc, double alacak,double bakiye, PdfGrid grid) {
    var formatAlacak = Foksiyonlar.formatMoney(alacak);
    var formatbakiye= Foksiyonlar.formatMoney(bakiye);
    var formatborc = Foksiyonlar.formatMoney(borc);
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = donem.padRight(10);
    //row.cells[0].stringFormat.alignment = PdfTextAlignment.left;
    row.cells[1].value = formatborc;
    row.cells[1].stringFormat.alignment = PdfTextAlignment.right;
    row.cells[2].value = formatAlacak;
    row.cells[2].stringFormat.alignment = PdfTextAlignment.right;
    row.cells[3].value = formatbakiye;
    row.cells[3].stringFormat.alignment = PdfTextAlignment.right;
  }

  Future<void> send(String path) async {
    String mailbody = UserInfo.activeDB == "MikroDB_V16_12" ? '''Sayın ${widget.data.unvan}

${widget.maliYili} tarihli dönemsel bakiyeniz, bizim kayıtlarımıza göre mail size ulaştığı anda ekteki gibidir.

Mail ve ekteki bilgiler size özeldir ve 3. şahıslarla paylaşılmamalıdır. Sadece bilgi amaçlı olup farklılık olması durumunda ZENİTLED kayıtları geçerlidir.

ZENIT LED AYDINLATMA VE TEKNLOJILERI''' :
    '''Sayın ${widget.data.unvan}

${widget.maliYili} tarihli dönemsel bakiyeniz, bizim kayıtlarımıza göre mail size ulaştığı anda ekteki gibidir.

Mail ve ekteki bilgiler size özeldir ve 3. şahıslarla paylaşılmamalıdır. Sadece bilgi amaçlı olup farklılık olması durumunda SDS kayıtları geçerlidir.

SDS SATIŞ DESTEK SİSTEMLERİ''';
    if (Platform.isIOS) {
      final bool canSend = await FlutterMailer.canSendMail();
    }

    // Platform messages may fail, so we use a try/catch PlatformException.
    final MailOptions mailOptions = MailOptions(
      body: mailbody,
      subject: "Dönemsel Bakiye",
      recipients: ["${widget.data.email}"],
      isHTML: false,
      // bccRecipients: ['other@example.com'],
      //ccRecipients: <String>['third@example.com'],
      attachments: [path],
    );

    String platformResponse;
    if(widget.data.email == "" || widget.data.email == null) {
      showDialog(context: context,builder: (context) => BilgilendirmeDialog("Cari karta kayıtlı mail bulunmamaktadır maili kendiniz girmeniz gerekecektir\nCari karta mail tanımlarsanız, otomatik gelecektir.")).then((value) async {
        try {
          final MailerResponse response = await FlutterMailer.send(mailOptions);
          switch (response) {
            case MailerResponse.saved:
              platformResponse = 'mail was saved to draft';
              break;
            case MailerResponse.sent:
              platformResponse = 'mail was sent';
              break;
            case MailerResponse.cancelled:
              platformResponse = 'mail was cancelled';
              break;
            case MailerResponse.android:
              platformResponse = 'intent was success';
              break;
            default:
              platformResponse = 'unknown';
              break;
          }
        } on PlatformException catch (error) {
          platformResponse = error.toString();
          print(error);
          if (!mounted) {
            return;
          }
        } catch (error) {
          platformResponse = error.toString();
        }
      });
    }else{
      try {
        final MailerResponse response = await FlutterMailer.send(mailOptions);
        switch (response) {
          case MailerResponse.saved:
            platformResponse = 'mail was saved to draft';
            break;
          case MailerResponse.sent:
            platformResponse = 'mail was sent';
            break;
          case MailerResponse.cancelled:
            platformResponse = 'mail was cancelled';
            break;
          case MailerResponse.android:
            platformResponse = 'intent was success';
            break;
          default:
            platformResponse = 'unknown';
            break;
        }
      } on PlatformException catch (error) {
        platformResponse = error.toString();
        print(error);
        if (!mounted) {
          return;
        }
      } catch (error) {
        platformResponse = error.toString();
      }
    }



  }
}
