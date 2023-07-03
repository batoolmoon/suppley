import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_locales/flutter_locales.dart';

class StoreDetails extends StatefulWidget{
  StoreDetails(this.storeId);
  String storeId;


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StoreDetailsState(storeId);
  }

}

class _StoreDetailsState extends State<StoreDetails>{
  _StoreDetailsState(this.storeId);
  String storeId;


  late String memberId;
  late String theLanguage;
  late String deviceId = '0';
  late bool isLogin;

  late String storeName = '';
  late String storePhoto = '';
  late String storeEmailAddrress = '';
  late String storeMobileNumber = '';
  late String storeAddress = '';

  late TextAlign theAlignment = TextAlign.right;
  late Alignment theTopAlignment;

  late bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final _ratingController = TextEditingController();
  final bool _isVertical = false;
  late double _storeRating = 1.0;
  late double _thisUserRating = 1.0;
  final int _ratingBarMode = 1;
  IconData? _selectedIcon;
  bool isRated = false;

  bool showRateBtn = false;
  late double tempRate = 0.0;

  @override
  void initState(){
    super.initState();
    _ratingController.text = "0.0";
    getSharedData().then((result) {
      getProductData();
      getRate();
      checkIfUserRated();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProductData(){
    getData().then((result) {

      setState (() {
        storePhoto = result['theData'][0]['thePhoto'];
        storeName = result['theData'][0]['storeName'];
        storeEmailAddrress = result['theData'][0]['emailAddress'];
        storeMobileNumber = result['theData'][0]['mobileNumber'];
        storeAddress = result['theData'][0]['address'];
      });
    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = prefs.getString('memberId')!;
      theLanguage = prefs.getString('theLanguage')!;
      deviceId = prefs.getString('deviceId')!;
      isLogin = prefs.getBool('isLogin')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theTopAlignment = Alignment.topRight;
      }else{
        theAlignment = TextAlign.left;
        theTopAlignment = Alignment.topLeft;
      }

    });
  }

  // rating
  getRate() async{
    String theUsersRating = await funcs.getStoreRate(storeId);
    setState(() {
      _storeRating = double.parse(theUsersRating);
    });
  }

  checkIfUserRated() async{
    var myUrl = Uri.parse(funcs.mainLink+'api/checkIfUserRatedStore/$memberId/$storeId/');
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

  rateThisStore() async{
    styles.onLoading(context);
    String response  = await funcs.rateStore(isLogin,tempRate,memberId,storeId);
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
    var myUrl = Uri.parse(funcs.mainLink+'api/getStoreDetails/$storeId/');
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
        appBar: styles.theAppBar(context, theLanguage, isLogin, '' , true, false, '0'),
        body: Column(
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

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 100.0,
                                        height: 100.0,
                                        margin: const EdgeInsets.only(right: 10.0),
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              topRight:  Radius.circular(30),
                                              topLeft:  Radius.circular(30),
                                              bottomLeft: Radius.circular(30),
                                              bottomRight: Radius.circular(30),
                                            ),
                                            image: storePhoto != null && storePhoto != '' ? DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(funcs.mainLink+ 'public/uploads/php/files/stores/'+storePhoto),
                                            ):const DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage('images/default.png',)
                                            )
                                        ),
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(storeName, style: styles.paragraphTitle, textAlign: theAlignment),

                                            RatingBarIndicator(
                                              rating: _storeRating,
                                              itemBuilder: (context, index) => Icon(
                                                _selectedIcon ?? Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 20.0,
                                              direction: _isVertical ? Axis.vertical : Axis.horizontal,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10.0,),
                                const Divider(),

                                Container(
                                  alignment: theTopAlignment,
                                  child: Text(storeAddress, style: styles.paragraphText, textAlign: theAlignment),
                                ),

                                Container(
                                  alignment: theTopAlignment,
                                  child: GestureDetector(
                                    child: Text(storeMobileNumber, style: styles.paragraphText, textAlign: theAlignment),
                                    onTap: ()=> styles.makeCall(storeMobileNumber),
                                  ),
                                ),

                                Container(
                                  alignment: theTopAlignment,
                                  child: Text(storeEmailAddrress, style: styles.paragraphText, textAlign: theAlignment),
                                ),

                                const SizedBox(height: 20.0,),

                                isLogin == true ? Container(
                                  alignment: theTopAlignment,
                                  child: Text(context.localeString('rate_store'), style: styles.paragraphTitle, textAlign: theAlignment),
                                ):Container(),

                                isLogin == true ? Container(
                                  alignment: theTopAlignment,
                                  child: isRated == false ? Center(child: _ratingBar(_ratingBarMode),):Text(context.localeString('your_rate') + ' $_thisUserRating', style: styles.paragraphText, textAlign: theAlignment),
                                ):Container(),

                                showRateBtn == true ? Container(
                                  padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20.0),
                                  child: ElevatedButton(
                                    onPressed: ()=> rateThisStore(),
                                    style: ElevatedButton.styleFrom(
                                      padding:   const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                                      elevation: 0.0,
                                      shape:  styles.circleBtn(),
                                    backgroundColor: Theme.of(context).secondaryHeaderColor,),
                                    child: Text(context.localeString('rate'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

                                   //todo
                                  ),
                                ):Container(),

                                const SizedBox(height: 60.0,),

                              ],
                            ),
                          )
                        ]
                    ),
                  ),

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