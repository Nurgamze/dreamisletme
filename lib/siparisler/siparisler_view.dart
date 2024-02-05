/*
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/core/models/base_data_grid_source.dart';
import 'package:sdsdream_flutter/core/services/api_service.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'models/siparis.dart';






class SiparislerView extends StatefulWidget {
  const SiparislerView({Key? key}) : super(key: key);

  @override
  State<SiparislerView> createState() => _SiparislerViewState();
}

class _SiparislerViewState extends State<SiparislerView> {


  DataGridController _dataGridController = DataGridController();
  late BaseDataGridSource _siparisDataSource;
  List<Siparis> _siparisList = [];
  bool _loading = false;


  @override
  void initState() {
    // TODO: implement initState
    _siparisDataSource = BaseDataGridSource(_dataGridController,Siparis.buildDataGridRows(_siparisList));
    super.initState();
    _siparisleriGetir();
    AutoOrientation.fullAutoMode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _siparisList.clear();
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
          child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ?
          HorizontalPage(_grid()) :
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.blue.shade900,
                centerTitle: true,
                title: Container(
                    child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
                ),
              ),
              body: !_loading ?
              DreamCogs() :
              _buildBody()
          ),
        )
    );
  }


  _siparisleriGetir() async {
    print("sipariş getir fonk içindeyim");

    var queryParameters = {
      "vt" : UserInfo.activeDB,
      "devInfo" : TelefonBilgiler.userDeviceInfo,
      "appVer" : TelefonBilgiler.userAppVersion,
      "userId" : UserInfo.activeUserId,
    };
    print("queryparameters ,$queryParameters");

    var serviceData = await APIService.getDataWithModel<List<Siparis>,Siparis>("Siparisler", queryParameters, Siparis());

    print("serviceData.statusCode ${serviceData?.statusCode}");
    print("serviceData.responseData ${serviceData?.responseData}");
    if(serviceData.statusCode == 200) {
      print("servicedata if içindeyim  , $serviceData " );
      _siparisList = serviceData?.responseData ?? [];

      _loading = !_loading;
      _siparisDataSource = BaseDataGridSource(_dataGridController,Siparis.buildDataGridRows(_siparisList));

      setState(() {});
    }
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
        source: _siparisDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'siparisTarihi',label: 'SİPARİŞ TARİHİ'),
          dreamColumn(columnName: 'evrak',label: 'EVRAK'),
          dreamColumn(columnName: 'tip',label: 'TİP'),
          dreamColumn(columnName: 'cariKodu',label: 'CARİ KODU'),
          dreamColumn(columnName: 'unvani',label: 'ÜNVANI'),
          dreamColumn(columnName: 'miktar',label: 'MİKTAR'),
          dreamColumn(columnName: 'teslimMiktar',label: 'TESLİM MİKTAR'),
          dreamColumn(columnName: 'kalan',label: 'KALAN'),
          dreamColumn(columnName: 'tutar',label: 'TUTAR'),
          dreamColumn(columnName: 'teslimTarihi',label: 'TESLİM TARİHİ'),
          dreamColumn(columnName: 'satirSayisi',label: 'SATIR SAYISI'),
          dreamColumn(columnName: 'durum',label: 'DURUM'),
          dreamColumn(columnName: 'onayDurumu',label: 'ONAY DURUMU'),
        ],
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), (){
            FocusScope.of(context).requestFocus(new FocusNode());
            if(value.rowColumnIndex.rowIndex > 0){
              var row = _dataGridController.selectedRow!.getCells();
              _dataGridController.selectedIndex = -1;
              //Navigator.push(context, PageTransition(type: PageTransitionType.leftToRight,child: FaturaDetaySayfasi(row[7].value,row[6].value,row[11].value)));

            }
          });
        },
      ),
    );
  }

  _buildBody() {
    return _grid();
  }
}

*/