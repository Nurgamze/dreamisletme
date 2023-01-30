import 'dart:async';
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../modeller/GridModeller.dart';
import '../modeller/Listeler.dart';
import '../modeller/Modeller.dart';
import '../widgets/Dialoglar.dart';
import '../widgets/DreamCogsGif.dart';
import '../widgets/HorizontalPage.dart';
import '../widgets/select/src/model/choice_item.dart';
import '../widgets/select/src/model/modal_config.dart';
import '../widgets/select/src/model/modal_theme.dart';
import '../widgets/select/src/widget.dart';
class SatisTahsilatOzetSayfasi extends StatefulWidget {
  @override
  _SatisTahsilatOzetSayfasiState createState() => _SatisTahsilatOzetSayfasiState();
}


final List<Map<String,dynamic>> subeFiltreList = [];
List<String?> _sehirFiltreler = [];
class _SatisTahsilatOzetSayfasiState extends State<SatisTahsilatOzetSayfasi> {

  bool loading = true;


  DateTime secilenTarih1 = DateTime.now();
  DateTime secilenTarih2= DateTime.now();
  DateTime now = DateTime.now();


  List<SatisTahsilatOzetGridModel> aramaList = [];

  DataGridController _satisTahsilatOzetController = DataGridController();
  late SatisTahsilatlarOzetDataSource _satisTahsilatlarOzetDataSource;


