import 'dart:convert';import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
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

class DepodakiMiktarlarDetaySayfasi extends StatefulWidget {

  final bool merkezMi;
  final StoklarGridModel data;
  DepodakiMiktarlarDetaySayfasi(this.merkezMi,{required this.data});
  @override
  _DepodakiMiktarlarDetaySayfasiState createState() => _DepodakiMiktarlarDetaySayfasiState();
}

class _DepodakiMiktarlarDetaySayfasiState extends State<DepodakiMiktarlarDetaySayfasi> {

  TextEditingController _aramaController = new TextEditingController();

  DataGridController dataGridController = DataGridController();
  late DepoMiktarGridSource _depoMiktarGridSource;

  bool loading = false;
  List<DepoMiktarlariGridModel> aramaList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _depoMiktarGridSource = DepoMiktarGridSource(dataGridController);
    _depoMiktarlariGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    depoMiktarlariGridList.clear();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }
  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
        child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid()) :
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
            Container(
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
                        child: Center(child: TextFormField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Şube adı veya Depo adı arayınız",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                                onPressed: () {
                                  _aramaController.text = " ";
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
                      height:50,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(widget.merkezMi ? "SDS DEPOLAR" : " TÜM DEPOLAR",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                          Text(widget.data.stokKodu,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                          Text(widget.data.stokIsim,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
                        ],)
                  ),
                  Expanded(child:  Container(
                      margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                      child: _grid()
                  ))
                ],
              ),
            )
        )
    );
  }

  Widget _grid(){
    return  SfDataGridTheme(
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
        controller: dataGridController,
        source: _depoMiktarGridSource,
        columns: <GridColumn> [
         // dreamColumn(columnName: 'SubeKodu', label: 'subeKodu',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'SubeAdi', label: 'ŞUBE ADI',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'DepoAdi',label : 'DEPO ADI', ),
         // dreamColumn(columnName: 'DepoKodu', label: 'depoKodu',),
         // dreamColumn(columnName: 'StokKodu', label: 'stokKodu',minWidth: 140),
         // dreamColumn(columnName: 'StokAdi', label: 'stokAdi',),
          dreamColumn(columnName: 'StokMiktari', label : 'STOK MİKTARI',),
        ],
        onCellTap: (value) async {
          Future.delayed(Duration(milliseconds: 10), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }

  _satisAra() async {
    List<DepoMiktarlariGridModel> arananlarList = [];
    for(var stok in aramaList){
      if(stok.subeAdi!.toLowerCase().contains(_aramaController.text) || stok.depoAdi!.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(stok);
      }
    }
    setState(() {
      depoMiktarlariGridList = arananlarList;
      _depoMiktarGridSource = DepoMiktarGridSource(dataGridController);
    });
  }

  _depoMiktarlariGetir() async {
    String? gidecekVt = widget.merkezMi ? "MikroDB_V16_01" : UserInfo.activeDB;
    var response = await http.get(Uri.parse("${Sabitler.url}/api/TumStoklar?vtName=$gidecekVt&stokkod=${widget.data.stokKodu}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey" : Sabitler.apiKey});
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      var depoMiktarJson = jsonDecode(response.body);
      for(var depoMiktar in depoMiktarJson) {
        DepoMiktarlariGridModel bbbb = DepoMiktarlariGridModel(
            depoMiktar['SubeKodu'],
            depoMiktar['SubeAdi'],
            depoMiktar['DepoAdi'],
            depoMiktar['DepoKodu'] ,
            depoMiktar['StokKodu'],
            depoMiktar['StokAdi'],
            depoMiktar['StokMiktari'],
        );
        depoMiktarlariGridList.add(bbbb);
      }

      setState(() {
        _depoMiktarGridSource = DepoMiktarGridSource(dataGridController);
        loading = true;
        aramaList = depoMiktarlariGridList;
      });
    }else{
      setState(() {
        _depoMiktarGridSource = DepoMiktarGridSource(dataGridController);
        depoMiktarlariGridList.clear();
        loading = true;
      });
    }
  }
}



class DepoMiktarGridSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRows() {
    dataGridRows = depoMiktarlariGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
         // DataGridCell<String>(columnName: 'SubeKodu',value: e.subeKodu),
          DataGridCell<String>(columnName: 'SubeAdi',value: e.subeAdi),
          DataGridCell<String>(columnName: 'DepoAdi',value: e.depoAdi),
        //  DataGridCell<String>(columnName: 'DepoKodu',value: e.depoKodu),
        //  DataGridCell<String>(columnName: 'StokKodu',value: e.stokKodu),
        //  DataGridCell<String>(columnName: 'StokAdi',value: e.stokAdi),
          DataGridCell<double>(columnName: 'StokMiktari',value: e.stokMiktar),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  DepoMiktarGridSource(this.dataGridController) {
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
           // child: Text(e.value?.toString() ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: getSelectionStyle()),
          );
        }).toList()
    );
  }

  void updateDataGridSource() {
    notifyListeners();
  }
}

