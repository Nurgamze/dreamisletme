import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/Dialoglar.dart';
import 'package:sdsdream_flutter/widgets/DreamCogsGif.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';



class YagizTabloSayfasi extends StatefulWidget {
  @override
  _YagizTabloSayfasiState createState() => _YagizTabloSayfasiState();
}

final List<HayvanGridModel> hayvanlarGridList = [];
class _YagizTabloSayfasiState extends State<YagizTabloSayfasi> {

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String tarihBasligi = "Tarih Seçiniz";
  List<String> tarihList = [];
  bool loading = false;
  FixedExtentScrollController? scrollController;
  final DataGridController _dataGridController = DataGridController();
  late HayvanlarGridDataSource _hayvanlarGridDataSource = HayvanlarGridDataSource(_dataGridController);



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tarihGetir();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    hayvanlarGridList.clear();
  }
  @override
  Widget build(BuildContext context) {
    return ConstScreen(
      child: Scaffold(
          appBar: AppBar(
            title: Container(
                child: Image(image: AssetImage("assets/images/b2b_isletme_v3.png"),width: 150,)
            ),
            centerTitle: true,
            backgroundColor: Colors.blue.shade900,
          ),
          body: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 10,left: 5,bottom: 5,right: 5),
                  decoration: Sabitler.dreamBoxDecoration,
                  child: Center(
                    child: Text(tarihBasligi,style: GoogleFonts.roboto(fontSize: 20,fontWeight: FontWeight.w800,color: Colors.blue.shade900),),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                ),
                onTap: () {
                  showDialog(context: context,builder: (context) => _tarihlerDialog());
                },
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
                  child: Center(child: Text("HAYVANLAR",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
              ),
              !loading ? Expanded(child: DreamCogs()) :
              Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    child: _grid(),
                  )
              ),
              SizedBox(height: 2,),
              /*Container(
                margin: EdgeInsets.only(left: 5,right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width/2-8,
                        padding: EdgeInsets.only(left: 5,right: 5),
                        decoration: Sabitler.dreamBoxDecoration,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FaIcon(FontAwesomeIcons.paperPlane,color: Colors.blue.shade900),
                            Text("MAİL GÖNDER",style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.w800,color: Colors.blue.shade900),),
                          ],
                        )
                    ),
                    InkWell(
                      child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width/2-8,
                          padding: EdgeInsets.only(left: 5,right: 5),
                          decoration: Sabitler.dreamBoxDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FaIcon(FontAwesomeIcons.fileExcel,color: Colors.blue.shade900),
                              Text("EXCEL OLUŞTUR",style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.w800,color: Colors.blue.shade900),),
                            ],
                          )
                      ),
                      onTap: () {
                        _excelOlustur();
                      },
                    )
                  ],
                ),
              ),*/
              //SizedBox(height: 15,),
            ],
          ),
      )
    );
  }
  _tarihGetir() async {
    var response = await http.get(Uri.parse("${Sabitler.url}/api/TabloBilgi"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 20));
    if(response.statusCode == 200){
      var tarihler = jsonDecode(response.body);
      for(var tarih in tarihler){
        setState(() {
          tarihList.add(tarih["tarih"]);
        });
      }
      setState(() {
        tarihBasligi = tarihList[0];
        _hayvanlariGetir();
      });
    }else if(response.statusCode == 400){
      var message = jsonDecode(response.body);
      showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
    }
  }

  _hayvanlariGetir() async {
    hayvanlarGridList.clear();
    setState(() {
      loading = false;
    });
    String gidecekTarih = tarihBasligi == "MEVCUT DURUM" ? "" : tarihBasligi.substring(3,6)+tarihBasligi.substring(0,3)+tarihBasligi.substring(6,10);
    var response = await http.get(Uri.parse("${Sabitler.url}/api/HayvanGetir?tarih=$gidecekTarih"),headers: {"apiKey" : Sabitler.apiKey}).timeout(Duration(seconds: 20));
    if(response.statusCode == 200){
      var hayvanlar = jsonDecode(response.body);
      for(var hayvan in hayvanlar){
        setState(() {
          hayvanlarGridList.add(HayvanGridModel(
            hayvan["Hayvan ID"],
            hayvan["Küpe NO"],
            hayvan["Kimlik Bilgisi"],
            hayvan["Hayvan Adı"],
            DateTime.parse(hayvan["Doğum Tarihi"].toString()),
            hayvan["İlk Tartım"],
            hayvan["Bir Önceki Tartım"],
            hayvan["Son Tartım KG"],
            hayvan["Son Tartım Fark"],
            hayvan["Son Tartım Tarihi"] == null ? null : DateTime.parse(hayvan["Son Tartım Tarihi"]),
            hayvan["Çiftlik Küpe No"],
            hayvan["Yaşı"],
            hayvan["Grup Adı"],
            hayvan["Son Açıklama"]
          ));
        });
      }
    }else if(response.statusCode == 400){
      var message = jsonDecode(response.body);
      showDialog(context: context,builder: (context) => BilgilendirmeDialog(message["Message"]));
    }
    setState(() {
      loading = true;
    });
  }


  Widget _tarihlerDialog() {
    for(int i=0 ; i<tarihList.length; i++){
      if(tarihList[i] == tarihBasligi) {
        scrollController = FixedExtentScrollController(initialItem: i);
      }
    }
    return MediaQuery(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Container(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                    child: Column(
                      children: [
                        Text("Tarih Seçiniz",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue.shade900)),
                        Divider(thickness: 2,),
                        Container(
                            color: Colors.white10,
                            height: 180,
                            child: Stack(
                              children: [
                                ListWheelScrollView(
                                  controller: scrollController,
                                  physics: const FixedExtentScrollPhysics(),
                                  perspective: 0.01,
                                  itemExtent: 40,
                                  children: List.generate(tarihList.length, (index) {
                                    return Container(
                                      child: Center(
                                        child: Text(tarihList[index],style: TextStyle(color: Colors.blue.shade700,fontWeight: FontWeight.bold,fontSize: 17),),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                    );
                                  }),
                                ),
                                Align(
                                    alignment: Alignment(0,0.2),
                                    child: Container(
                                      child: Divider(
                                        color: Colors.grey,
                                      ),
                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                    )
                                ),
                                Align(
                                    alignment: Alignment(0,-0.2),
                                    child: Container(
                                      child: Divider(
                                        color: Colors.grey,
                                      ),
                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                    )
                                ),
                              ],
                            )
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 10,left: 10),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: TextButton(
                                child: Text("İptal Et",style: TextStyle(color: Colors.grey.shade200),),
                                /*
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.red)),
                            color: Colors.red,*/
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(child: TextButton(
                                child: Text("Detay Getir",style: TextStyle(color: Colors.grey.shade200),),
                                /*
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.green)),
                            color: Colors.green,*/
                                onPressed: () async {
                                  tarihBasligi = tarihList[scrollController!.selectedItem];
                                  _hayvanlariGetir();
                                  Navigator.pop(context);
                                },
                              ))
                            ],
                          ),
                        )
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );

  }
  SfDataGridTheme _grid() {
    return SfDataGridTheme(
      data: myGridTheme,
      child: SfDataGrid(
        selectionMode: SelectionMode.none,
        //allowSorting: true,
        //allowTriStateSorting: true,
        source: _hayvanlarGridDataSource,
        allowSorting: true,
        allowTriStateSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        columnSizer: customColumnSizer,
        gridLinesVisibility: GridLinesVisibility.vertical,
        headerGridLinesVisibility: GridLinesVisibility.vertical,
        headerRowHeight: 35,
        rowHeight: 35,
        columns: <GridColumn> [
          dreamColumn(columnName: 'hayvanId',label : "Hayvan ID",),
          dreamColumn(columnName: 'kupeNo',label : "Küpe No",),
          dreamColumn(columnName: 'ciftlikKupeNo',label : "Çiftlik Küpe No",),
          dreamColumn(columnName: 'dogumTarihi',label : "Doğum Tarihi",),
          dreamColumn(columnName: 'yasi',label : "Yaşı",),
          dreamColumn(columnName: 'grupAdi',label : "Grubu",),
          dreamColumn(columnName: 'ilkTartim',label : "İlk Tartım",),
          dreamColumn(columnName: 'birOncekiTartim',label : "Bir Önceki Tartım",),
          dreamColumn(columnName: 'sonTartim',label : "Son Tartım",),
          dreamColumn(columnName: 'sonTartimFarki',label : "Son Tartım Fark",),
          dreamColumn(columnName: 'sonTartimTarihi',label : "Son Tartım Tarihi",),
        ],
        controller: this._dataGridController,
        onCellTap: (value) {
          Future.delayed(Duration(milliseconds: 50), () async{
            FocusScope.of(context).requestFocus(new FocusNode());
          });
        },
      ),
    );
  }


}

