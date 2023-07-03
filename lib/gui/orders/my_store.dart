import 'package:flutter/material.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyStore extends ChangeNotifier{

  var funcs = Funcs();

  late String _cartCount;
  late int sharedCartCount;

  MyStore(){
    _cartCount = '0';
    notifyListeners();
  }

  String get cartCount => _cartCount;

  getCartCount(String memberId, bool isLogin) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedCartCount = prefs.getInt('cartCount')!;
    _cartCount = sharedCartCount.toString();

    notifyListeners();


//    if(int.parse(memberId) > 0){
//      String myUrl = funcs.mainLink+'api/getCartCount/$memberId';
//      http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
//      try{
//        List ordersCount = json.decode(response.body);
//        _cartCount = ordersCount[0]['cnt'].toString();
//
//      }catch(e){
//
//      }
//    }else{
//      _cartCount = '0';
//    }
//
//    notifyListeners();
//    print(_cartCount);
  }

}