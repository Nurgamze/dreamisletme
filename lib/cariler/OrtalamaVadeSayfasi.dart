import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Listeler.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../widgets/MailGondermePopUp.dart';
import 'models/cari.dart';


class OrtalamaVade extends StatefulWidget {
  final DreamCari data;
  OrtalamaVade({required this.data});
  @override
  _OrtalamaVadeState createState() => _OrtalamaVadeState();
}

class _OrtalamaVadeState extends State<OrtalamaVade> {

  bool loading = false;
  String tutar = "";
  var ortVadeGun;
  Color? ortVadeGunColor;
  List<dynamic> listGelenVeri = [];


  var font;

  late OrtalamaVadeDataSource _ortalamaVadeDataSource;
  final DataGridController _dataGridController = DataGridController();

  @override
  void initState() {
    // TODO: implement initState
    _ortalamaVadeDataSource = OrtalamaVadeDataSource(_dataGridController);
    _vadeGetir();
    super.initState();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ortalamaVadeGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    return ConstScreen(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/dreambg.jpg"), fit: BoxFit.cover)),
        child: OrientationBuilder(
          builder: (context,currentOrientation){
            if(currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet){
              return HorizontalPage(_myGrid());
            }else{
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.blue.shade900,
                  actions: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.envelopeOpenText,color: Colors.white,),
                          tooltip: "Mail Gönder",
                          onPressed: () async {
                            //Grid Sonra Yapılacak
                            /*
                          image =
                              PdfBitmap(await _readImageData());
                          font = await _readFontData();
                          generateReport();*/
                            showDialog(context: context,builder: (context) => MailGonderPopUp(context,"OrtalamaVade",ekstreTarihi: DateTime.now().toString(),data: widget.data));
                          },),
                      ],
                    )
                  ],
                  title: Container(
                      child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
                  ),
                  centerTitle: true,
                ),
                body: !loading ? DreamCogs() :
                Column(
                  children: <Widget>[
                    SizedBox(height: 5,),
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/2-1,
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: 20,
                                child: Center(child: Text("Bakiye",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height:31,
                                child: Center(child: Text(tutar,style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.blue.shade900,width: 2,),
                                    color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2,),
                        Container(
                          width: MediaQuery.of(context).size.width/2-1,
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: 20,
                                child: Center(child: Text("Tanımlı Vade",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height:31,
                                child: Center(child: Text("${widget.data.vade}",style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.blue.shade900,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2,),
                    Container(
                      width: MediaQuery.of(context).size.width/1.5,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height: 21,
                            child: Center(child: Text("Kalan Borcun Vadesi",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                              color: ortVadeGunColor,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            height:31,
                            child: Center(child: Text("$ortVadeGun GÜN",style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                border: Border.all(color: ortVadeGunColor!,width: 2)
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2,),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                          color: Colors.blue.shade900,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        height: 30,
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: Text("EKSTRE HAREKETLERİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                    ),
                    Expanded(child: Container(
                        margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                        child: _myGrid()
                    ))
                  ],
                ),
              );
            }
          },
        )
      )
    );
  }

  Widget _myGrid() {
    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: Color.fromRGBO(235, 90, 12, 1),
        selectionColor:  Colors.blue,
        sortIconColor: Colors.white,
      ),
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _ortalamaVadeDataSource,
        controller: _dataGridController,
        allowSorting: false,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        columns: <GridColumn> [
          dreamColumn(columnName: 'normalIade',label:  "TÜR",minWidth: 120,alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'meblag',label:  "MEBLAĞ",),
          dreamColumn(columnName: 'kalanBorc',label:  "KALAN BORÇ",),
          dreamColumn(columnName: 'gecenGun',label:  "GEÇEN",),
          dreamColumn(columnName: 'kalanGun',label:  "KALAN",),
          dreamColumn(columnName: 'belgeTarihi',label:  "BELGE TARİHİ",),
          dreamColumn(columnName: 'vadeTarihi',label:  "VADE TARİHİ",),
          dreamColumn(columnName: 'evrakTipi',label: "EVRAK TİPİ",),
          dreamColumn(columnName: 'cinsi',label:  "CİNSİ",),
          dreamColumn(columnName: 'isTarihi',label:  "İŞ TARİHİ",),
          dreamColumn(columnName: 'evrakSeri',label:  "SERİ",),
          dreamColumn(columnName: 'evrakSira',label:  "SIRA",),
        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }
  _vadeGetir() async {
    double meblagTutar = 0;
    double hesapToplam = 0;
    double borcToplam = 0;
    double gecenBakiye00Gun = 0;
    double gecenBakiye30Gun = 0;
    double gecenBakiye60Gun = 0;
    String yazilacakVade = widget.data.vade == "PEŞİN" ? "0 GÜN" : "${widget.data.vade}";
    int vadeGun = int.parse(yazilacakVade.replaceAll(" GÜN", ""));
    var response = await http.get(Uri.parse("${Sabitler.url}/api/CariHesapEkstresi?VtIsim=${UserInfo.activeDB}&Customer=false&cariKod=${widget.data.kod}&ozet=false&Mobile=true&ekstreTarihi=&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200) {
      setState(() {
        var ekstreDetay = json.decode(response.body);
        listGelenVeri = ekstreDetay;
        for(int i = listGelenVeri.length-1 ; i > -1 ; i--){
          var kayitTip = listGelenVeri[i]['tip'].toString().toLowerCase();
          if (meblagTutar >= (widget.data.bakiye ?? 0)) break;
          if (kayitTip == "alacak") continue;

          if(listGelenVeri[i]['kayit'].toString() == "0"){
            if(listGelenVeri[i]['tip'].toString() == "Bakiye") tutar = listGelenVeri[i]['cinsi'];
            continue;
          }
          var meblag = listGelenVeri[i]['meblag'];
          meblagTutar += meblag;
          var belgeTarih = DateTime.parse(listGelenVeri[i]['belgeTarihi']);
          var vadeTarih = DateTime.parse(listGelenVeri[i]['vadeTarihi']);
          var gecenGun = (DateTime.now().difference(belgeTarih)).inDays;
          var kalanGun = vadeGun - gecenGun;
          if(listGelenVeri[i]['evrakTipi'].toString() == "Çek İade Çıkış Bordrosu"){
            gecenGun = (DateTime.now().difference(vadeTarih)).inDays;
            kalanGun = gecenGun * -1;
          }

          var kalanBorc = meblagTutar > (widget.data.bakiye ?? 0) ? meblag - (meblagTutar - (widget.data.bakiye ?? 0)) : meblag;
          borcToplam += kalanBorc;
          hesapToplam += kalanBorc * kalanGun;

          if (gecenGun >= 0  && gecenGun < 30)    gecenBakiye00Gun += kalanBorc; //00-29 Gun
          if (gecenGun >= 30 && gecenGun < 60)    gecenBakiye30Gun += kalanBorc; //30-59 Gun
          if (gecenGun >= 60)                     gecenBakiye60Gun += kalanBorc; //60 ve Ustu
          OrtalamaVadeGridModel cariEkstreler = OrtalamaVadeGridModel(listGelenVeri[i]["bakiye"],DateTime.parse(listGelenVeri[i]["belgeTarihi"]), listGelenVeri[i]["cinsi"], listGelenVeri[i]["evrakSeri"], listGelenVeri[i]["evrakSira"],listGelenVeri[i]["evrakTipi"], DateTime.parse(listGelenVeri[i]["isTarihi"]), listGelenVeri[i]["kayit"], listGelenVeri[i]["meblag"], listGelenVeri[i]["normalIade"], listGelenVeri[i]["tip"],DateTime.parse(listGelenVeri[i]["vadeTarihi"]),kalanBorc,gecenGun.toString(),kalanGun.toString());
          ortalamaVadeGridList.add(cariEkstreler);
        }

        ortalamaVadeGridList.add(OrtalamaVadeGridModel(null, null, "", "", "", "", null, "-----", null, "-----", "", null, null, "", ""));
        ortalamaVadeGridList.add(OrtalamaVadeGridModel(null,null, "", "", "", "", null, "", gecenBakiye00Gun, "0-30 Gün Arası", "", null, null, "", ""));
        ortalamaVadeGridList.add(OrtalamaVadeGridModel(null, null, "", "", "", "", null, "", gecenBakiye30Gun, "30-60 Geciken", "", null, null, "", ""));
        ortalamaVadeGridList.add(OrtalamaVadeGridModel(null, null, "", "", "", "", null, "", gecenBakiye60Gun, "60+ Geciken", "", null, null, "", ""));
        ortVadeGun = (hesapToplam/borcToplam).round();
        ortVadeGun < 0 ? ortVadeGunColor = Colors.deepOrange : ortVadeGunColor = Colors.green;
        loading = !loading;
        _ortalamaVadeDataSource = OrtalamaVadeDataSource(_dataGridController);
      });

    }else{
      print(response.body);
    }
  }








}

class OrtalamaVadeDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;


  void buildDataGridRows() {
    dataGridRows = ortalamaVadeGridList.map<DataGridRow>((e) =>
        DataGridRow(
            cells: [
              DataGridCell<String>(
                  columnName: 'normalIade', value: e.normalIade),
              DataGridCell<double>(columnName: 'meblag', value: e.meblag),
              DataGridCell<double>(columnName: 'kalanBorc', value: e.kalanBorc),
              DataGridCell<String>(columnName: 'gecenGun', value: e.gecenGun),
              DataGridCell<String>(columnName: 'kalanGun', value: e.kalanGun),
              DataGridCell<DateTime>(
                  columnName: 'belgeTarihi', value: e.belgeTarihi),
              DataGridCell<DateTime>(
                  columnName: 'vadeTarihi', value: e.vadeTarihi),
              DataGridCell<String>(columnName: 'evrakTipi', value: e.evrakTipi),
              DataGridCell<String>(columnName: 'cinsi', value: e.cinsi),
              DataGridCell<DateTime>(columnName: 'isTarihi', value: e.isTarihi),
              DataGridCell<String>(columnName: 'evrakSeri', value: e.evrakSeri),
              DataGridCell<String>(columnName: 'evrakSira', value: e.evrakSira),
            ]
        )).toList();
  }

  final DataGridController dataGridController;

  OrtalamaVadeDataSource(this.dataGridController) {
    buildDataGridRows();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    TextStyle getSelectionStyle() {
      String tur = row.getCells()[0].value.toString();
      if(tur.contains('0')){
        return (TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black));
      }
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
        if (index == ortalamaVadeGridList.length - 3) {
          return Colors.yellowAccent.shade700;
        } else if (index == ortalamaVadeGridList.length - 2) {
          return Colors.orange;
        } else if (index == ortalamaVadeGridList.length - 1) {
          return Color(0xffe41111);
        }
        return Colors.grey.shade300;
      } else {
        if (index == ortalamaVadeGridList.length - 3) {
          return Colors.yellowAccent.shade700;
        } else if (index == ortalamaVadeGridList.length - 2) {
          return Colors.orange;
        } else if (index == ortalamaVadeGridList.length - 1) {
          return Color(0xffe41111);
        }
        return Colors.white;
      }
    }
    return DataGridRowAdapter(
        color: getRowBackGroundColor(),
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: alignValue(e.value),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(e.value == null ? "" : formatValue(e.value).toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getSelectionStyle(),),
          );
        }).toList()
    );
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}