  bool temsilciFiltreMi = false;
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _satisTahsilatlarOzetDataSource = SatisTahsilatlarOzetDataSource(_satisTahsilatOzetController);
    _satisTahsilatAnaliziGetir();
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
      child: currentOrientation == Orientation.landscape && !TelefonBilgiler.isTablet ?
      HorizontalPage(_grid()) :
      Scaffold(
        appBar: AppBar(
          title: Container(
              child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
          ),
          actions: [
            temsilciFiltreMi ? Badge(
              position: BadgePosition.topEnd(top: 0, end: 5),
              badgeColor: Colors.red,
              badgeContent: Text("${_sehirFiltreler.length}",style: TextStyle(color: Colors.white)),
              child: IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: ()async {
                showDialog(context: context,builder: (context) => _filtreDialog());

              }),
            )
                : IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: () async {
              showDialog(context: context,builder: (context) => _filtreDialog());
            }
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.blue.shade900,
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child:  Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/2.2-25,
                          child: Center(
                            child:Text("${DateFormat('dd-MM-yyyy').format(secilenTarih1)}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                          )
                      ),
                      onTap: () => callDatePicker(1),
                    ),
                    InkWell(
                      child: Container(
                          decoration: Sabitler.dreamBoxDecoration,
                          margin: EdgeInsets.only(right: 1),
                          height: 50,
                          width: MediaQuery.of(context).size.width/2.2-25,
                          child: Center(
                            child:Text("${DateFormat('dd-MM-yyyy').format(secilenTarih2)}",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.blue.shade900,fontWeight: FontWeight.bold))),
                          )
                      ),
                      onTap: () => callDatePicker(2),
                    ),
                    InkWell(
                        child: Container(
                            decoration: Sabitler.dreamBoxDecoration,
                            margin: EdgeInsets.only(right: 1),
                            height: 50,
                            width: 50,
                            child: Center(
                                child: Icon(Icons.search,color: Colors.blue.shade900,)
                            )
                        ),
                        onTap: () => _satisTahsilatAnaliziGetir()
                    ),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                    color: Colors.blue.shade900,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text("SATIŞ TAHSİLAT ÖZET",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
              ),
              !loading ? Container(child: DreamCogs(),margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/4),) :
              Expanded(child: Container(
                  margin: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                  child: _grid()
              ))
            ],
          ),
        ),
      )
    );
  }


  _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.single,
        source: _satisTahsilatlarOzetDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        controller: this._satisTahsilatOzetController,
        columns: <GridColumn> [
          dreamColumn(columnName: 'tarih',label : "TARİH",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'sube',label : "ŞUBE",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'iadeDahilKdvHaricNetSatis',label : "İADE DAHİL KDV HARİÇ NET SATIŞ",),
          dreamColumn(columnName: 'kdvDahilToplamCiro',label : "KDV DAHİL TOPLAM CİRO",),
          dreamColumn(columnName: 'nakit',label : "NAKİT",),
          dreamColumn(columnName: 'cek',label : "ÇEK",),
          dreamColumn(columnName: 'senet',label : "SENET",),
          dreamColumn(columnName: 'toplamTahsilat',label : "TOPLAM TAHSİLAT",),
        ],

        onCellTap: (v) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }
  Future<DateTime?> getDate() {
    return showDatePicker(
      locale: Locale('tr',''),
      helpText: "TARİH SEÇİNİZ",
      confirmText: "TAMAM",
      cancelText: "İPTAL",
      context: context,
      initialDate: now,
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
  void callDatePicker(int secilenTarih) async {
    var order = await getDate();
    if(order != null){
      if(secilenTarih == 1) {
        setState(() {
          secilenTarih1 =order;
          now = order;
        });
      }else{
        setState(() {
          secilenTarih2 = order;
          now = order;
        });
      }
    }
  }
  _satisTahsilatAnaliziGetir() async {
    setState(() {
      loading=false;
    });
    satisTahsilatOzetGridList.clear();
    late http.Response response;
    double idk = 0.0;
    double kdtc = 0.0;
    double nakit = 0.0;
    double senet = 0.0;
    double cek = 0.0;
    double toplamTahsilat = 0.0;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/SatisTahsilatOzet?tarih1=${secilenTarih1.toString().substring(0,10)} 00:00:00&tarih2=${secilenTarih2.toString().substring(0,10)} 23:59:59&"
          "vtName=${UserInfo.activeDB}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&"
          "UserId=${UserInfo.activeUserId}"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 30));
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
      setState(() {
        var analizDetay = jsonDecode(response.body);
        for(var analiz in analizDetay){
          print(analiz);
          SatisTahsilatOzetGridModel satisTahsilatTemsilciModel = new SatisTahsilatOzetGridModel(
              analiz['TARIH'],
              analiz['SubeAdi'],
              analiz['IadeDahilKdvHaricNetSatis'],
              analiz['KdvDahilToplamCiro'],
              analiz['Nakit'],
              analiz['Cek'],
              analiz['Senet'],
              analiz['ToplamTahsilat']);
          idk += double.parse(analiz['IadeDahilKdvHaricNetSatis'].toString());
          kdtc += double.parse(analiz['KdvDahilToplamCiro'].toString());
          nakit += double.parse(analiz['Nakit'].toString());
          senet += double.parse(analiz['Senet'].toString());
          cek += double.parse(analiz['Cek'].toString());
          toplamTahsilat += double.parse(analiz['ToplamTahsilat'].toString());
          bool addT = true;
          for (var map in subeFiltreList) {
            if(map["value"] == analiz["SubeAdi"]) addT = false;
          }
          if(addT) subeFiltreList.add({"grup" : "Şube","value": analiz["SubeAdi"]});
          satisTahsilatOzetGridList.add(satisTahsilatTemsilciModel);
        }
        if(satisTahsilatOzetGridList.isNotEmpty){
          satisTahsilatOzetGridList.add(SatisTahsilatOzetGridModel("TOPLAM", "",idk, kdtc, nakit, cek, senet, toplamTahsilat));
        }
      });
    }
    setState(() {
      aramaList = satisTahsilatOzetGridList;
      _satisTahsilatlarOzetDataSource = SatisTahsilatlarOzetDataSource(_satisTahsilatOzetController);
      loading = true;
    });
    Future.delayed(Duration(milliseconds: 50), () async{
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }



  Widget _filtreDialog(){
    return MediaQuery(
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
                    child: SmartSelect<String?>.multiple(
                        title: 'Şube Filtre',
                        placeholder: 'Şube Filtrele',
                        selectedValue: _sehirFiltreler,
                        onChange: (state) => setState(() => _sehirFiltreler = (state.value)),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: subeFiltreList,
                          value: (index, item) => item['value'],
                          title: (index, item) => item['value'],
                          group: (index, item) => item['grup'],
                        ),
                        modalFooterBuilder: (context,v) {
                          return Row(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.red
                                  ),
                                  child: Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                                ),
                                onTap: () async {
                                  v.selection!.clear();
                                  Fluttertoast.showToast(
                                      msg: "Filtreler temizlendi.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      textColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      fontSize: 16.0
                                  );
                                  setState(() {
                                    _gridAra([]);
                                    temsilciFiltreMi = false;
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width/2,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(2, 5),
                                        ),
                                      ],
                                      color: Colors.grey.shade500
                                  ),
                                  child: Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                                ),
                                onTap: () async {
                                  v.onChange();
                                  if(_sehirFiltreler.length >0){
                                    setState(() {
                                      temsilciFiltreMi = true;
                                    });
                                  }else{
                                    temsilciFiltreMi = false;
                                  }
                                  v.closeModal();
                                  _gridAra(_sehirFiltreler);
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
                        modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                        choiceEmptyBuilder: (context,s){
                          return Container(
                            child: Center(
                              child: Text("FİLTRE BULUNAMADI"),
                            ),
                          );
                        },
                        tileBuilder: (context, state) {
                          if(temsilciFiltreMi){
                            return Badge(
                              position: BadgePosition.topEnd(top: 15, end: 20),
                              badgeColor: Colors.red,
                              badgeContent: Text("${_sehirFiltreler.length}",style: TextStyle(color: Colors.white)),
                              child: InkWell(
                                  child: Container(child: Center(child: Text("Şube",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
                                  onTap: () async {
                                    state.showModal();
                                  }
                              ),
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Şube",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
                                onTap: () async {
                                  state.showModal();
                                }
                            );
                          }
                        }
                    ),
                  ),
                ),),
              Container(height: 1,color: Colors.grey.shade300,),
              Expanded(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: InkWell(
                    child: Container(
                      child: Center(
                        child: Text("Temizle",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontSize: 18),),),
                    ),
                    onTap: (){
                      setState(() {
                        _sehirFiltreler = [];
                        temsilciFiltreMi = false;
                        _gridAra([]);
                      });
                      Navigator.pop(context);
                    },
                  ),),
                  Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(child: InkWell(
                    child: Container(
                      child: Center(
                        child: Text("Tamam",style: TextStyle(color: Colors.green.shade800,fontWeight: FontWeight.w700,fontSize: 18),),),
                    ),
                    onTap: (){
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





  _gridAra(List<String?> a) {
    List<SatisTahsilatOzetGridModel> arananlarList = [];
    if(a.isEmpty) {
      print("dsa");
      print(aramaList);
      setState(() {
        satisTahsilatOzetGridList = aramaList;
        _satisTahsilatlarOzetDataSource = SatisTahsilatlarOzetDataSource(_satisTahsilatOzetController);
      });
      return;
    }
    double idk = 0.0;
    double kdtc = 0.0;
    double nakit = 0.0;
    double senet = 0.0;
    double cek = 0.0;
    double toplamTahsilat = 0.0;
    for(var value in aramaList){
      if(a.contains(value.sube))
      {
        idk +=  value.iadeDahilKdvHaricNetSatis;
        kdtc += value.kdvDahilToplamCiro;
        nakit += value.nakit;
        senet += value.senet;
        cek += value.cek;
        toplamTahsilat += value.toplamTahsilat;
        arananlarList.add(value);
      }
    }
    arananlarList.add(SatisTahsilatOzetGridModel("TOPLAM","----",idk, kdtc, nakit, cek, senet, toplamTahsilat));
    setState(() {
      satisTahsilatOzetGridList = arananlarList;
      _satisTahsilatlarOzetDataSource = SatisTahsilatlarOzetDataSource(_satisTahsilatOzetController);
    });
  }



}





class SatisTahsilatlarOzetDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = satisTahsilatOzetGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'tarih',value: e.tarih),
          DataGridCell<String>(columnName: 'sube',value: e.sube),
          DataGridCell<double>(columnName: 'iadeDahilKdvHaricNetSatis',value: e.iadeDahilKdvHaricNetSatis),
          DataGridCell<double>(columnName: 'kdvDahilToplamCiro',value: e.kdvDahilToplamCiro),
          DataGridCell<double>(columnName: 'nakit',value: e.nakit),
          DataGridCell<double>(columnName: 'cek',value: e.cek),
          DataGridCell<double>(columnName: 'senet',value: e.senet),
          DataGridCell<double>(columnName: 'toplamTahsilat',value: e.toplamTahsilat),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  SatisTahsilatlarOzetDataSource(this.dataGridController) {
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