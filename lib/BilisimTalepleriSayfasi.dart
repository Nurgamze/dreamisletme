import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:url_launcher/url_launcher.dart';

import 'modeller/GridModeller.dart';
import 'modeller/Listeler.dart';
import 'modeller/Modeller.dart';
import 'widgets/Dialoglar.dart';
import 'widgets/DreamCogsGif.dart';
import 'widgets/HorizontalPage.dart';
import 'widgets/const_screen.dart';
import 'yeni_formlar/YeniPortalTalep.dart';

class BilisimTalepleriSayfasi extends StatefulWidget {
  @override
  _BilisimTalepleriSayfasiState createState() => _BilisimTalepleriSayfasiState();
}

class _BilisimTalepleriSayfasiState extends State<BilisimTalepleriSayfasi> {
  bool loading = true;


  final DataGridController _dataGridController = DataGridController();
  late PortalTalepleriDataSource _portalTalepleriDataSource = PortalTalepleriDataSource(_dataGridController);


  List<TalepStatus> _talepStatusList = [];
  List<DropdownMenuItem<TalepStatus>>? _dropdownMenuItems;
  TalepStatus? _selectedItem;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AutoOrientation.fullAutoMode();
    _getPortalStatuses();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(!TelefonBilgiler.isTablet) AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid(),) :
      Scaffold(
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue.shade900,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => YeniPortalTalep()));
          },
        ),
        body: Column(
          children: [
            SizedBox(height: 5,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.symmetric(horizontal: 5),
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: DropdownButton<TalepStatus>(
                  value: _selectedItem,
                  isExpanded: true,
                  items: _dropdownMenuItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value;
                      _talepleriGetir(value!.statusId);
                    });
                  }),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey
                  ),
                  borderRadius: BorderRadius.circular(5)
              ),
            ),
            SizedBox(height: 5,),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                  color: Colors.blue.shade900,
                ),
                margin: EdgeInsets.symmetric(horizontal: 1),
                height: 30,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Text("TALEPLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
            ),
            loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) :
            Expanded(flex: 1,child: Container(
              margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
              child: _grid()
            ),)
          ],
        ),
      )
    );

  }

  Widget _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        controller: this._dataGridController,
        selectionMode: SelectionMode.single,
        source: _portalTalepleriDataSource,
        allowSorting: true,
        allowTriStateSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        columns: <GridColumn> [
          GridColumn(columnName: "uuid", label: Container(child: Text( "uuid",style: headerStyle,),padding : EdgeInsets.only(left:10,right: 10),alignment: Alignment.center),visible: false),
          dreamColumn(columnName: 'talepNo',label : "TALEP NO"),
          dreamColumn(columnName: 'atanan',label : "ATANAN",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'durumu',label : "DURUMU",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'olusturmaTarihi',label : "OLUŞTURMA TARİHİ",),
          dreamColumn(columnName: 'yuzde',label : "YÜZDE(%)",),
          dreamColumn(columnName: 'kapanisTarihi',label : "KAPANIŞ TARİHİ",),
          dreamColumn(columnName: 'talepBasligi',label : "TALEP BAŞLIĞI",alignment: Alignment.centerLeft,),
          dreamColumn(columnName: 'aciklama',label : "AÇIKLAMA",alignment: Alignment.centerLeft),
        ],
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex > 0){
              var row = _dataGridController.selectedRow!.getCells();
              _dataGridController.selectedIndex = -1;
              await launch(
                "https://bulut.sds.com.tr/taskdetail/${row[0].value}",
                forceSafariVC: false,
                forceWebView: false,
                headers: <String, String>{'my_header_key': 'my_header_value'},
              );
            }
          });
        },
      ),
    );
  }
  List<DropdownMenuItem<TalepStatus>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<TalepStatus>> items = [];
    for (TalepStatus listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.statusName),
          value: listItem,
        ),
      );
    }
    return items;
  }

  _getPortalStatuses() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/PortalGetStatus?userId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode == 200) {
      var statuses = jsonDecode(response.body);
      for(var status in statuses){
        setState(() {
          _talepStatusList.add(TalepStatus(status["durum_id"], status["durum_ad"]));
        });
      }
      _dropdownMenuItems = buildDropDownMenuItems(_talepStatusList);
      _selectedItem = _dropdownMenuItems![0].value;
      _talepleriGetir(_dropdownMenuItems![0].value!.statusId);
    }else{
    }
  }

  _talepleriGetir(int statusId) async {
    setState(() {
      loading = true;
    });
    portalTalepleriGridList.clear();
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/PortalGetIssuesByUserId?pUserId=${UserInfo.portalUserId}&statusId=$statusId"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 25));
    } on TimeoutException catch (e) {
      showDialog(context: context,
          builder: (BuildContext context ){
            return BilgilendirmeDialog("Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    } on Error catch (e) {
      showDialog(context: context,
          builder: (BuildContext context ){
            return BilgilendirmeDialog("Sunucuya bağlanılamadı internetinizi kontrol ediniz");
          }).then((value) => Navigator.pop(context));
    }
    if(response.statusCode == 200) {
      var issues = jsonDecode(response.body);
      for(var issue in issues){
        setState(() {
          portalTalepleriGridList.add(
              PortalTalepleriGridModel(
                  issue["gorev_uuid"],
                  issue["gorev_no"], 
                  issue["gorev_atanan"],
                  issue["durumu"],
                  DateTime.parse(issue["gorev_baslangic"].toString()),
                  issue["gorev_tamamlanma"], 
                  issue["gorev_bitis"] == null ? issue["gorev_bitis"] : DateTime.parse(issue["gorev_bitis"].toString()),
                  issue["gorev_ad"],
                  removeAllHtmlTags(issue["gorev_aciklama"].toString())));
        });
      }
    }else{
    }
    setState(() {
      loading = false;
      _portalTalepleriDataSource = PortalTalepleriDataSource(_dataGridController);
    });
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }
}

class PortalTalepleriDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = portalTalepleriGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'uuid',value: e.talepUuid),
          DataGridCell<int>(columnName: 'talepNo',value: e.talepNo),
          DataGridCell<String>(columnName: 'atanan',value: e.atanan),
          DataGridCell<String>(columnName: 'durumu',value: e.durumu),
          DataGridCell<DateTime>(columnName: 'olusturmaTarihi',value: e.olusturmaTarihi),
          DataGridCell<int>(columnName: 'yuzde',value: e.yuzde),
          DataGridCell<DateTime>(columnName: 'kapanisTarihi',value: e.kapanisTarihi),
          DataGridCell<String>(columnName: 'talepBasligi',value: e.talepBasligi),
          DataGridCell<String>(columnName: 'aciklama',value: e.aciklama),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  PortalTalepleriDataSource(this.dataGridController) {
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

class TalepStatus {
  int statusId;
  String statusName;
  TalepStatus(this.statusId,this.statusName);
}