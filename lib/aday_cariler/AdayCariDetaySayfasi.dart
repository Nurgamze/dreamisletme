import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sdsdream_flutter/modeller/GridModeller.dart';
import 'package:sdsdream_flutter/modeller/Modeller.dart';
import 'package:sdsdream_flutter/widgets/const_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ZiyaretlerSayfasi.dart';

class AdayCariDetaySayfasi extends StatefulWidget {
  final AdayCarilerGridModel data;

  AdayCariDetaySayfasi({required this.data});

  @override
  _AdayCariDetaySayfasiState createState() => _AdayCariDetaySayfasiState();
}

class _AdayCariDetaySayfasiState extends State<AdayCariDetaySayfasi> {
  late String telBolge;
  late String telefon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    telBolge = widget.data.TelBolge != null ? widget.data.TelBolge! : "";
    telefon = widget.data.Telefon != null ? widget.data.Telefon! : "";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AutoOrientation.fullAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    return ConstScreen(
        child: Scaffold(
      appBar: AppBar(
        title: Container(
            child: Image(
          image: AssetImage("assets/images/b2b_isletme_v3.png"),
          width: 150,
        )),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 30,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.5, 0.9],
                    colors: [Colors.blue.shade900, Colors.blue.shade700])),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Text(
                      "${widget.data.Kod}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Text(
                      "${widget.data.unvan}",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: ListTile(
              title: Text(
                "Yetkili",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12.0),
              ),
              subtitle: Text(
                widget.data.Yetkili != null ? widget.data.Yetkili! : "",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            height: 60,
          ),
          Divider(),
          Container(
            child: ListTile(
              title: Text(
                "Yetkili E-Posta",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12.0),
              ),
              subtitle: Text(
                widget.data.YetkiliEposta != null
                    ? widget.data.YetkiliEposta!
                    : "",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            height: 60,
          ),
          const Divider(),
          SizedBox(
            child: ListTile(
              onTap: () {
                String aranacakNo = widget.data.YetkiliCep != null
                    ? widget.data.YetkiliCep!
                    : "";
                if (aranacakNo.isEmpty) return;
                if (!aranacakNo.startsWith('0')) {
                  aranacakNo = "0" + aranacakNo;
                }
                launch('tel:$aranacakNo');
              },
              title: Text(
                "Yetkili Cep No",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12.0),
              ),
              subtitle: Text(
                widget.data.YetkiliCep != null ? widget.data.YetkiliCep! : "",
                style: const TextStyle(fontSize: 18.0, color: Colors.blue),
              ),
              trailing: IconButton(
                onPressed: () {
                  String aranacakNo = widget.data.YetkiliCep != null
                      ? widget.data.YetkiliCep!
                      : "";
                  if (aranacakNo.isEmpty) return;
                  if (!aranacakNo.startsWith('0')) {
                    aranacakNo = "0" + aranacakNo;
                  }
                  Clipboard.setData((ClipboardData(text: aranacakNo)));
                  Fluttertoast.showToast(
                      msg: "Telefon numarası kopyalandı",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      textColor: Colors.white,
                      backgroundColor: Colors.grey,
                      fontSize: 16.0);
                },
                icon: FaIcon(FontAwesomeIcons.solidClipboard),
              ),
            ),
            height: 60,
          ),
          const Divider(),
          SizedBox(
            child: ListTile(
              title: Text(
                "Telefon",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12.0),
              ),
              subtitle: Text(
                telBolge + " " + telefon,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
            height: 60,
          ),
          const Divider(),
          SizedBox(
            child: ListTile(
              title: Text(
                "Web",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12.0),
              ),
              subtitle: Text(
                widget.data.Web != null ? widget.data.Web! : "",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            height: 60,
          ),
          const Divider(),
          SizedBox(
            child: ListTile(
              title: Text(
                "Vergi Dairesi ve No",
                style: TextStyle(color: Colors.blue.shade900, fontSize: 12.0),
              ),
              subtitle: Text(
                widget.data.VergiDaireNo != null
                    ? widget.data.VergiDaireNo!
                    : "",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            height: 60,
          ),
          const Divider(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[800]),
            child: TextButton(
              child: const Text(
                "ZİYARETLER",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (await Foksiyonlar.internetDurumu(context)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZiyaretlerSayfasi(
                          true,
                          cariData: widget.data,
                        ),
                      ));
                }
              },
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }
}
