import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supplyplatform/gui/members/login.dart';
import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_products.dart';
import 'package:supplyplatform/module/get_tags.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_locales/flutter_locales.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supplyplatform/gui/view_photo.dart';

class ProductDetails extends StatefulWidget{
  ProductDetails(this.productId);
  String productId;
bool AddFav(){
  return _ProductDetailsState(productId)._clickFavorite();
}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductDetailsState(productId);
  }

}

class _ProductDetailsState extends State<ProductDetails>{
  _ProductDetailsState(this.productId);
  String productId;
  late String productTitle = '';
  late String productPhoto = '';
  late String categoryTitle = '';
  late String priceId = '0';
  late String memberId;
  late String theLanguage;
 late String deviceId = '0';
  late bool isLogin;
  late int currencyId;
  late double currencyExchange;
  late int cartCount;

  late TextAlign theAlignment = TextAlign.right;
  late Alignment theTopAlignment;
  bool addedToFavourite = false;

  late String notificationsCount = '0';

  late String productDetails = '';
  late String productLink = '';
  late String storeName;
  late String storeId;
  late String thePrice;
  late String theDiscount  = '0.0';
  late String theQuantity;
  late String minCount ;
  late String theNote = '';
  late String symbol = '';
  late String priceAfterDiscount;
  late String totalPrice ="0.0";
  late String priceBeforeDiscount="0.0";
  late String optionId = '0';
  late String categoryId;
  late String isOffer;
  late String offerExpiryDate;

 //this.categoryId,required this.minCount
 //  late String categoryProfit = '0';

  late bool isLoading = true;
  List<DropdownMenuItem<String>> pricesSizesList = [];
  String priceSizeId = '0';

int _selectedQuantity=0 ;

  var funcs = Funcs();
  var styles = Styles();
  // late String totalPrice; //= Styles().Price().toString();
  // late int _selectedQuantity; //=Styles().MinCount();


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final _ratingController = TextEditingController();
  final bool _isVertical = false;
  late double _productRating = 1.0;
  late double _thisUserRating = 1.0;
  final int _ratingBarMode = 1;
  IconData? _selectedIcon;
  bool isRated = false;

  bool showRateBtn = false;
  late double tempRate = 0.0;
  var relatedProductsList = <GetProducts>[];

  List sliderListFromApi = [];
  List sliderList = [];

  int _current = 0;
  List<T> map<T>(List list, Function handler){
    List<T> result = [];
    for(var i = 0; i < list.length; i++){
      result.add(handler(i, list[i]));
    }
    return result;
  }


  var tagsList = <GetTags>[];

