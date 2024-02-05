import 'package:flutter/foundation.dart';

class StateHelper with ChangeNotifier, DiagnosticableTreeMixin {

  String _depoSecinizTitle = "Depo Seçiniz";
  String get depoSecinizTitle => _depoSecinizTitle;

  int _depoNo = 1;
  int get depoNo => _depoNo;

  String _plansizCikis = "Depo Seçiniz";
  String get plansizCikis => _plansizCikis;

  String _plansizGiris = "Depo Seçiniz";
  String get plansizGiris => _plansizGiris;

  bool _kalemPopUpLoading = true;
  bool get kalemPopUpLoading => _kalemPopUpLoading;




  void setDepoName(String value) {
    _depoSecinizTitle = value;
    notifyListeners();

  }  void setDepoNo(int value) {
    _depoNo = value;
    notifyListeners();
  }

  void setPlansizCikis(String value) {
    _plansizCikis = value;
    notifyListeners();
  }

  void setPlansizGiris(String value) {
    _plansizGiris = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _kalemPopUpLoading = value;
    notifyListeners();
  }







  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('depoSecinizTitle', depoSecinizTitle));
    properties.add(IntProperty('1', depoNo));
    properties.add(StringProperty('plansizCikis', plansizCikis));
    properties.add(StringProperty('plansizGiris', plansizGiris));
    properties.add(EnumProperty('kalemPopUpLoading', kalemPopUpLoading));
  }
}

//benim sonradan eklediklerimmm

class AktifSubeModel extends ChangeNotifier {
  String _aktifSubeNo = "";

  String get aktifSubeNo => _aktifSubeNo;

  setAktifSubeNo(String subeNo) {
    _aktifSubeNo = subeNo;
    notifyListeners();
  }
}





