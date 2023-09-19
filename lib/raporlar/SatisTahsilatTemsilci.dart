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
import '../stoklar/const_screen.dart';
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
class SatisTahsilatTemsilciSayfasi extends StatefulWidget {
  @override
  _SatisTahsilatTemsilciSayfasiState createState() => _SatisTahsilatTemsilciSayfasiState();
}

final List<Map<String,dynamic>> temsilciFiltreList = [];
List<String?> _temsilciFiltreler = [];


class _SatisTahsilatTemsilciSayfasiState extends State<SatisTahsilatTemsilciSayfasi> {

  bool loading = true;
  bool temsilciFiltreMi = false;


  DateTime secilenTarih1 = DateTime.now();
  DateTime secilenTarih2= DateTime.now();
  DateTime now = DateTime.now();


  List<SatisTahsilatTemsilciModel> aramaList = [];

  DataGridController _satisTahsilatTemsilciController = DataGridController();
  late SatisTahsilatlarAnaliziDataSource _satisTahsilatlarAnaliziDataSource;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(_satisTahsilatTemsilciController);
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
            centerTitle: true,
            actions: [
              temsilciFiltreMi ? Stack(
                alignment: Alignment(0,5),
                children: [
                  Container(
                    color: Colors.red,
                  ),
                  Text("${_temsilciFiltreler.length}",style: TextStyle(color: Colors.white)),
                  IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: ()async {
                    showDialog(context: context,builder: (context) => _filtreDialog());
                  }),
                ],

              )
                  : IconButton(icon: FaIcon(FontAwesomeIcons.filter), onPressed: () async {
                showDialog(context: context,builder: (context) => _filtreDialog());
              }
              ),
            ],
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
                    child: Center(child: Text("TEMSİLCİ BAZLI SATIŞ TAHSİLAT",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
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
        source: _satisTahsilatlarAnaliziDataSource,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        allowSorting: true,
        allowTriStateSorting: true,
        controller: this._satisTahsilatTemsilciController,
        columns: <GridColumn> [
          dreamColumn(columnName: 'tarih',label : "TARİH",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'temsilci',label : "TEMSİLCİ",alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'iadeDahilKdvHaricNetSatis',label : "İADE DAHİL KDV HARİÇ NET SATIŞ",),
          dreamColumn(columnName: 'kdvDahilToplamCiro',label : "KDV DAHİL TOPLAM CİRO",),
          dreamColumn(columnName: 'nakit',label : "NAKİT",),
          dreamColumn(columnName: 'cek',label : "ÇEK",minWidth: 120),
          dreamColumn(columnName: 'senet',label : "SENET",minWidth: 120),
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
    satisTahsilatTemsilciGridList.clear();
    temsilciFiltreList.clear();
    late http.Response response;
    try {
      response  = await http.get(Uri.parse("${Sabitler.url}/api/TemsilciBazliSatisTahsilat?tarih1=${secilenTarih1.toString().substring(0,10)} 00:00:00&tarih2=${secilenTarih2.toString().substring(0,10)} 23:59:59&"
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
      double idk = 0.0;
      double kdtc = 0.0;
      double nakit = 0.0;
      double senet = 0.0;
      double cek = 0.0;
      double toplamTahsilat = 0.0;
      setState(() {
        var analizDetay = jsonDecode(response.body);
        for(var analiz in analizDetay){
          SatisTahsilatTemsilciModel satisTahsilatTemsilciModel = new SatisTahsilatTemsilciModel(
              analiz['TARIH'],analiz['TEMSİLCİ'],analiz['IadeDahilKdvHaricNetSatis'],
              analiz['KdvDahilToplamCiro'],analiz['Nakit'],analiz['Cek'],
              analiz['Senet'],analiz['ToplamTahsilat']);
          satisTahsilatTemsilciGridList.add(satisTahsilatTemsilciModel);
          idk += double.parse(analiz['IadeDahilKdvHaricNetSatis'] == null ? "0" : analiz['IadeDahilKdvHaricNetSatis'].toString());
          kdtc += double.parse(analiz['KdvDahilToplamCiro'] == null ? "0": analiz['KdvDahilToplamCiro'].toString());
          nakit += double.parse(analiz['Nakit'] == null ? "0": analiz['Nakit'].toString());
          senet += double.parse(analiz['Senet'] == null ? "0": analiz['Senet'].toString());
          cek += double.parse(analiz['Cek'] == null ? "0": analiz['Cek'].toString());
          toplamTahsilat += double.parse(analiz['ToplamTahsilat'] == null ? "0" : analiz['ToplamTahsilat'].toString());
          bool addT = true;
          for (var map in temsilciFiltreList) {
            if(map["value"] == analiz["TEMSİLCİ"]) addT = false;
          }
          if(addT) temsilciFiltreList.add({"grup" : "Temsilci","value": analiz["TEMSİLCİ"]});
        }
        if(satisTahsilatTemsilciGridList.isNotEmpty){
          satisTahsilatTemsilciGridList.add(SatisTahsilatTemsilciModel("TOPLAM","----", idk, kdtc, nakit, cek, senet, toplamTahsilat));
        }
      });
    }
    setState(() {
      aramaList = satisTahsilatTemsilciGridList;
      loading = true;
      temsilciFiltreMi = false;
      _temsilciFiltreler.clear();
      _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(_satisTahsilatTemsilciController);
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
                        title: 'Temsilci Filtre',
                        placeholder: 'Temsilci Filtrele',
                        selectedValue: _temsilciFiltreler,
                        onChange: (state) => setState(() => _temsilciFiltreler = state.value),
                        choiceItems: S2Choice.listFrom<String, Map>(
                          source: temsilciFiltreList,
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
                                  if(_temsilciFiltreler.length >0){
                                    setState(() {
                                      temsilciFiltreMi = true;
                                    });
                                  }else{
                                    temsilciFiltreMi = false;
                                  }
                                  v.closeModal();
                                  _gridAra(_temsilciFiltreler);
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
                            return Stack(
                              alignment: Alignment(15,20),
                              children: [
                                Container(
                                  color: Colors.red,
                                ),Text("${_temsilciFiltreler.length}",style: TextStyle(color: Colors.white)),
                                InkWell(
                                    child: Container(child: Center(child: Text("Temsilci",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
                                    onTap: () async {
                                      state.showModal();
                                    }
                                ),
                              ],
                            );
                          }else{
                            return InkWell(
                                child: Container(child: Center(child: Text("Temsilci",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(top: 10),),
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
                        _temsilciFiltreler = [];
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
    List<SatisTahsilatTemsilciModel> arananlarList = [];
    if(a.isEmpty) {
      print("dsa");
      print(aramaList);
      setState(() {
        satisTahsilatTemsilciGridList = aramaList;
        _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(_satisTahsilatTemsilciController);
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
      if(a.contains(value.temsilci))
      {
        idk +=  value.iadeDahilKdvHaricNetSatis == null ? 0 : value.iadeDahilKdvHaricNetSatis!;
        kdtc += value.kdvDahilToplamCiro == null ? 0 : value.kdvDahilToplamCiro!;
        nakit += value.nakit == null ? 0 : value.nakit!;
        senet += value.senet == null ? 0 : value.senet!;
        cek += value.cek == null ? 0 : value.cek!;
        toplamTahsilat += value.toplamTahsilat == null ? 0 : value.toplamTahsilat!;
        arananlarList.add(value);
      }
    }
    arananlarList.add(SatisTahsilatTemsilciModel("TOPLAM","----", idk, kdtc, nakit, cek, senet, toplamTahsilat));
    setState(() {
      satisTahsilatTemsilciGridList = arananlarList;
      _satisTahsilatlarAnaliziDataSource = SatisTahsilatlarAnaliziDataSource(_satisTahsilatTemsilciController);
    });
  }


}






class SatisTahsilatlarAnaliziDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = satisTahsilatTemsilciGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'tarih',value: e.tarih),
          DataGridCell<String>(columnName: 'temsilci',value: e.temsilci),
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
  SatisTahsilatlarAnaliziDataSource(this.dataGridController) {
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