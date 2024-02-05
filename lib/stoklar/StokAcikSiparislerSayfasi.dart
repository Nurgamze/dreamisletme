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

class StokAcikSiparislerSayfasi extends StatefulWidget {

  final bool merkezMi;
  final StoklarGridModel data;

  StokAcikSiparislerSayfasi(this.merkezMi,{required this.data});
  @override
  _StokAcikSiparislerSayfasiState createState() => _StokAcikSiparislerSayfasiState();
}

class _StokAcikSiparislerSayfasiState extends State<StokAcikSiparislerSayfasi> {

  TextEditingController _aramaController = new TextEditingController();

  DataGridController dataGridController = DataGridController();
  late StokAcikSiparislerGridSource _stokAcikSiparislerGridSource;

  bool loading = false;
  List<AcikSiparislerGridModel> aramaList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stokAcikSiparislerGridSource = StokAcikSiparislerGridSource(dataGridController);
    _acikSiparisleriGetir();
    AutoOrientation.fullAutoMode();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    acikSiparisGridList.clear();
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
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(widget.merkezMi ? "SDS MERKEZ AÇIK SİPARİŞLER" : "AÇIK SİPARİŞLER",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,),
                        Text(widget.data.stokKodu,style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 11,color: Colors.white,fontWeight: FontWeight.bold)),textAlign: TextAlign.center,maxLines: 1,),
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
        source: _stokAcikSiparislerGridSource,
        columns: <GridColumn> [
          dreamColumn(columnName: 'musteriIsim', label: 'CARİ ADI',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'musteriKod', label: 'CARİ KODU',alignment: Alignment.centerLeft),
          dreamColumn(columnName: 'sipEvrakSeri',label : "EVRAK NO", ),
          dreamColumn(columnName: 'kalan', label: 'KALAN',),
          dreamColumn(columnName: 'sipMiktar', label: 'SİPARİŞ MİKTARI',minWidth: 140),
          dreamColumn(columnName: 'sipTeslimMiktar', label: 'TESLİM MİKTARI',),
          dreamColumn(columnName: 'birim', label : 'BİRİM',),
          dreamColumn(columnName: 'birimFiyat', label : 'BİRİM FİYAT',),
          dreamColumn(columnName: 'dovizCinsi', label : 'DÖVİZ CİNSİ',),
          dreamColumn(columnName: 'tutar', label : 'TUTAR',),
          dreamColumn(columnName: 'sip_tarih', label : 'SİPARİŞ TARİHİ',),
          dreamColumn(columnName: 'sip_teslim_tarih', label : 'SİPARİŞ TESLİM TARİHİ',),
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
    List<AcikSiparislerGridModel> arananlarList = [];
    for(var siparis in aramaList){
      if(siparis.musteriIsim.toLowerCase().contains(_aramaController.text) || siparis.musteriKod.toLowerCase().contains(_aramaController.text)){
        arananlarList.add(siparis);
      }
    }
    setState(() {
      acikSiparisGridList = arananlarList;
      _stokAcikSiparislerGridSource = StokAcikSiparislerGridSource(dataGridController);
    });
  }

  _acikSiparisleriGetir() async {
    String? gidecekVt = widget.merkezMi ? "MikroDB_V16_01" : UserInfo.activeDB;
    var response = await http.get(Uri.parse("${Sabitler.url}/api/AcikSiparisler?vtIsim=$gidecekVt&cariKod=&stokKod=${widget.data.stokKodu}&caridenMi=false&DevInfo=${TelefonBilgiler.userDeviceInfo}&AppVer=${TelefonBilgiler.userAppVersion}&UserId=${UserInfo.activeUserId}"),
        headers: {"apiKey" : Sabitler.apiKey});
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      var siparislerJson = jsonDecode(response.body);
      for(var siparisler in siparislerJson) {
        AcikSiparislerGridModel bbbb = AcikSiparislerGridModel(
          siparisler['sip_cins'],
          siparisler['sip_tip'],
          siparisler['sip_evrakno_seri'],
          siparisler['sip_evrakno_sira'],
          siparisler['sip_stok_kod'],
          siparisler['sto_isim'],
          siparisler['cari_unvan'] ?? " ",
          siparisler['sip_musteri_kod'],
          siparisler['sip_miktar'],
          siparisler['sip_teslim_miktar'],
          siparisler['kalan'],
          siparisler['tutar'],
          siparisler['birim'],
          siparisler['birimFiyat'],
          siparisler['dovizCinsi'],
          DateTime.parse(siparisler['sip_tarih'].toString()),
          DateTime.parse(siparisler['sip_teslim_tarih'].toString())
        );
        acikSiparisGridList.add(bbbb);
      }
      // if(acikSiparisGridList.length == 1)
      //   acikSiparisGridList.clear();
      //
      // if(acikSiparisGridList.length == 2){
      //   late AcikSiparislerGridModel first;
      //   late AcikSiparislerGridModel last;
      //   for(var data in acikSiparisGridList)
      //   {
      //     print("bakkk ${data.musteriIsim}");
      //       if(data.musteriIsim == "TOPLAM")
      //         last = data;
      //       else first = data;
      //   }
      //   List<AcikSiparislerGridModel> newList = [first,last];
      //   acikSiparisGridList = newList;
      //
      // }
      setState(() {
        _stokAcikSiparislerGridSource = StokAcikSiparislerGridSource(dataGridController);
        loading = true;
        aramaList = acikSiparisGridList;
      });
    }else{
      setState(() {
        _stokAcikSiparislerGridSource = StokAcikSiparislerGridSource(dataGridController);
        acikSiparisGridList.clear();
        loading = true;
      });
    }
  }
}



class StokAcikSiparislerGridSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRows() {
    dataGridRows = acikSiparisGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'musteriIsim',value: e.musteriIsim),
          DataGridCell<String>(columnName: 'musteriKod',value: e.musteriKod),
          DataGridCell<String>(columnName: 'sipEvrakSeri',value: "${e.sipEvrakSeri}${e.sipEvrakSira}"),
          DataGridCell<double>(columnName: 'kalan',value: e.kalan),
          DataGridCell<double>(columnName: 'sipMiktar',value: e.sipMiktar),
          DataGridCell<double>(columnName: 'sipTeslimMiktar',value: e.sipTeslimMiktar),
          DataGridCell<String>(columnName: 'birim',value: e.birim),
          DataGridCell<double>(columnName: 'birimFiyat',value: e.birimFiyat),
          DataGridCell<String>(columnName: 'dovizCinsi',value: e.dovizCinsi),
          DataGridCell<double>(columnName: 'tutar',value: e.tutar),
          DataGridCell<DateTime>(columnName:'sip_tarih',value: e.sip_tarih),
          DataGridCell<DateTime>(columnName:'sip_teslim_tarih',value: e.sip_teslim_tarih),
        ]
    )).toList();
    print("ddataGridRows ${dataGridRows}");
  }

  final DataGridController dataGridController;
  StokAcikSiparislerGridSource(this.dataGridController) {
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

