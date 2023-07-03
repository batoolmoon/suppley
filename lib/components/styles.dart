import 'dart:convert';
//import 'dart:js';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supplyplatform/gui/products/favourite.dart';
import 'package:supplyplatform/gui/products/product_details.dart';
import 'package:supplyplatform/gui/members/login.dart';
import 'package:supplyplatform/gui/members/register.dart';
import 'package:supplyplatform/gui/products/products.dart';
import 'package:supplyplatform/gui/members/forget_password.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart';
import 'package:supplyplatform/gui/notifications.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../gui/store_details.dart';

class Styles{
  TextStyle appBarStyle = const TextStyle(color: Colors.white, fontSize: 15.0,);
  TextStyle lineThroughPrice = const TextStyle(color: Colors.black45, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold, fontSize: 15.0);
  TextStyle discountPrice = const TextStyle(color: Color.fromRGBO(194, 171, 131, 1), fontWeight: FontWeight.bold, fontSize: 17.0);
  TextStyle productPrice = const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16.0);
  TextStyle priceTitle = const TextStyle(color: Colors.black87, fontSize: 13.0);
  TextStyle productNameView =  TextStyle(color: Colors.black, fontSize: 13.0, fontFamily: 'Cairo');
  TextStyle productPriceTitleView = const TextStyle(color: Colors.black87, fontSize: 11.0, fontFamily: 'Cairo');
  TextStyle secondaryHeaderColor = const TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: 'Cairo');
  TextStyle listTileStyle = const TextStyle(color: Colors.white, fontSize: 15.0,);
  TextStyle listTileStyle2 = const TextStyle(color: Color.fromRGBO(0, 0, 51, 1), fontSize: 15.0,);
  TextStyle listTileTitleStyle = const TextStyle(color: Color.fromRGBO(0, 0, 51, 1), fontWeight: FontWeight.bold, fontSize: 16.0,);
  TextStyle dialogData = const TextStyle(color: Colors.black87, fontSize: 16.0, fontFamily: 'Cairo');
  TextStyle couponDiscount = const TextStyle(color: Colors.red, fontWeight:FontWeight.bold, fontSize: 15.0);
  TextStyle couponDate = const TextStyle(color: Colors.black87, fontSize: 13.0);
  TextStyle checkoutPageTitle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,  color: Colors.green);
  TextStyle appBarActionBtn = const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.white);
  TextStyle inputTextStyle = const TextStyle(color: Colors.black87, fontSize: 14.0);
  TextStyle inputTextHintStyle = const TextStyle(color: Colors.grey, fontSize: 18.0,fontWeight:FontWeight.normal);
  TextStyle couponValueYouWinTitle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0);
  TextStyle ordersPrice = const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 17.0);
  TextStyle orderShippingPrice = const TextStyle(color: Colors.black87, fontSize: 15.0);
  TextStyle positionSelectedTitle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,  color: Colors.green);
  Color deleteColor =  const Color.fromRGBO(230, 81, 62, 1);
  Color nextColor =  const Color.fromRGBO(0, 0, 51, 1);
  TextStyle specialOffers = const TextStyle(fontFamily: 'Cairo', fontSize: 11.0, color: Colors.white);
  TextStyle paragraphTitle = const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 20.0); // for titles
  TextStyle paragraphText = const TextStyle(color: Colors.black87, fontFamily: 'Cairo', fontSize: 15.0);
  TextStyle greenTitle = const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 15.0); // for titles
  TextStyle acceptPrivacy = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0);
  TextStyle startBtn = const TextStyle(color:  Colors.black , fontFamily: 'Cairo', fontSize: 15.0);
  TextStyle activeBtn = const TextStyle(color: Colors.white, fontSize: 13.0);
  TextStyle inActiveBtn = const TextStyle(color: Colors.black87, fontSize: 13.0);
  TextStyle closeNow = const TextStyle(color: Colors.red, fontFamily: 'Cairo', fontSize: 13.0);
  TextStyle whiteTabsTitle = const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 15.0);
  TextStyle activeWhiteTabsTitle = const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 15.0);

  bool _isVertical = false;
  IconData? _selectedIcon;


late String price='';
int  minCount=0;
  var funcs = new Funcs();