  @override
  void initState(){
    super.initState();
    _ratingController.text = "0.0";
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      _getProductsMediaDataList();
      getProductData();
      getRate();
      checkIfUserRated();
      getPricesData();
      checkFavouriteStatus();
      _getRelatedProductsDataList();
     // totalPrice ="100"; //Styles().Price().toString();
     // _selectedQuantity =4;//Styles().MinCount();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  _getRelatedProductsDataList() {
    GetData.getDataList(funcs.mainLink+'api/getRelatedProducts/$theLanguage/$productId/$currencyId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        relatedProductsList = list.map((model) => GetProducts.fromJson(model)).toList();
      });
    });
  }

  getProductData(){
    getData().then((result) {

      setState (() {
        productDetails = result['productDetails'][0]['theDetails'];
        productTitle = result['productDetails'][0]['theTitle'];
        productPhoto = result['productDetails'][0]['thePhoto'];
        categoryTitle = result['productDetails'][0]['categoryTitle'];
       thePrice = result['productDetails'][0]['thePrice'];
        priceId = result['productDetails'][0]['priceId'];
        theDiscount = result['productDetails'][0]['theDiscount'];
        theQuantity = result['productDetails'][0]['theQuantity'];
        minCount = result['productDetails'][0]['minCount'];
        isOffer=result['productDetails'][0]['isOffer'];
        offerExpiryDate=result['productDetails'][0]['offerExpiryDate'];
        theNote = result['productDetails'][0]['theNote'];
        productLink = result['productDetails'][0]['theLink'];
        symbol = result['productDetails'][0]['symbol'];
        storeName = result['productDetails'][0]['storeName'];
        storeId = result['productDetails'][0]['storeId'];
       categoryId=result['productDetails'][0]['categoryId'];
        _selectedQuantity=int.parse(minCount);
        print (_selectedQuantity);
        print(thePrice);
        print(theDiscount);
        print(currencyExchange);
        priceAfterDiscount = funcs.getPriceAfterDiscount(thePrice,theDiscount, _selectedQuantity, currencyExchange/*,"100"*/).toStringAsFixed(2);
        totalPrice = funcs.getTotalPrice(thePrice,theDiscount,_selectedQuantity,currencyExchange/*,"100"*/).toStringAsFixed(2);
        priceBeforeDiscount = funcs.getPriceBeforeDiscount(thePrice,theDiscount,_selectedQuantity,currencyExchange/*,"100"*/).toStringAsFixed(2);

      });
      _getTagsDataList(priceId);
    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = prefs.getString('memberId')!;
      theLanguage = prefs.getString('theLanguage')!;
     deviceId = prefs.getString('deviceId')!;
      isLogin = prefs.getBool('isLogin')!;
      currencyId = prefs.getInt('currencyId')!;
      currencyExchange = prefs.getDouble('currencyExchange')!;
         cartCount = prefs.getInt('cartCount')!;
      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theTopAlignment = Alignment.topRight;
      }else{
        theAlignment = TextAlign.left;
        theTopAlignment = Alignment.topLeft;
      }

    });
  }

  _getTagsDataList(String thePriceId) {
    tagsList = [];
    GetData.getDataList(funcs.mainLink+'api/getTags/$theLanguage/$thePriceId/').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        if(list.isNotEmpty){
          tagsList = list.map((model) => GetTags.fromJson(model)).toList();
          optionId = tagsList[0].optionId;
        }

        isLoading = false;
      });
    });
  }

  // rating
  getRate() async{
    String theUsersRating = await funcs.getRate(productId);
    setState(() {
      _productRating = double.parse(theUsersRating);
    });
  }

  checkIfUserRated() async{
    var myUrl = Uri.parse(funcs.mainLink+'api/checkIfUserRated/$memberId/$productId/');
    http.Response response = await http.post(myUrl, headers: {"Accept": "application/text"});
    var theResult = json.decode(response.body);
    if(theResult['theResult'] == true){
      setState(() {
        isRated = true;
        _thisUserRating = double.parse(theResult['theRate']);
      });
    }else if(theResult['theResult'] == false){
      setState(() {
        isRated = false;
      });
    }else{
      isRated = false;
    }
  }


  Widget _ratingBar(int mode){
    switch (mode) {
      case 1:
        return RatingBar.builder(
          initialRating: 0,
          direction: _isVertical ? Axis.vertical : Axis.horizontal,
          allowHalfRating: true,
          unratedColor: Colors.grey[200],
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            _selectedIcon ?? Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating){
            setState(() {
              if(rating > 0.0){
                showRateBtn = true;
              }else{
                showRateBtn = false;
              }
              tempRate = rating;
            });
          },
        );

      default:
        return Container();
    }
  }

  rateThisProduct() async{
    styles.onLoading(context);
    String response  = await funcs.rateProduct(isLogin,tempRate,memberId,productId);
    if(response == 'true'){
      getRate();
      setState(() {
        isRated = true;
        _thisUserRating = tempRate;
        showRateBtn = false;
      });
      Navigator.of(context, rootNavigator: true).pop();
    }else{
      styles.showSnackBar(scaffoldKey, context,context.localeString('error_occurred').toString(),'error','');
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  // end rating

  Future<Map> getData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getProductDetails/$theLanguage/$productId/$priceId/$currencyId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
//      print(e);
    }

    return result;
  }

  _getProductsMediaDataList() {
    GetData.getDataList(funcs.mainLink+'api/getProductMedia/$productId').then((response) {
      setState(() {
        sliderListFromApi = json.decode(response.body);
        for (var e in sliderListFromApi) {
          setState(() {
            sliderList.add(e['theMedia'].toString());
          });
        }
        isLoading = false;
      });
    });
  }

  checkFavouriteStatus() async{

    await http.post(Uri.parse(funcs.mainLink+'api/checkFavouriteStatus'), body: {
      "memberId" : memberId,
      "productId": productId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['theResult'] == true){
        setState(() {
          addedToFavourite = true;
        });
      }else if(theResult['theResult'] == false){
        setState(() {
          addedToFavourite = false;
        });
      }else{
      }
    }).catchError((error) {
      print(error);
    });

  }

  addRemoveFavorite() async{
    styles.onLoading(context);
    await http.post(Uri.parse(funcs.mainLink+'api/addRemoveFavourite'), body: {
      "memberId" : memberId,
      "productId": productId,
    }).then((result) async{
      var theResult = json.decode(result.body);
      if(theResult['theResult'] == true){
        setState(() {
          addedToFavourite = true;
        });
        Navigator.of(context, rootNavigator: true).pop();
      }else if(theResult['theResult'] == false){
        setState(() {
          addedToFavourite = false;
        });
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        Navigator.of(context, rootNavigator: true).pop();
      }
    }).catchError((error) {
      print(error);
      Navigator.of(context, rootNavigator: true).pop();
    });

  }
  bool _clickFavorite(){
    addedToFavourite=!addedToFavourite;
    setState(() {
      addRemoveFavorite();
    });
    return addedToFavourite;
  }

  void _openLink(String theLink) async{
    styles.openLink(theLink);
  }

  void minus() {
    setState(() {
      if (_selectedQuantity != 1 && _selectedQuantity > int.parse(minCount) ){
        _selectedQuantity=_selectedQuantity-1;
        totalPrice = funcs.getTotalPrice(thePrice,theDiscount,_selectedQuantity,currencyExchange/*,categoryProfit*/).toStringAsFixed(2);
        priceBeforeDiscount = funcs.getPriceBeforeDiscount(thePrice,theDiscount,_selectedQuantity, currencyExchange/*,categoryProfit*/).toStringAsFixed(2);
      }
      else {
        styles.showSnackBar(scaffoldKey, context,context.localeString('minimum_order'),'error','');
      }
      print(minCount);
      print(_selectedQuantity);
      print("min"+totalPrice);
    });
  }

  void add() {
    setState(() {
      if(int.parse(minCount) > 0){
        if(int.parse(theQuantity) == 0){
          styles.showSnackBar(scaffoldKey, context,context.localeString('quantity_not_available').toString(),'error','');
        }else if(int.parse(theQuantity) > _selectedQuantity){
          _selectedQuantity = _selectedQuantity + 1;
        }
      }else{
        _selectedQuantity = _selectedQuantity + 1;
      }
      totalPrice = funcs.getTotalPrice(thePrice,theDiscount,_selectedQuantity,currencyExchange).toStringAsFixed(2);
      priceBeforeDiscount = funcs.getPriceBeforeDiscount(thePrice,theDiscount,_selectedQuantity, currencyExchange).toStringAsFixed(2);
      print("total price"+totalPrice);
    });
  }


  void getPricesData() async{
    setState(() {
      isLoading = true;
    });
    var myUrl = Uri.parse(funcs.mainLink+'api/getProductPricesData/$theLanguage/$productId');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});

    if(int.parse(priceId) == 0){
      pricesSizesList.add(DropdownMenuItem(
        child: Text(context.localeString('please_select')),
        value: '0',
      ));
    }

    try{
      setState(() {
        isLoading = false;
      });
      var responseData = json.decode(response.body);
      responseData.forEach((sizes){
        pricesSizesList.add(DropdownMenuItem(
          child: Text(sizes['thePriceSizeTitle'],overflow: TextOverflow.visible),
          value: "${sizes['prId']}",
        ));
      },
      );
    }catch(e){
      print(e);
    }

  }

  _changeSizes(String e){
    setState(() {
      priceId = e;
      optionId = '0';
      getProductData();
    });
  }


  Widget widgetTagsList(){
    return ListView.builder(
      itemCount: tagsList.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: false,
      itemBuilder: (BuildContext context, int index) =>
          Container(
              height: 25.0,
              margin: const EdgeInsets.only(right: 5.0, left: 5.0),
              child: ElevatedButton(
                onPressed: ()=> _selectTag(tagsList[index].optionId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 1.0, bottom: 1.0 ),
                  elevation: 0.0,
                  primary: optionId == tagsList[index].optionId ?  Theme.of(context).primaryColor : Colors.black12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),),

                child: Text(tagsList[index].theTitle,style: TextStyle(color: optionId == tagsList[index].optionId ? Colors.white:Colors.black87, fontSize: 13.0), textAlign: TextAlign.center),


              )

          ),
    );
  }


  _selectTag(String theOptionId){
    if(int.parse(theOptionId) > 0 ){
      setState(() {
        optionId = theOptionId;
      });
    }
  }

  addToCart(scaffoldKey, context, bool isLogin, String productId, String priceId, String optionId, int currencyId, int quantity) async{

    styles.onLoading(context);

    String response  = await funcs.addToCart(isLogin, storeId, productId, priceId,optionId, quantity, currencyId);

    if(response == '1'){
      Navigator.of(context, rootNavigator: true).pop();
      styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'added_to_card'),'success','');

      setState(() {
       cartCount = cartCount + quantity ;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cartCount', cartCount);

      setState(() {

      });

    }else if(response == 'already_added'){
      Navigator.of(context, rootNavigator: true).pop();
      styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'already_added_to_cart'),'error','');
    }else if(response == 'quantity_not_avaliable'){
      Navigator.of(context, rootNavigator: true).pop();
      styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'quantity_not_available'),'error','');
    }else if(response == 'not_same_store'){
      Navigator.of(context, rootNavigator: true).pop();
      styles.showSnackBar(scaffoldKey, context,Locales.string(context, 'not_same_store'),'error','');
    }else{
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  needToRefresh(){
    setState(() {

    });
  }


  _viewPhoto(String photoName,String theType){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ViewPhoto(photoName.toString(),theType)));
  }

  Future<bool> _onWillPop() async{
    if (Navigator.canPop(context)) {
      Navigator.pop(context,true);
      return false;
    } else {
      exit(0);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        appBar: styles.theAppBar(context, theLanguage, isLogin, isLoading == false ? productTitle : '' , true, true, notificationsCount),
        body: isLoading == true ? Center(
          child: Container(),
        ): Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: <Widget>[
                                sliderList.isEmpty ? ClipRRect(
                                  borderRadius: BorderRadius.circular(13.0),
                                  child: productPhoto.isNotEmpty ? FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: funcs.mainLink+"public/uploads/php/files/products/thumbnail/$productPhoto"):Container(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'images/logo.png',
                                      width: 120.0,
                                    ),
                                  ),
                                ):
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(height: 50.0,),
                                      CarouselSlider(
                                        options: CarouselOptions(
                                            height: 200.0,
                                            initialPage: 0,
                                            viewportFraction: 1,
                                            autoPlay: sliderList.length > 1 ? true:false,
                                            reverse: false,
                                            autoPlayCurve: Curves.fastOutSlowIn,
                                            enableInfiniteScroll: true,
                                            autoPlayInterval: const Duration(seconds: 5),
                                            disableCenter: true,
                                            autoPlayAnimationDuration: const Duration(milliseconds: 2000),
                                            scrollDirection: Axis.horizontal,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _current = index;
                                              });
                                            }
                                        ),

                                        items: sliderList.map((sliderPhoto) {
                                          return Builder(
                                            builder: (BuildContext context){
                                              return GestureDetector(
                                                onTap: ()=> _viewPhoto(sliderPhoto,'products'),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height:170,
                                                      width: MediaQuery.of(context).size.width,
                                                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.transparent,
                                                      ),
                                                      child: ClipRRect(
                                                          borderRadius: const BorderRadius.only(topRight:  Radius.circular(10), topLeft:  Radius.circular(10)),
                                                          child: Image.network(
                                                            funcs.mainLink+'public/uploads/php/files/products/thumbnail/'+sliderPhoto,
                                                            fit: BoxFit.cover,
                                                          )
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),

                                ),
                                const SizedBox(height: 10.0,),
                                Container(
                                  width: double.infinity,
                                  child: Text(productTitle, style: styles.listTileStyle2/*Theme.of(context).textTheme.*/, textAlign: theAlignment),
                                ),

                                const SizedBox(height: 10.0,),
                                const Divider(),
                                Container(
                                  width: 400.0,
                                  padding: const EdgeInsets.only(right: 0.0, left: 0.0, top: 0.0),
                                  alignment: Alignment.topCenter,
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        items: pricesSizesList,
                                        value: priceId,
                                        isExpanded: true,
                                        onChanged: (value)=> _changeSizes(value.toString()),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 10.0,),

                                int.parse(priceId) > 0 && tagsList.isNotEmpty ? Container(
                                  height: 40.0,
                                  child: widgetTagsList(),
                                ):Container(),

                                const SizedBox(height: 10.0,),

                                Row(
                                  children: <Widget>[
                                    RatingBarIndicator(
                                      rating: _productRating,
                                      itemBuilder: (context, index) => Icon(
                                        _selectedIcon ?? Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 20.0,
                                      direction: _isVertical ? Axis.vertical : Axis.horizontal,
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    isLogin == true ? Container(
                                      padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                                      child: IconButton(
                                        icon: addedToFavourite == true ? const Icon(Icons.favorite, color: Colors.red, size: 40.0,): const Icon(Icons.favorite_outline_rounded, color: Colors.grey, size: 40.0,),
                                        tooltip: context.localeString('add_remove_favourite').toString(),
                                        onPressed: ()=> addRemoveFavorite(),
                                      ),
                                    ):Container(),
                                  ],
                                ),

                                const SizedBox(height: 50.0,),

                                Container(
                                  width: double.infinity,
                                  child: Text(context.localeString('products_details'), style: styles.paragraphTitle, textAlign: theAlignment),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Html(
                                      data: productDetails,
                                      style: {
                                        'p': Style(fontSize: FontSize.large, lineHeight: LineHeight.number(1.6)),
                                        'strong': Style(fontSize: FontSize.large, color: Colors.black, fontWeight: FontWeight.bold,),
                                        'a': Style(fontSize: FontSize.large, color: Colors.blue,),
                                      },
                                      onLinkTap: (String? theUrl, RenderContext context, Map<String, String> attributes, dom.Element? element) async{
                                        if (await canLaunch(theUrl!)) {
                                          await launch(theUrl);
                                        } else {
                                          throw 'Could not launch $theUrl';
                                        }
                                      }
                                  ),
                                ),

                                const SizedBox(height: 30.0,),

                                theNote != null ? Container(
                                  width: double.infinity,
                                  child: Text(theNote, style: const TextStyle(color: Colors.red, fontSize: 16.0), textAlign: theAlignment),
                                ):Container(),

                                const SizedBox(height: 30.0,),
                                productLink != null && productLink != '' ? Container(
                                  width: double.infinity,
                                  child: Text(context.localeString('more_details'), style: styles.paragraphTitle, textAlign: theAlignment),
                                ):Container(),

                                productLink != null && productLink != '' ? GestureDetector(
                                  child: Container(
                                    width: double.infinity,
                                    child: Text(productLink, style: styles.paragraphText, textAlign: theAlignment),
                                  ),
                                  onTap: ()=> _openLink(productLink),
                                ):Container(),

                                isLogin == true ? Container(
                                  alignment: theLanguage =='en' ?Alignment.topLeft : Alignment.topRight,

                                  child: Text(context.localeString('rate_products'), style: styles.paragraphTitle, textAlign: theAlignment),
                                ):Container(),

                                isLogin == true ? Container(
                                  alignment: theTopAlignment,
                                  child: isRated == false ? Container(
                                      alignment: theLanguage =='en' ?Alignment.topLeft : Alignment.topRight,
                                      child: _ratingBar(_ratingBarMode)):Text(context.localeString('your_rate') + ' $_thisUserRating', style: styles.paragraphText, textAlign: theAlignment),
                                ):Container(),

                                showRateBtn == true ? Container(
                                  //padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                                  child: Container(
                                    alignment: theLanguage =='en' ?Alignment.topLeft : Alignment.topRight,
                                    child: ElevatedButton(
                                      onPressed: ()=> rateThisProduct(),
                                      style: ElevatedButton.styleFrom(
                                       // padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                        elevation: 0.0,
                                        shape: styles.circleBtn(),
                                        primary:Color.fromRGBO(194, 171, 131, 1)//Theme.of(context).secondaryHeaderColor,
    ),
                                      child: Text(context.localeString('rate'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),



                                    ),
                                  ),
                                ):Container(),

                                const SizedBox(height: 60.0,),

                              ],
                            ),
                          )
                        ]
                    ),
                  ),

                  SliverList(
                      delegate: SliverChildListDelegate(
                          [
                            relatedProductsList.isNotEmpty ? Container(
                              margin: const EdgeInsets.only(bottom: 5.0, left: 15.0, right: 15.0),
                              child: Text(context.localeString('related_products_title'), style: styles.paragraphTitle, textAlign: theAlignment),
                            ):Container(),
                            relatedProductsList.isNotEmpty ? Container(
                                margin: const EdgeInsets.only(bottom: 25.0),
                                height:390.0,
                                child: ListView.builder(
                                    itemCount: relatedProductsList.length,
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext context, int index){
                                      return styles.widgetProducts(scaffoldKey,context, isLogin, memberId, currencyExchange, relatedProductsList,index,'main_page',currencyId,);
                                    }
                                )
                            ):Container()
                          ]
                      )
                  ),

                ],
              ),
            ),

            Container(
              color: const Color.fromRGBO(245, 245, 245, 1),
              height: 80.0,
              padding: const EdgeInsets.only(bottom: 0.0, right: 15.0, left: 15.0),
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: ShapeDecoration(
                      color: Color.fromRGBO(0, 0, 51, 1),
                      shape: styles.circleBtn(),
                    ),
                    child: IconButton(
                      onPressed: (){
                        if(int.parse(theQuantity) == 0){
                          styles.showSnackBar(scaffoldKey, context,context.localeString('quantity_not_available').toString(),'error','');
                        }else{
                          addToCart(scaffoldKey,context,isLogin,productId,priceId,optionId,currencyId,_selectedQuantity);
                        }
                        }

                     ,
                      padding: const EdgeInsets.all(5.0),
                      icon: const Icon(Icons.add_shopping_cart),
                      color: Colors.white,
                      tooltip: context.localeString('add_to_cart'),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  double.parse(theDiscount) == 0.0 ? Text('$totalPrice $symbol', style: styles.productPrice, textAlign: theAlignment):
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 13.0,),
                      Text('$priceBeforeDiscount $symbol', style: styles.lineThroughPrice, textAlign: theAlignment),
                      Text('$totalPrice $symbol', style: styles.discountPrice, textAlign: theAlignment),
                    ],
                  ),
                  const SizedBox(width: 20.0,),
                  Expanded(
                    child: Container(),
                  ),
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 11.0,),
                      Row(
                        children: <Widget>[
                          Container(
                            decoration: ShapeDecoration(
                              color: Color.fromRGBO(194, 171, 131, 1),
                              shape: styles.circleBtn(),
                            ),
                            child: IconButton(
                              onPressed: (){ print(_selectedQuantity); add();},
                              padding: const EdgeInsets.all(5.0),
                              icon: const Icon(Icons.keyboard_arrow_up_sharp),
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            child: Text('$_selectedQuantity', style: const TextStyle(fontSize: 20.0, color: Colors.black87)),
                            padding: const EdgeInsets.all(10.0),
                          ),
                          Container(
                            decoration: ShapeDecoration(
                              color: Color.fromRGBO(194, 171, 131,1),

                              shape: styles.circleBtn(),
                            ),
                            child: IconButton(
                              onPressed: ()=> minus(),
                              padding: const EdgeInsets.all(5.0),
                              icon: const Icon(Icons.keyboard_arrow_down_sharp),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarWidget(1),
        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      ),
    );
  }

}