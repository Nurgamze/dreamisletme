import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../modeller/DreamCogsGif.dart';
import '../../modeller/GridListeler.dart';
import '../../modeller/GridModeller.dart';
import '../../modeller/Modeller.dart';
import '../widgets/HorizontalPage.dart';
import '../widgets/const_screen.dart';

class StokKimlerdenAlinmisSayfasi extends StatefulWidget {
  final String stokKodu;
  StokKimlerdenAlinmisSayfasi({required this.stokKodu});
  @override
  _StokKimlerdenAlinmisSayfasiState createState() => _StokKimlerdenAlinmisSayfasiState();
}


class _StokKimlerdenAlinmisSayfasiState extends State<StokKimlerdenAlinmisSayfasi> {

  TextEditingController _aramaController = new TextEditingController();
  DataGridController dataGridController = DataGridController();
  late StokKimlerdenAlinmisDataSource _stokKimlerdenAlinmisDataSource;
  bool loading = false;
  List<StokKimlerdenAlinmisGridModel> aramaList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stokKimlerdenAlinmisDataSource = StokKimlerdenAlinmisDataSource(dataGridController);
    _alinanlariGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stokKimlerdenAlinmisGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? 
      HorizontalPage(_grid(),) :
      Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Container(
                child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
          ),
          body: !loading ? DreamCogs() :
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    margin: EdgeInsets.only(top: 5,left: 5,bottom: 5),
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
                    child: Center(child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                            onPressed: () {
                              _aramaController.text = "";
                              FocusScope.of(context).unfocus();
                              _satisAra();
                            },
                          )
                      ),
                      controller: _aramaController,
                      onChanged: (v) {
                        _satisAra();
                      },
                    ),),
                    width: MediaQuery.of(context).size.width * 6 / 7 - 10,
                    height: 50,
                  ),
                  InkWell(
                    child: Container(
                        margin: EdgeInsets.only(left: 5),
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
                        _satisAra();
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
                      Text("KİMLERDEN ALINMIŞ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                      Text("${widget.stokKodu}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                    ],)
              ),
              Expanded(child: Container(
                margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                child: _grid(),
              ))
            ],
          )
      )
    );

  }
  
  
  Widget _grid() { 
    return  SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        controller: dataGridController,
        selectionMode: SelectionMode.single,
        allowSorting: true,
        allowTriStateSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        source: _stokKimlerdenAlinmisDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'cariKodu', label: 'CARİ KODU',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'cariAdi', label: 'CARİ ADI',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'temsilci', label: 'TEMSİLCİ',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'tarih',label : "TARİH",),
          dreamColumn(columnName: 'miktar', label: 'MİKTAR',),
          dreamColumn(columnName: 'birim', label: 'BİRİM',),
          dreamColumn(columnName: 'birimFiyat',label:'BİRİM FİYAT',),
          dreamColumn(columnName: 'paraBirimi', label: 'PARA BİRİMİ',),
          dreamColumn(columnName: 'dovizBirimFiyat', label: 'DÖVİZ BİRİM FİYAT',),
          dreamColumn(columnName: 'doviz', label: 'DÖVİZ',),
          dreamColumn(columnName: 'kur', label: 'KURU',),
          dreamColumn(columnName: 'turu', label: 'TÜRÜ',),
          dreamColumn(columnName: 'evrak', label: 'EVRAK',),
        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }
  _satisAra() async {
    List<StokKimlerdenAlinmisGridModel> arananlarList = [];
    for(var cari in aramaList){
      if(cari.cariKodu!.toLowerCase().contains(_aramaController.text) || cari.cariAdi!.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(cari);
      }
    }
    setState(() {
      stokKimlerdenAlinmisGridList = arananlarList;
      _stokKimlerdenAlinmisDataSource = StokKimlerdenAlinmisDataSource(dataGridController);
    });
  }

  _alinanlariGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/StokKimlerdenAlinmis?VtIsim=${UserInfo.activeDB}&StokKodu=${widget.stokKodu}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
    print(response.statusCode);
    print(response.body);
    print(response.headers);
    if(response.statusCode == 200){
      var alislarJson = jsonDecode(response.body);
      for(var alislar in alislarJson) {
        StokKimlerdenAlinmisGridModel alis = StokKimlerdenAlinmisGridModel(
            alislar['cariKodu'], alislar['cariAdi'],alislar['temsilci'],
            DateTime.parse(alislar['tarih'].toString()), alislar['miktar'],
            alislar['birim'],alislar['birimFiyat'], alislar['paraBirimi'],
            alislar['dovizBirimFiyat'],alislar['doviz'],alislar['kur'],
            alislar['turu'],alislar['evrak']);
        setState(() {
          stokKimlerdenAlinmisGridList.add(alis);
        });
      }
      setState(() {
        aramaList = stokKimlerdenAlinmisGridList;
        loading = true;
        _stokKimlerdenAlinmisDataSource = StokKimlerdenAlinmisDataSource(dataGridController);
      });
    }else{
      setState(() {
        stokKimlerdenAlinmisGridList.clear();
        loading = true;
        _stokKimlerdenAlinmisDataSource = StokKimlerdenAlinmisDataSource(dataGridController);
      });
    }
  }
}





class StokKimlerdenAlinmisDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = stokKimlerdenAlinmisGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'cariKodu',value: e.cariKodu),
          DataGridCell<String>(columnName: 'cariAdi',value: e.cariAdi),
          DataGridCell<String>(columnName: 'temsilci',value: e.temsilci),
          DataGridCell<DateTime>(columnName: 'tarih',value: e.tarih),
          DataGridCell<double>(columnName: 'miktar',value: e.miktar),
          DataGridCell<String>(columnName: 'birim',value: e.birim),
          DataGridCell<double>(columnName: 'birimFiyat',value: e.birimFiyat),
          DataGridCell<String>(columnName: 'paraBirimi',value: e.paraBirimi),
          DataGridCell<String>(columnName: 'dovizBirimFiyat',value: e.dovizBirimFiyat),
          DataGridCell<String>(columnName: 'doviz',value: e.doviz),
          DataGridCell<String>(columnName: 'kur',value: e.kur),
          DataGridCell<String>(columnName: 'turu',value: e.turu),
          DataGridCell<String>(columnName: 'evrak',value: e.evrak),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  StokKimlerdenAlinmisDataSource(this.dataGridController) {
    buildDataGridRows();
  }
  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    TextStyle getSelectionStyle() {
      if(dataGridController.selectedRows.contains(row)){
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.white));
      }else{
        return(TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black));
      }
    }
    Color getRowBackGroundColor() {
      final int index = effectiveRows.indexOf(row);
      if(index %2 != 0){
        return Colors.grey.shade300;
      }else {
        return Colors.white;
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