class HayvanGridModel{
  int? hayvanId;
  String? kupeNo;
  String? kimlikBilgisi;
  String? hayvanAdi;
  DateTime? dogumTarihi;
  double? ilkTartim;
  double? birOncekiTartim;
  double? sonTartim;
  double? sonTartimFarki;
  DateTime? sonTartimTarihi;
  String? ciftlikKupeNo;
  double? yasi;
  String? grupAdi;
  String? sonAciklama;
  HayvanGridModel(this.hayvanId,this.kupeNo,this.kimlikBilgisi,this.hayvanAdi,this.dogumTarihi,this.ilkTartim,this.birOncekiTartim
      ,this.sonTartim,this.sonTartimFarki,this.sonTartimTarihi,this.ciftlikKupeNo,this.yasi,this.grupAdi,this.sonAciklama);
}






class HayvanlarGridDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;



  void buildDataGridRows() {
    dataGridRows = hayvanlarGridList.map<DataGridRow>((e) => DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'hayvanId',value: e.hayvanId),
          DataGridCell<String>(columnName: 'kupeNo',value: e.kupeNo),
          DataGridCell<String>(columnName: 'ciftlikKupeNo',value: e.ciftlikKupeNo),
          DataGridCell<DateTime>(columnName: 'dogumTarihi',value: e.dogumTarihi),
          DataGridCell<double>(columnName: 'yasi',value: e.yasi),
          DataGridCell<String>(columnName: 'grupAdi',value: e.grupAdi),
          DataGridCell<double>(columnName: 'ilkTartim',value: e.ilkTartim),
          DataGridCell<double>(columnName: 'birOncekiTartim',value: e.birOncekiTartim),
          DataGridCell<double>(columnName: 'sonTartim',value: e.sonTartim),
          DataGridCell<double>(columnName: 'sonTartimFarki',value: e.sonTartimFarki),
          DataGridCell<DateTime>(columnName: 'sonTartimTarihi',value: e.sonTartimTarihi),
        ]
    )).toList();
  }

  final DataGridController dataGridController;
  HayvanlarGridDataSource(this.dataGridController) {
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