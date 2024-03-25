import 'dart:convert';import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import '../lojistik/widgets/select/src/model/choice_item.dart';
import '../lojistik/widgets/select/src/model/modal_config.dart';
import '../lojistik/widgets/select/src/model/modal_theme.dart';
import '../lojistik/widgets/select/src/widget.dart';

class TumAcikSiparis extends StatefulWidget {

  const TumAcikSiparis({Key? key}) : super(key: key);
  @override
  _TumAcikSiparisState createState() => _TumAcikSiparisState();
}

class _TumAcikSiparisState extends State<TumAcikSiparis> {

  TextEditingController _aramaController = new TextEditingController();
  DataGridController dataGridController = DataGridController();
  late TumAcikSiparislerGridSource _tumAcikSiparisDataSource;
  bool loading = false;
  List<TumAcikSiparislerGridModel> aramaList = [];

  final List<Map<String,dynamic>> cariKodFiltreList = [];
  List<String?> cariKodFiltreler = [];

  final List<Map<String,dynamic>> temsilciFiltreList = [];
  List<String?> temsilciFiltreler = [];

  bool cariKodFiltreMi = false;
  bool temsilciFiltreMi = false;


  @override
  void initState() {
    super.initState();
    _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(dataGridController);
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
              actions: [
                cariKodFiltreMi || temsilciFiltreMi ? Stack(
                  alignment: Alignment(0,5),
                  children: [
                    Container(
                      color: Colors.red,
                    ), Text("${cariKodFiltreler.length + temsilciFiltreler.length }",style: TextStyle(color: Colors.white)),
                    IconButton(icon: const FaIcon(FontAwesomeIcons.filter), onPressed: ()async {
                      showDialog(context: context,builder: (context) => _filtreDialog());
                    }),
                  ],
                )
                    : IconButton(icon: const FaIcon(FontAwesomeIcons.filter), onPressed: () async {
                  showDialog(context: context,builder: (context) => _filtreDialog());
                }
                ),
              ],
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
                              hintText: "Stok adı veya Cari adı arayınız",
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
                          Text("TÜM AÇIK SİPARİŞLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
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
        source: _tumAcikSiparisDataSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'Sipariş No',label: 'SİPARİŞ NO'),
          dreamColumn(columnName: 'Sipariş Tarihi',label: 'SİPARİŞ TARİHİ'),
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
        onCellTap: (value) async {
          Future.delayed(Duration(milliseconds: 10), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }

  _satisAra() async {
    List<TumAcikSiparislerGridModel> arananlarList = [];
    for(var acikSip in aramaList){
      if(acikSip.sipStokIsim!.toLowerCase().contains(_aramaController.text) || acikSip.musteriIsim!.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(acikSip);
      }
    }
    setState(() {
      tumAcikSiparisGridList = arananlarList;
      _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(dataGridController);
    });
  }

  _siparisleriGetir() async {
    var response = await http.get(Uri.parse("http://api.sds.com.tr/api/TumAcikSiparisler?vtName=${UserInfo.activeDB}&Mobile=true&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey" : Sabitler.apiKey});
    if(response.statusCode==200){
      var acikSiparislerJson = jsonDecode(response.body);
      cariKodFiltreList.clear();
      temsilciFiltreList.clear();
      tumAcikSiparisGridList.clear();
      for(var acikSiparisler in acikSiparislerJson){
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

        bool addC = true;
        bool addT = true;

        for (var map in cariKodFiltreList) {
          if(map["value"] == "${acikSiparisler["Müşteri Kodu"]} - ${acikSiparisler["Müşteri"]}") addC = false;
        }
        for (var map in temsilciFiltreList) {
          if(map["value"] == acikSiparisler["TEMSILCI"]) addT = false;
        }

        if(addC) cariKodFiltreList.add({"grup" : "Müşteri Kodu","value": "${acikSiparisler["Müşteri Kodu"]} - ${acikSiparisler["Müşteri"]}"});
        if(addT) temsilciFiltreList.add({"grup" : "TEMSILCI","value": acikSiparisler["TEMSILCI"]});

        print("cariKodFiltreList ${cariKodFiltreList}");
        print("temsilciFiltreList ${temsilciFiltreList}");
      }
      aramaList = tumAcikSiparisGridList;
      cariKodFiltreler.clear();
      temsilciFiltreler.clear();
      // cariKodFiltreList.clear();
      // temsilciFiltreList.clear();
      cariKodFiltreMi = false;
      temsilciFiltreMi = false;

      print("cariKodFiltreListlengt ${tumAcikSiparisGridList.length}");

      setState(() {
        loading = true;
      });
    }else{
      setState(() {
        tumAcikSiparisGridList.clear();
        loading = true;
      });
    } _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(dataGridController);
    Future.delayed(const Duration(milliseconds: 50), () async{
      FocusScope.of(context).unfocus();
    });
  }

  Widget _filtreDialog(){
    print("filtredialog içindeyim");
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),


        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child:   SmartSelect<String?>.multiple(
                      modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Cari Filtre',
                      placeholder: 'Cariler Filtrele',
                      selectedValue: cariKodFiltreler,
                      onChange: (state) => setState(() => cariKodFiltreler = state.value),
                      choiceItems: S2Choice.listFrom<String, Map>(
                        source: cariKodFiltreList,
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
                                    msg: "Filtreler temizlendi",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 16.0
                                );
                                setState(() {
                                  _gridAra([],temsilciFiltreler);
                                  cariKodFiltreMi = false;
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
                                if(cariKodFiltreler.isNotEmpty){
                                  setState(() {
                                    print("debug1");
                                    cariKodFiltreMi = true;
                                  });
                                }else{
                                  print("debug2");
                                  cariKodFiltreMi = false;
                                }
                                v.closeModal();
                                print("debug1 cari kod filtreler ${cariKodFiltreler}");
                                _gridAra(cariKodFiltreler,temsilciFiltreler);
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
                      choiceEmptyBuilder: (context,s){
                        return Container(
                          child: Center(
                            child: Text("FİLTRE BULUNAMADI"),
                          ),
                        );
                      },
                      tileBuilder: (context, state) {
                        if(cariKodFiltreMi){
                          return Stack(
                            alignment: Alignment(0,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),
                              Text("${cariKodFiltreler.length}",style: TextStyle(color: Colors.white),),
                              InkWell(
                                  child: Container(child: Center(child: Text("Cari",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () {
                                    state.showModal();
                                  }
                              ),
                            ],
                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Cari",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                              onTap: () {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: SmartSelect<String?>.multiple(
                      modalHeaderStyle: S2ModalHeaderStyle(backgroundColor: Colors.blue.shade900),
                      title: 'Temsilci',
                      placeholder: 'Temsilci Filtrele',
                      selectedValue: temsilciFiltreler,
                      onChange: (state) => setState(() => temsilciFiltreler = state.value),
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
                                child: const Center(child: Text("Temizle",style: TextStyle(color: Colors.white)),),
                              ),
                              onTap: () async {
                                v.selection!.clear();
                                setState(() {
                                  temsilciFiltreMi = false;
                                  _gridAra(cariKodFiltreler,[]);
                                });
                                Fluttertoast.showToast(
                                    msg: "Filtreler temizlendi",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    fontSize: 16.0
                                );
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
                                        offset: const Offset(2, 5),
                                      ),
                                    ],
                                    color: Colors.grey.shade500
                                ),
                                child: const Center(child: Text("Filtreyle Arama Yap",style: TextStyle(color: Colors.white),),),
                              ),
                              onTap: () async {
                                v.onChange();
                                setState(() {
                                  if(temsilciFiltreler.isNotEmpty){
                                    print("debug3");
                                    temsilciFiltreMi = true;

                                  }else{
                                    print("debug4");
                                    temsilciFiltreMi = false;
                                  }
                                });
                                v.closeModal();
                                print("debug3 temsilciFiltreler ${temsilciFiltreler}");
                                _gridAra(cariKodFiltreler,temsilciFiltreler);
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
                      choiceEmptyBuilder: (context,s){
                        return const Center(
                          child: Text("FİLTRE BULUNAMADI"),
                        );
                      },
                      tileBuilder: (context, state) {
                        if(temsilciFiltreMi){
                          return Stack(
                            alignment: Alignment(0,20),
                            children: [
                              Container(
                                color: Colors.red,
                              ),Text("${temsilciFiltreler.length}",style: TextStyle(color: Colors.white),),
                              InkWell(
                                  child: Container(child: Center(child: Text("Temsilci",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                                  onTap: () async {
                                    state.showModal();
                                  }
                              ),
                            ],

                          );
                        }else{
                          return InkWell(
                              child: Container(child: Center(child: Text("Temsilci",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.w700,fontSize: 18),),),padding: EdgeInsets.only(bottom: 0),),
                              onTap: () async {
                                state.showModal();
                              }
                          );
                        }
                      }
                  ),
                ),
              ),
              Container(height: 1,color: Colors.grey.shade300,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        cariKodFiltreler = [];
                        temsilciFiltreler = [];
                         temsilciFiltreMi = false;
                         cariKodFiltreMi = false;
                         print("debug5");
                        _gridAra([],[]);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Temizle",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontSize: 18),),
                  ),
                  Container(
                    height: 46,width: 1,
                    color: Colors.grey.shade300,
                  ),
                  TextButton(
                      onPressed: () {
                        print("debug6");
                        print("cariKodFiltreler, ${cariKodFiltreler}");
                        print("temsilciFiltreler, ${temsilciFiltreler}");
                       setState(() {
                         _gridAra(cariKodFiltreler,temsilciFiltreler);
                       });
                        Navigator.pop(context);
                      },
                      child: Text("Tamam",style: TextStyle(color: Colors.green.shade800,fontWeight: FontWeight.w700,fontSize: 18),)
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _gridAra(List<String?> a,List<String?> b) {
    List<TumAcikSiparislerGridModel> arananlarList = [];

    for(var value in aramaList){
      if((a.contains("${value.musteriKod} - ${value.musteriIsim}") || a.isEmpty ) && (b.contains(value.temsilci) || b.isEmpty))
      {
        arananlarList.add(value);
      }
    }
    setState(() {
      tumAcikSiparisGridList = arananlarList;
      _tumAcikSiparisDataSource = TumAcikSiparislerGridSource(dataGridController);
    });
  }
}



class TumAcikSiparislerGridSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRows() {
    dataGridRows = tumAcikSiparisGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'Sipariş No',value: e.sip_no),
          DataGridCell<DateTime>(columnName: 'Sipariş Tarihi',value: e.sip_tarih),
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
  }

  final DataGridController dataGridController;
  TumAcikSiparislerGridSource(this.dataGridController) {
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

