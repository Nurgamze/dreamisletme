import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/HorizontalPage.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:sdsdream_flutter/core/models/base_data_grid_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../core/services/api_service.dart';
import 'models/cari.dart';
import 'models/cari_risk_foyu.dart';

class CariRiskFoyuView extends StatefulWidget {
  final DreamCari data;
  const CariRiskFoyuView({Key? key,required this.data}) : super(key: key);

  @override
  State<CariRiskFoyuView> createState() => _CariRiskFoyuViewState();
}

class _CariRiskFoyuViewState extends State<CariRiskFoyuView> {


  var riskFoyuJson;
  bool loading = false;
  double xKrediLimitToplami = 0;
  double xBakiye = 0;
  double xRiskKendisi = 0;
  double xRiskMusterisi = 0;
  double xFaturalanmamis = 0;


  late BaseDataGridSource _riskFoyuDataSource;
  DataGridController _dataGridController = new DataGridController();

  List<CariRiskFoyu> _cariRiskFoyuList = [];


  @override
  void initState() {
    // TODO: implement initState
    _riskFoyuGetir();
    _riskFoyuDataSource = BaseDataGridSource(_dataGridController,CariRiskFoyu.buildDataGridRows(_cariRiskFoyuList));
    super.initState();
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
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    return ConstScreen(
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ? HorizontalPage(_grid(),) : Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/dreambg.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Container(
                child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
          ),
          body: !loading ? DreamCogs() :
          Column(
            children: <Widget>[
              SizedBox(height: 5,),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height:(MediaQuery.of(context).size.height*0.08*2.7/7),
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text("Kredi Limiti",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height:(MediaQuery.of(context).size.height*0.08*3.7/7),
                      child: Center(child: Text(Foksiyonlar.formatMoney(xKrediLimitToplami),style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                          border: Border.all(color: Colors.blue.shade900,width: 2)
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: (MediaQuery.of(context).size.height*0.24),
                    width: MediaQuery.of(context).size.width/2,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*2.7/7),
                                child: Center(child: Text("Faturalanmamış(Sip/İrs)",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*3.7/7),
                                child: Center(child: Text(Foksiyonlar.formatMoney(xFaturalanmamis),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.blue.shade900,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*2.7/7),
                                child: Center(child: Text("Risk (Kendi Evrağı)",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*3.7/7),
                                child: Center(child: Text(Foksiyonlar.formatMoney(xRiskKendisi),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.blue.shade900,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height:(MediaQuery.of(context).size.height*0.08*2.7/7),
                                child: Center(child: Text("Toplam Risk",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.red,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*3.7/7),
                                child: Center(child: Text(Foksiyonlar.formatMoney(xFaturalanmamis+xRiskKendisi+xRiskMusterisi),style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.red,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height*0.24),
                    width: 2,
                    child: Container(color: Colors.white,),
                  ),
                  Container(
                    height: (MediaQuery.of(context).size.height*0.24),
                    width: MediaQuery.of(context).size.width/2.04,
                    color: Colors.white70,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height:(MediaQuery.of(context).size.height*0.08*2.7/7),
                                child: Center(child: Text("Toplam Bakiye",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*3.7/7),
                                child: Center(child: Text(Foksiyonlar.formatMoney(xBakiye),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.blue.shade900,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height:(MediaQuery.of(context).size.height*0.08*2.7/7),
                                child: Center(child: Text("Risk (Müşteri Evrağı)",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*3.7/7),
                                child: Center(child: Text(Foksiyonlar.formatMoney(xRiskMusterisi),style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.blue.shade900,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height:(MediaQuery.of(context).size.height*0.08*2.7/7),
                                child: Center(child: Text("Risk Dahil Bakiye",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold)),),),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                                  color: Colors.red,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                height: (MediaQuery.of(context).size.height*0.08*3.7/7),
                                child: Center(child: Text(Foksiyonlar.formatMoney(xFaturalanmamis+xRiskKendisi+xRiskMusterisi+xBakiye),style: TextStyle(fontSize: 15,color: Colors.black,fontWeight: FontWeight.bold),),),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                                    border: Border.all(color: Colors.red,width: 2)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2,),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.blue.shade900,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text("RİSK FÖYÜ HAREKETLERİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
              ),
              Expanded(child:  Container(
                  margin: EdgeInsets.only(bottom: 2,left: 2,right: 2),
                  child: _grid()
              ),)
            ],
          ),
        ),
      ),
    );

  }


  Widget _grid(){
    return SfDataGridTheme(
      data:myGridTheme,
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
        source: _riskFoyuDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'tipi',label :  "TİPİ",alignment: Alignment.center),
          dreamColumn(columnName: 'sahibi',label :  "SAHİBİ",alignment: Alignment.center),
          dreamColumn(columnName: 'referans',label :  "REFERANS",alignment: Alignment.center),
          dreamColumn(columnName: 'pozisyon',label :  "POZİSYON",alignment: Alignment.center),
          dreamColumn(columnName: 'belgeTarihi',label :  "BELGE TARİHİ",alignment: Alignment.center),
          dreamColumn(columnName: 'vadeTarihi',label :  "VADE TARİHİ",alignment: Alignment.center),
          dreamColumn(columnName: 'tutar',label :  "TUTAR",alignment: Alignment.center),
          dreamColumn(columnName: 'vadeHafta',label :  "VADE HAFTA",alignment: Alignment.center),
          dreamColumn(columnName: 'vadeCeyrek',label :  "VADE ÇEYREK",alignment: Alignment.center),
          dreamColumn(columnName: 'doviz',label :  "DÖVİZ",alignment: Alignment.center),
          dreamColumn(columnName: 'riski',label: 'RİSKİ',alignment: Alignment.center),
          dreamColumn(columnName: 'kullKredi',label: 'KULLANILAN KREDİ',alignment: Alignment.center),

        ],
        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }

  var keys = [
    "Açık tanınan kredi",
    "Banka teminat mektubu",
    "Gayrimenkul ipoteği",
    "Coface",
    "Pazarlama Yöneticisi",
    "Ortak kefalet",
    "Şahsi kefalet",
    "Teminat senetleri",
    "Şube Yöneticisi",
    "Merkez Yöneticisi"
  ];


  _riskFoyuGetir() async {

    var queryParameters = {
      "VtIsim" : UserInfo.activeDB,
      "Customer" : false,
      "cariKod" : widget.data.kod,
      "Mobile" : true,
      "DevInfo" : TelefonBilgiler.userDeviceInfo,
      "AppVer" : TelefonBilgiler.userAppVersion,
      "UserId" : UserInfo.activeUserId,
    };
    var serviceData = await APIService.getDataWithModel<List<CariRiskFoyu>,CariRiskFoyu>("CariRiskFoyu", queryParameters, CariRiskFoyu());
    if(serviceData?.statusCode == 200) {
      _cariRiskFoyuList = serviceData?.responseData ?? [];
      for(var _riskFoyu in _cariRiskFoyuList){
        String tipi = _riskFoyu.tipi.toString();
        if(keys.any((element) => tipi.contains(element))){
          xKrediLimitToplami += _riskFoyu.tutar ?? 0;
        }else if(tipi.contains("çeki") || tipi.contains("senedi")){
          if(_riskFoyu.sahibi.toString().contains("Kendisi")){
            xRiskKendisi += _riskFoyu.riski ?? 0;
          }else{
            xRiskMusterisi += _riskFoyu.riski ?? 0;
          }
        }else if(tipi.contains("Faturalaşmamış") || tipi.contains("Sipariş")){
          xFaturalanmamis += _riskFoyu.riski ?? 0;
        }else if(tipi.contains("Açık Hesap Bakiye")){
          xBakiye += _riskFoyu.tutar ?? 0;
        }
      }
      _riskFoyuDataSource = BaseDataGridSource(_dataGridController,CariRiskFoyu.buildDataGridRows(_cariRiskFoyuList));
      loading = true;
      setState(() {

      });
    }else{
      print(serviceData?.statusCode);
      print(serviceData?.errorMessage);
    }
  }
}

