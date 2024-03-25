/*
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;
import '../lojistik/widgets/HorizontalPage.dart';
import '../modeller/Listeler.dart';



class SiparislerView22 extends StatefulWidget {
  const SiparislerView22({Key? key}) : super(key: key);

  @override
  State<SiparislerView22> createState() => _SiparislerView22State();
}

class _SiparislerView22State extends State<SiparislerView22> {


  DataGridController _dataGridController = DataGridController();
  late TumAcikSiparislerGridSource _tumAcikSiparisDataSource;
  List<TumAcikSiparislerGridModel> tumAcikSiparisGridList = [];
  bool loading = false;


  @override
  void initState() {
    super.initState();
    _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(_dataGridController);
    _siparisleriGetir();
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    super.dispose();
    tumAcikSiparisGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }



  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: Container(
          // decoration: BoxDecoration(
          //     image: DecorationImage(
          //         image: AssetImage("assets/images/dreambg.jpg"), fit: BoxFit.cover)),
          child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ?
          HorizontalPage(_grid()) :
          Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.blue.shade900,
                centerTitle: true,
                title: Container(
                    child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
                ),
              ),
              body: !loading ? DreamCogs() :  Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          margin: EdgeInsets.only(top: 5,left: 5,bottom: 0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(3, 5),
                                ),
                              ],
                              color: Colors.white
                          ),
                          width: MediaQuery.of(context).size.width * 6 / 7 - 10,
                          height: 50,
                        ),
                        InkWell(
                          child: Container(
                              margin: EdgeInsets.only(left: 5,top: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: Offset(3, 5),
                                  ),
                                ],
                              ),
                              width: MediaQuery.of(context).size.width/7-5,
                              height: 50,
                              padding: EdgeInsets.all(5),
                              child: Center(child: FaIcon(FontAwesomeIcons.search,color: Colors.blue.shade900,size: 18,),)
                          ),
                          onTap: () async{
                            if(await Foksiyonlar.internetDurumu(context)){
                            //  _siparisleriGetir();
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                          color: Colors.blue.shade900,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text( "AÇIK SİPARİŞLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                            //Text(widget.data.stokKodu,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                          ],)
                    ),
                    Expanded(child:  Container(
                        margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                        child: _grid()
                    ))
                  ],
                ),
              )
          ),
        )
    );
  }

//_grid kolonları getirdi.
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
        source: _tumAcikSiparisDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'Sipariş Tarihi',label: 'SİPARİŞ TARİHİ'),
          dreamColumn(columnName: 'Sipariş No',label: 'SİPARİŞ NO'),
          dreamColumn(columnName: 'Teslim Tarihi',label: 'SİPARİŞ TESLİM TARİHİ'),
          dreamColumn(columnName: 'Müşteri Kodu',label: 'CARİ KODU'),
          dreamColumn(columnName: 'Müşteri',label: 'CARİ ADI'),
          dreamColumn(columnName: 'TEMSILCI',label: 'TEMSİLCİ'),
          dreamColumn(columnName: 'Stok Kodu',label: 'SİPARİŞ STOK KODU'),
          dreamColumn(columnName: 'Stok İsmi',label: 'SİPARİŞ STOK İSMİ'),
          dreamColumn(columnName: 'Net Fiyat',label: 'SİPARİŞ NET FİYAT'),
          dreamColumn(columnName: 'Döviz',label: 'DOVİZ'),
          dreamColumn(columnName: 'Tutar',label: 'TUTAR'),
          dreamColumn(columnName: 'TL Tutar',label: 'TL TUTAR'),
          dreamColumn(columnName: 'SiparisMiktar',label: 'SİPARİŞ MİKTAR'),
          dreamColumn(columnName: 'Kalan Miktar',label: 'KALAN MİKTAR'),
          dreamColumn(columnName: 'Kalan 2',label: 'KALAN2 MİKTAR'),
          dreamColumn(columnName: 'Mevcut Stok',label: 'MEVCUT STOK '),
          dreamColumn(columnName: 'VerilenSiparis',label: 'VERİLEN SİPARİŞ '),
          dreamColumn(columnName: 'Açıklama 1',label: 'AÇIKLAMA 1'),
          dreamColumn(columnName: 'Açıklama 2',label: 'AÇIKLAMA 2'),
        ],

        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 10), (){
            FocusScope.of(context).requestFocus(new FocusNode());
            // if(value.rowColumnIndex.rowIndex > 0){
            //   var row = _dataGridController.selectedRow!.getCells();
            //   _dataGridController.selectedIndex = -1;
            //   //Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: FaturaDetaySayfasi(row[7].value,row[6].value,row[11].value)));
            //
            // }
          });
        },
      ),
    );
  }




  _siparisleriGetir() async{
    var response = await http.get(Uri.parse("http://api.sds.com.tr/api/TumAcikSiparisler?vtName=${UserInfo.activeDB}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode==200){
      var acikSiparislerJson = jsonDecode(response.body);
      for(var acikSiparisler in acikSiparislerJson){
        print(acikSiparisler);
        TumAcikSiparislerGridModel tumAcikSiparis =  TumAcikSiparislerGridModel(
          DateTime.parse(acikSiparisler['Sipariş Tarihi'].toString()),
          acikSiparisler['Sipariş No'],
          DateTime.parse(acikSiparisler['Teslim Tarihi'].toString()),
          acikSiparisler['Müşteri Kodu'],
          acikSiparisler['Müşteri'],
          acikSiparisler['TEMSILCI'],
          acikSiparisler['Stok Kodu'],
          acikSiparisler['Stok İsmi'],
          double.parse(acikSiparisler['Net Fiyat'].toString().replaceAll(',', '.')),
          acikSiparisler['Döviz'],
          double.parse(acikSiparisler['Tutar'].toString().replaceAll(',', '.')),
          double.parse(acikSiparisler['TL Tutar'].toString().replaceAll(',', '.')),
          double.parse(acikSiparisler['SiparisMiktar'].toString().replaceAll(',', '.')),
          double.parse(acikSiparisler['Kalan Miktar'].toString().replaceAll(',', '.')),
          double.parse(acikSiparisler['Kalan 2'].toString().replaceAll(',', '.')),
          double.parse(acikSiparisler['VerilenSiparis'].toString().replaceAll(',', '.')),
          double.parse(acikSiparisler['Kalan 2'].toString().replaceAll(',', '.')),
          acikSiparisler['Açıklama 1'],
          acikSiparisler['Açıklama 2'],
        );
        tumAcikSiparisGridList.add(tumAcikSiparis);
      }
      setState(() {
        _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(_dataGridController);
        loading = true;
        //aramaList = tumAcikSiparisGridList;
      });
    }else{
      setState(() {
        _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(_dataGridController);
        acikSiparisGridList.clear();
        loading = true;
      });
    }
  }




}

class TumAcikSiparislerGridSource  extends DataGridSource{
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;


  void buildDataGridRows() {
    print("builddata içindeyimmm");
    dataGridRows = tumAcikSiparisGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<DateTime>(columnName: 'Sipariş Tarihi',value: e.sip_tarih),
          DataGridCell<String>(columnName: 'Sipariş No',value: e.sip_no),
          DataGridCell<DateTime>(columnName: 'Teslim Tarihi',value: e.sip_teslim_tarih),
          DataGridCell<String>(columnName: 'Müşteri Kodu',value: e.musteriKod),
          DataGridCell<String>(columnName: 'Müşteri',value: e.musteriIsim),
          DataGridCell<String>(columnName: 'TEMSILCI',value: e.temsilci),
          DataGridCell<String>(columnName: 'Stok Kodu',value: e.sipStokKod),
          DataGridCell<String>(columnName: 'Stok İsmi',value: e.sipStokIsim),
          DataGridCell<double>(columnName: 'Net Fiyat',value: e.sipNetFiyat),
          DataGridCell<String>(columnName: 'Döviz',value: e.dovizCinsi),
          DataGridCell<double>(columnName: 'Tutar',value: e.tutar),
          DataGridCell<double>(columnName: 'TL Tutar',value: e.TlTutar),
          DataGridCell<double>(columnName: 'SiparisMiktar',value: e.sipMiktar),
          DataGridCell<double>(columnName: 'Kalan Miktar',value: e.kalanMiktar),
          DataGridCell<double>(columnName: 'Kalan 2',value: e.kalan2),
          DataGridCell<double>(columnName: 'Mevcut Stok',value: e.mevcutStok),
          DataGridCell<double>(columnName: 'VerilenSiparis',value: e.verilenSip),
          DataGridCell<String>(columnName: 'Açıklama 1',value: e.aciklama1),
          DataGridCell<String>(columnName: 'Açıklama 2',value: e.aciklama2),

        ]
    )).toList();
    print("ddataGridRows ${dataGridRows}");
  }

   final DataGridController dataGridController;
  TumAcikSiparislerGridSource(this.dataGridController) {
    buildDataGridRows();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    Color getRowBackGroundColor() {
      final int index = effectiveRows.indexOf(row);
      if(index %2 != 0){
        return Colors.grey.shade300;
      }else {
        return Colors.white;
      }
    }
    TextStyle getSelectionStyle() {
      if(dataGridController.selectedRows.contains(row)){
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }else{
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black));
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

*/
