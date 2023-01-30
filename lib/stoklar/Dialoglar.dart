import 'package:flutter/material.dart';


class BilgilendirmeDialog extends StatelessWidget {
  String bilgiMesaji;
  BilgilendirmeDialog(this.bilgiMesaji);
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    child: Text(bilgiMesaji,style: TextStyle(color: Colors.black,fontSize: 17),maxLines: 4,textAlign: TextAlign.center,),
                    margin: EdgeInsets.only(top: 10,bottom: 10),
                    padding: EdgeInsets.only(left: 5,top: 10,bottom: 0,right: 5)
                ),
                Divider(color: Colors.grey,thickness: 1,),
                TextButton(
                    onPressed: () => Navigator.of(context).pop("ok"),
                    child: Container(
                      child: Text("TAMAM",style: TextStyle(color: Colors.blue,),textAlign: TextAlign.center,),
                      width: double.infinity,
                    )
                )
              ],
            ),
          ),
        ));
  }
}

class DetayDialog extends StatelessWidget {
  final String detay;
  final String baslik;
  const DetayDialog({Key? key, required this.detay, required this.baslik}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/11),
          child: Container(
            height: MediaQuery.of(context).size.height*5/8,
            child: Column(
              children: [
                Container(
                  height: 30,
                  child: Center(child: Text(baslik,style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w700)),),
                  margin: EdgeInsets.only(top: 5),
                ),
                Divider(),
                Container(
                    height: MediaQuery.of(context).size.height*5
                        /8-104,
                    child: ListView(
                      children: [
                        Text(detay,style: TextStyle(color: Colors.black,fontSize: 17)),
                      ],
                    ),
                    margin: EdgeInsets.only(bottom: 2),
                    padding: EdgeInsets.only(left: 5,right: 5)
                ),
                Container(height: 1,color: Colors.grey,),
                InkWell(
                  child: Container(
                    height: 50,
                    child: Center(child: Text("TAMAM",style: TextStyle(color: Colors.blue,),textAlign: TextAlign.center,),),
                    width: double.infinity,
                  ),
                  onTap: () => Navigator.of(context).pop("ok"),
                )

              ],
            ),
          ),
        ));
  }
}