bool addedToFavourite=false;
int ChangeFavColor=0;

//  addToCart(scaffoldKey, context, bool isLogin, String productId, String priceId, String tagId, int currencyId, int quantity) async{
//
//      onLoading(context);
//
//      String response  = await funcs.addToCart(isLogin, productId, priceId,tagId, quantity, currencyId);
//
//      if(response == '1'){
//        Navigator.of(context, rootNavigator: true).pop();
//        showSnackBar(scaffoldKey, context,Locales.string(context, 'added_to_card'),'success','');
//        SharedPreferences prefs = await SharedPreferences.getInstance();
//        sharedCartCount = prefs.getInt('sharedCartCount')!;
//        await prefs.setInt('sharedCartCount', sharedCartCount + 1);
//      }else if(response == 'already_added'){
//        Navigator.of(context, rootNavigator: true).pop();
//        showSnackBar(scaffoldKey, context,Locales.string(context, 'already_added_to_cart'),'error','');
//      }else if(response == 'quantity_not_avaliable'){
//        Navigator.of(context, rootNavigator: true).pop();
//        showSnackBar(scaffoldKey, context,Locales.string(context, 'quantity_not_available'),'error','');
//      }else if(response == 'not_same_category'){
//        Navigator.of(context, rootNavigator: true).pop();
//        showSnackBar(scaffoldKey, context,Locales.string(context, 'not_same_category'),'error','');
//      }else{
//        Navigator.of(context, rootNavigator: true).pop();
//      }
//  }

  addRemoveFavorite(scaffoldKey, context, bool isLogin, String memberId, String productId) async{
    onLoading(context);
    await http.post(Uri.parse(funcs.mainLink+'api/addRemoveFavourite'), body: {
      "memberId" : memberId,
      "productId": productId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['theResult'] == true){

          addedToFavourite = true;

        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['theResult'] == false){

          addedToFavourite = false;

        Navigator.of(context, rootNavigator: true).pop();
      }else{
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      Navigator.of(context, rootNavigator: true).pop();
    });

  }

  removeItemFromFavourite(scaffoldKey, context, bool isLogin, String memberId, String productId) async{
    if(isLogin == true){
      onLoading(context);
      String response  = await funcs.removeItemFromFavourite(memberId, productId);
      if(response == '1'){
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, anotherAnimation){
            return Favourite();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {

            return FadeTransition(
              opacity:animation,
              child: child,
            );
          },
        ));
      }else{
        Navigator.of(context, rootNavigator: true).pop();
        showSnackBar(scaffoldKey, context,context.localeString('error_occurred').toString(),'error','');
      }
    }else{
      needLoginModalBottomSheet(context);
    }

  }


  getCurrencyExchange() async{
    double currencyExchange;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currencyExchange = prefs.getDouble('currencyExchange')!;
    return currencyExchange;
  }

  getPriceAfterExchange(String price, double currencyExchange/*, String categoryProfit*/){
    double thePrice;
    thePrice = double.parse(price) * currencyExchange;
    return thePrice + funcs.getProfit(price,1/*,categoryProfit*/);
  }

  getOrderItemPrice(String totalPrice, String selectedQuantity, String totalProfit){
    double thePrice;

    thePrice = (double.parse(totalPrice) + double.parse(totalProfit)) / double.parse(selectedQuantity);
    return thePrice.toStringAsFixed(2);
  }

  Widget widgetProducts(scaffoldKey,context, bool isLogin, String memberId, double currencyExchange, dataList, index, String theType, int currencyId){
// price =dataList[index].prId;
// minCount=dataList[index].minCount;
// print(price);
// print(minCount);
    return int.parse(dataList[index].priceId) > 0 ?
    GestureDetector(
      onTap: ()=> Navigator.of(context).push(
          PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation){
          price =dataList[index].thePrice;
          minCount=10;//int.parse(dataList[index].minCount);
          print(price);
          print(minCount);
          return ProductDetails(dataList[index].prId);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          return FadeTransition(
            opacity:animation,
            child: child,
          );
        },
      )),
      child: Container(
   padding: EdgeInsets.all(1),
        margin:EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white70,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(
            offset: Offset(10,10),
            blurRadius: 30,
            color: Colors.black12//TODO transparent,
          )],
        ),
        //color: Colors.brown[50],//TODO transparent,
        //elevation: 0.0,
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
       // shadowColor: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
           Stack(
              children: <Widget>[

                Container(
                  width: 170.0,
                  height: 130.0,
                 // padding: EdgeInsets.all(70),
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),

                      border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1), width: 1.0,),
                      image: dataList[index].thePhoto != null && dataList[index].thePhoto != '' ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(funcs.mainLink+"public/uploads/php/files/products/thumbnail/${dataList[index].thePhoto}"),
                      ):const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('images/default.png',)
                        )
                  ),
                ),
                dataList[index].isOffer == '1' && theType != 'main_page'? Positioned(
                  child: Container(
                    padding: const EdgeInsets.all(5.0),

                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                      color: Colors.red,
                    ),
                    child: Text(Locales.string(context, 'special_offer'),style: specialOffers, textAlign: TextAlign.center,),
                  ),
                  left: 0.0,
                  top: 0.0,
                ):Container(),
                theType == 'favourite' ? Positioned(
                  child: GestureDetector(
                    onTap: (){
                      removeItemFromFavourite(scaffoldKey, context, isLogin, memberId, dataList[index].prId);
                    },
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60.0),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 1.0,
                            ),
                          ]
                      ),
                      child: const Center(
                        child: Icon(color: Colors.red, Icons.cancel),
                      ),
                    ),
                  ),
                  right: 5.0,
                  bottom: 5.0,
                ):Container()
              ],
            ),
            const SizedBox(height: 10.0,),

            int.parse(dataList[index].rateCount) > 0 ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBarIndicator(
                  rating: (double.parse('${dataList[index].theRate}') / double.parse('${dataList[index].rateCount}')).toDouble(),
                  itemBuilder: (context, index) => Icon(
                    _selectedIcon ?? Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: _isVertical ? Axis.vertical : Axis.horizontal,
                ),
                IconButton(
                  onPressed: (){
                    if (isLogin==true){
                      addRemoveFavorite(scaffoldKey, context, isLogin, memberId, dataList[index].prId);
                      ChangeFavColor=int.parse(dataList[index].isFav);
                      if (ChangeFavColor==0){ChangeFavColor=1; dataList[index].isFav="1";}
                      else {ChangeFavColor=0;dataList[index].isFav="0";}
                      print (dataList[index].isFav); }
                    else {needLoginModalBottomSheet(context);}
                  }, icon: dataList[index].isFav=="1" ||ChangeFavColor== 1? const Icon(Icons.favorite, color: Colors.red, size:30.0,): const Icon(Icons.favorite_outline_rounded, color: Colors.grey, size: 30.0,),)
              ],
            ):Row(
              mainAxisAlignment: MainAxisAlignment.center
              ,
              children: [
                RatingBarIndicator(
                  rating: 0.0,
                  itemBuilder: (context, index) => Icon(
                    _selectedIcon ?? Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: _isVertical ? Axis.vertical : Axis.horizontal,
                ),
                IconButton(
                  onPressed: (){
                   if (isLogin==true){
                  addRemoveFavorite(scaffoldKey, context, isLogin, memberId, dataList[index].prId);
                  ChangeFavColor=int.parse(dataList[index].isFav);
                  if (ChangeFavColor==0){ChangeFavColor=1; dataList[index].isFav="1";}
                  else {ChangeFavColor=0;dataList[index].isFav="0";}
                  print (dataList[index].isFav); }
                   else {needLoginModalBottomSheet(context);}
                 }, icon: dataList[index].isFav=="1" ||ChangeFavColor== 1? const Icon(Icons.favorite, color: Colors.red, size: 30.0,): const Icon(Icons.favorite_outline_rounded, color: Colors.grey, size: 30.0,),)
              ],
            ),

            theType == 'favourite' ? Container(// for orders
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].storeName}'),
                    ),
                  ],
                )
            ):Container(),
            theType != 'orders' ? Container(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].theTitle}'),
                    ),
                    dataList[index].theDiscount == '0.00' ? Text(getPriceAfterExchange(dataList[index].thePrice,currencyExchange/*,dataList[index].categoryProfit*/).toStringAsFixed(2) + ' ${dataList[index].symbol}', style: productPrice, textAlign: TextAlign.center):
                    Column(
                      children: <Widget>[
                        Text(funcs.getPriceAfterDiscount(dataList[index].thePrice,dataList[index].theDiscount,1,currencyExchange/*,dataList[index].categoryProfit*/).toStringAsFixed(2)+ ' ${dataList[index].symbol}', style: discountPrice),
                        Text(getPriceAfterExchange('${dataList[index].thePrice}',currencyExchange/*,dataList[index].categoryProfit*/).toStringAsFixed(2) + ' ${dataList[index].symbol}', style: lineThroughPrice),
                      ],
                    ),
                  ],
                )
            ):Container( // for orders
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].theTitle}'),
                    ),
                    Text(getOrderItemPrice('${dataList[index].totalPrice}','${dataList[index].selectedQuantity}', '${dataList[index].totalProfit}') + ' ${dataList[index].symbol}', style: productPrice, textAlign: TextAlign.center)
                  ],
                )
            ),

            theType == 'orders' ? Container(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: productPriceTitleView,
                    text: '${dataList[index].priceSizeTitle}'),
              ),
              width: double.infinity,
            ):Container(),
            theType == 'orders' ? dataList[index].optionTitle != null ? Container(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: productPriceTitleView,
                    text: '${dataList[index].optionTitle}'),
              ),
              width: double.infinity,
            ):Container():Container(),
            theType == 'orders' ? Container(
              child: Text('x '+ dataList[index].selectedQuantity, style: productPrice, textAlign: TextAlign.center),
            ):Container()
            ,

          ],
        ),
      ),
    ):Container();
  }


    Widget widgetProductsForStores(scaffoldKey,context, bool isLogin, String memberId, double currencyExchange, dataList, index, String theType, int currencyId){

    return int.parse(dataList[index].priceId) > 0 ? GestureDetector(
      onTap: ()=> null,
      child: Card(
        color: Colors.transparent,
        elevation: 0.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: 200.0,
                  height: 190.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1), width: 1.0,),
                      image: dataList[index].thePhoto != null && dataList[index].thePhoto != '' ? DecorationImage(
                        fit: BoxFit.contain,
                        image: NetworkImage(funcs.mainLink+"public/uploads/php/files/products/thumbnail/${dataList[index].thePhoto}"),
                      ):const DecorationImage(
                       fit: BoxFit.cover,
                          image: AssetImage('images/default.png',)
                      )
                  ),
                ),
                Positioned(
                  child: Container(
                    padding: const EdgeInsets.all(5.0),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.red,
                    ),
                    child: Text(Locales.string(context, 'special_offer'),style: specialOffers, textAlign: TextAlign.center,),
                  ),
                  left: 0.0,
                  top: 0.0,
                ),
              ],
            ),
            const SizedBox(height: 10.0,),

            int.parse(dataList[index].rateCount) > 0 ? RatingBarIndicator(
              rating: (double.parse('${dataList[index].theRate}') / double.parse('${dataList[index].rateCount}')).toDouble(),
              itemBuilder: (context, index) => Icon(
                _selectedIcon ?? Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20.0,
              direction: _isVertical ? Axis.vertical : Axis.horizontal,
            ):Row(
              children: [
                RatingBarIndicator(
                  rating: 0.0,
                  itemBuilder: (context, index) => Icon(
                    _selectedIcon ?? Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: _isVertical ? Axis.vertical : Axis.horizontal,
                ),
                IconButton(
                  onPressed: (){
                    if (isLogin==true){
                      addRemoveFavorite(scaffoldKey, context, isLogin, memberId, dataList[index].prId);
                      ChangeFavColor=int.parse(dataList[index].isFav);
                      if (ChangeFavColor==0){ChangeFavColor=1; dataList[index].isFav="1";}
                      else {ChangeFavColor=0;dataList[index].isFav="0";}
                      print (dataList[index].isFav); }
                    else {needLoginModalBottomSheet(context);}
                  }, icon: dataList[index].isFav=="1" ||ChangeFavColor== 1? const Icon(Icons.favorite, color: Colors.red, size: 40.0,): const Icon(Icons.favorite_outline_rounded, color: Colors.grey, size: 40.0,),)
              ],
            ),
            theType == 'favourite' ? Container(// for orders
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].storeName}'),
                    ),
                  ],
                )
            ):Container(),
            theType != 'orders' ? Container(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].theTitle}'),
                    ),
                    dataList[index].theDiscount == '0.00' ? Text(getPriceAfterExchange(dataList[index].thePrice,currencyExchange/*,dataList[index].categoryProfit*/).toStringAsFixed(2) + ' ${dataList[index].symbol}', style: productPrice, textAlign: TextAlign.center):
                    Column(
                      children: <Widget>[
                        Text(funcs.getPriceAfterDiscount(dataList[index].thePrice,dataList[index].theDiscount,1,currencyExchange/*,dataList[index].categoryProfit*/).toStringAsFixed(2)+ ' ${dataList[index].symbol}', style: discountPrice),
                        Text(getPriceAfterExchange('${dataList[index].thePrice}',currencyExchange/*,dataList[index].categoryProfit*/).toStringAsFixed(2) + ' ${dataList[index].symbol}', style: lineThroughPrice),
                      ],
                    ),
                  ],
                )
            ):Container( // for orders
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].theTitle}'),
                    ),
                    Text(getOrderItemPrice('${dataList[index].totalPrice}','${dataList[index].selectedQuantity}', '0.0') + ' ${dataList[index].symbol}', style: productPrice, textAlign: TextAlign.center)
                  ],
                )
            ),

            theType == 'orders' ? Container(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: productPriceTitleView,
                    text: '${dataList[index].priceSizeTitle}'),
              ),
              width: double.infinity,
            ):Container(),
            theType == 'orders' ? dataList[index].optionTitle != null ? Container(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                strutStyle: const StrutStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: productPriceTitleView,
                    text: '${dataList[index].optionTitle}'),
              ),
              width: double.infinity,
            ):Container():Container(),
            theType == 'orders' ? Container(
              child: Text('x '+ dataList[index].selectedQuantity, style: productPrice, textAlign: TextAlign.center),
            ):Container(),

          ],
        ),
      ),
    ):Container();
  }

  Widget widgetStores(scaffoldKey,context, dataList, index){

    return GestureDetector(

      onTap: (){
       if(dataList[index].theType=='delivery_company'){
         Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetails(dataList[index].stId)),);
       }
        else if(dataList[index].theType=='factory'){
          print('ddd');
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Products(dataList[index].stId, dataList[index].storeName, 'products','')));
        }
        else{
              showSnackBar(scaffoldKey,context,Locales.string(context, 'store_is_closed'),'error','');
        }
      },

      child: Card(
        color: Colors.transparent,
        elevation: 0.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: 100.0,
                  height: 80.0,

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: const Color.fromRGBO(230, 230, 230, 1), width: 1.0,),
                      image: dataList[index].thePhoto != null && dataList[index].thePhoto != '' ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(funcs.mainLink+"public/uploads/php/files/stores/thumbnail/${dataList[index].thePhoto}")
                      ):const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('images/default.png',)
                      )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0.0,),
            Container(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: <Widget>[
                    //Text(dataList[index].theType),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: productNameView,
                          text: '${dataList[index].storeName}'),
                    ),
                    dataList[index].isClosed == '1' ? RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(fontSize: 15.0),
                      text: TextSpan(
                          style: closeNow,
                          text: Locales.string(context, 'store_is_closed')
                      ),
                    ):Container(),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
  void showSnackBar(scaffoldKey, context, String message, String theType, String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: theType == 'error' ? Colors.red:Colors.green,
      content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
      action: action == 'forget_password' ? SnackBarAction(
          label: Locales.string(context, 'forget_password'),
          textColor: Colors.white,
          onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()),)
      ):null,
    ));
  }

  /*void showSnackBar(scaffoldKey, context, String message, String theType, String action) {
    scaffoldKey.of(context).showSnackBar(SnackBar(
      backgroundColor: theType == 'error' ? Colors.red:Colors.green,
      content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
      action: action == 'forget_password' ? SnackBarAction(
          label: Locales.string(context, 'forget_password'),
          textColor: Colors.white,
          onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()),)
      ):null,
    ));
  }*/

  void onLoading(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // if (ChangeFavColor==0){ChangeFavColor=1;}
          // else{ChangeFavColor=0;}
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                 CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.3,
                ),
              ],
            ),
          );
        }

    );
  }

  void needLoginModalBottomSheet(context){

    String loginTitle;
    String registerTitle;
    String sheetTitle;
    String sheetDesc;

    sheetTitle = Locales.string(context, 'need_login_title');
    sheetDesc = Locales.string(context, 'need_login_text');
    loginTitle = Locales.string(context, 'login_page_title');
    registerTitle = Locales.string(context, 'do_not_have_account');

    showModalBottomSheet(
        context: context,
        isScrollControlled:true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),

        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(sheetTitle, style: TextStyle(color: Color.fromRGBO(0, 0, 50, 1), fontFamily: 'Cairo', fontSize: 22.0,), textAlign: TextAlign.center),
                  subtitle: Text(sheetDesc, style: const TextStyle(color: Colors.black45, fontFamily: 'Cairo', fontSize: 14.0,), textAlign: TextAlign.center),
                ),
                const Divider(),
                ListTile(
                  title: Text(loginTitle, style: const TextStyle(color: Colors.black87, fontFamily: 'Cairo', fontSize: 17.0,), textAlign: TextAlign.center),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),),
                ),
                const Divider(),
                ListTile(
                  title: Text(registerTitle, style: const TextStyle(color: Colors.black87, fontFamily: 'Cairo', fontSize: 17.0,), textAlign: TextAlign.center),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Register()),),
                ),
              ],
            ),
          );
        }
    );
  }

  PreferredSizeWidget theAppBar(context, String theLanguage, bool isLogin, String theTitle, bool backBtn, bool showNotification, notificationsCount){
    return AppBar(
      title:  Text(theTitle, style: appBarStyle,),
      foregroundColor: Colors.white,
      automaticallyImplyLeading: backBtn,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      elevation: 0.5,
      actions: [
        showNotification == true ? IconButton(
          icon: Badge(
            badgeContent: Text(notificationsCount, style: TextStyle(color: Colors.white, fontSize: int.parse(notificationsCount) > 100 ? 11:13),),
            child: const Icon(Icons.notifications, color: Colors.white,size: 25,),
            toAnimate: false,
            showBadge: int.parse(notificationsCount) > 0 ? true:false,
            position: BadgePosition.topEnd(top: -15,end: 12 ),
          ),
          onPressed: () {
            if(isLogin == true){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()),);
            }else{
              needLoginModalBottomSheet(context);
            }
          },
        ):Container(),
      ],
    );
  }

  PreferredSizeWidget theStoreAppBar(context, String theLanguage, String theTitle){
    return AppBar(
      title: theTitle.isNotEmpty ? Text(theTitle, style: appBarStyle,):Image.asset(
        'images/whiteLogo.png',
        width: 70.0,
      ),
      foregroundColor: Colors.white,
      automaticallyImplyLeading: true,
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      elevation: 0.5,
    );
  }

  BoxDecoration importantBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(250.0),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 3,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    );
  }

  BoxDecoration advBoxDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10)),
      color: const Color.fromRGBO(255, 255, 255, 1),
      border: Border.all(color: const Color.fromRGBO(215, 215, 215, 1))
    );
  }

  RoundedRectangleBorder circleBtn(){
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
      bottomRight: Radius.circular(10),
      bottomLeft: Radius.circular(10)),
      side: BorderSide(width: 1, color: Colors.white24)
    );
  }

  Widget loadingPage(context){
    return FloatingActionButton(
      onPressed: ()=> null,
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).secondaryHeaderColor), strokeWidth: 3.0,),
      backgroundColor: Colors.white,
    );
  }

  void makeCall(String theNumber){
    launch("tel:$theNumber");
  }

  void openEmail(String theLink) async{
    await launch('mailto: $theLink');
  }
  void openLink(String theLink) async{
    await launchUrl(Uri.http(theLink));
  }
 String Price(){return price;}
  int  MinCount(){return minCount;}

}