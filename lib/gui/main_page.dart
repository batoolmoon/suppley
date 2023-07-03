import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:supplyplatform/components/mainPageIcon.dart';
import 'package:supplyplatform/gui/products/favourite.dart';
import 'package:supplyplatform/gui/products/products.dart';
import 'package:supplyplatform/gui/stores.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_stores.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supplyplatform/gui/view_photo.dart';
import 'package:supplyplatform/gui/view_video.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/drawer.dart';

import 'orders/orders.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  _MainPageState();

  late String searchQuery = '';
  final TextEditingController _getSearch = TextEditingController();
  late int pageId = 1;
  late String memberId;
  late String emailAddress;
  late String mobileNumber;
  late String fullName = '';
  late String deviceId = '';
  late String theLanguage = 'en';
  late int currencyId;
  late double currencyExchange;
  late TextAlign theAlignment;
  late TextDirection theDirection;
  late bool isLoading = true;
  late bool isLogin = false;
  late String notificationsCount = '0';
  late int cartCount;
  //late String LogInType;
  var funcs = Funcs();
  var styles = Styles();
  List sliderListFromApi = [];
  List sliderList = [];
  List sliderTitleList = [];
  List sliderStoreIdList = [];
  List sliderStoreNameList = [];
  List outAdvertisingSliderListFromApi = [];
  List outAdvertisingSliderList = [];
  List outAdvertisingSliderLinkList = [];
  int _outCurrent = 0;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _current = 0;

  var storesList = <GetStores>[];

  GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

  late String homeVideo = '';

  @override
  void initState() {
    super.initState();
    print("list");
print(storesList);
    getSharedData().then((result) {
      _getStoresDataList();
      if (isLogin == false) {
        initPlatformState();
      }
      checkIfActive();
      generateMemberToken();
      getUnreadNotificationsCount();
      getCurrencyData();

      _getSliderDataList();
      getAdvertisingData();

      Timer.periodic(const Duration(seconds: 10), (timer) {
        getUnreadNotificationsCount();
      });

      getHomeVideo().then((result) {
        setState(() {
          homeVideo = result['generalnNotesData'][0]['theDetails'];
        });
      });
    });

  }



  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlatformState() async {
    String deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = (await PlatformDeviceId.getDeviceId)!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceId', deviceId);
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  generateMemberToken() async {
    if (isLogin == true) {
      await funcs.generateMemberTokenId();
    }
  }

  getUnreadNotificationsCount() async {
    if (isLogin == true) {
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  Future<Map> getHomeVideo() async {
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(
        funcs.mainLink + 'api/getGeneralNotes/$theLanguage/home_video');
    http.Response response =
        await http.get(myUrl, headers: {"Accept": "application/json"});
    try {
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    } catch (e) {
      print(e);
    }
    return result;
  }

  _getStoresDataList() async{
    isLoading = true;
    setState(() {});

    //TODO replace the url bellow with you ipv4 address in ipconfig
    var myUrl = Uri.parse(funcs.mainLink + 'api/getStores');

    var request = http.MultipartRequest('POST', myUrl);

    request.fields.addAll({
      "theLanguage": theLanguage,
      "pageId": pageId.toString(),
      "orderType": 'byNewer',
      "searchQuery" : searchQuery
    });
    var response = await request.send();
    http.Response.fromStream(response).then((onValue) {
      try {
        var theResult = json.decode(onValue.body);

        if(theResult['resultFlag'] == 'done'){
          Iterable list = theResult['theData'];
          storesList = list.map((model) => GetStores.fromJson(model)).toList();

          setState(() {isLoading = false;});
        }else{
          styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
        }

      } catch (e) {
        // handle exeption
      }


    });
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      isLogin = prefs.getBool('isLogin')!;
      memberId = prefs.getString('memberId')!;
      currencyId = prefs.getInt('currencyId')!;
      currencyExchange = prefs.getDouble('currencyExchange')!;
      cartCount = prefs.getInt('cartCount')!;
      deviceId = prefs.getString('deviceId')!;
      /*--------------------------------------*/

      fullName = prefs.getString('fullName')!;
      emailAddress = prefs.getString('emailAddress')!;
      // LogInType=prefs.getString('LogInType')!;
      //print("LogInType--- "+LogInType);
      mobileNumber = prefs.getString('mobileNumber')!;

      print("theLanguage " + theLanguage);
      print("isLogin " + isLogin.toString());
      print("memberId " + memberId);
      print("currencyId " + currencyId.toString());
      print("currencyExchange " + currencyExchange.toString());
      print("fullName " + fullName);
      print("emailAddress " + emailAddress);
      print("mobileNumber " + mobileNumber);
      print("cartCount " + cartCount.toString());
      if (theLanguage == 'ar') {
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
      } else {
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }
    });
  }

  checkIfActive() async {
    if (isLogin == true) {
      isLoading = true;
      //TODO replace the url bellow with you ipv4 address in ipconfig
      var myUrl = Uri.parse(funcs.mainLink + 'api/checkIfActive');

      var request = http.MultipartRequest('POST', myUrl);
      request.fields.addAll({"memberId": memberId});
      var response = await request.send();
      http.Response.fromStream(response).then((onValue) {
        try {
          var isActiveData = json.decode(onValue.body);
          if (isActiveData['checkActive'][0]['isActive'] == '0') {
            logout();
          }

          setState(() {});
        } catch (e) {
          // handle exeption
        }
      });
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    await prefs.setString('memberId', '0');
    await prefs.setString('fullName', '');
    await prefs.setString('emailAddress', '');
    await prefs.setString('mobileNumber', '');
    await prefs.setInt('currencyId', 1);
    await prefs.setString('currencySymbol', 'Jod');
    await prefs.setDouble('currencyExchange', 1.00);
    await prefs.setBool('isLogin', false);
    await prefs.setInt('cartCount', 0);
    await prefs.setString('deviceId', '');
    await prefs.setString('LogInType', '');

    initPlatformState();

//    print(theLanguage);
    Locales.change(context, theLanguage);
    await prefs.setString('theLanguage', theLanguage);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/Login', (Route<dynamic> route) => false);
  }

  _getSliderDataList() {
    GetData.getDataList(funcs.mainLink + 'api/getSlider/$theLanguage')
        .then((response) {
      setState(() {
        sliderListFromApi = json.decode(response.body);
        for (var e in sliderListFromApi) {
          setState(() {
            sliderList.add(e['thePhoto'].toString());
            sliderTitleList.add(e['theTitle'].toString());
            sliderStoreIdList.add(e['storeId'].toString());
            sliderStoreNameList.add(e['storeName'].toString());
            print(sliderList);
          });
        }
        isLoading = false;
      });
    });
  }

  getAdvertisingData() {
    GetData.getDataList(funcs.mainLink + 'api/getAdvertising').then((response) {
      setState(() {
        outAdvertisingSliderListFromApi = json.decode(response.body);

        for (var e in outAdvertisingSliderListFromApi) {
          setState(() {
            outAdvertisingSliderList.add(e['thePhoto'].toString());
            outAdvertisingSliderLinkList.add(e['theLink'].toString());
          });
        }
        isLoading = false;
      });
    });
  }

  void getCurrencyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(Uri.parse(funcs.mainLink + 'api/getCurrencyData'), body: {
      "currencyId": currencyId.toString(),
    }).then((result) async {
      var theResult = json.decode(result.body);
      if (theResult['resultFlag'] == 'done') {
        String currencySymbol = theResult['theResult'][0]['currencySymbol'];
        String currencyExchange = theResult['theResult'][0]['currencyExchange'];

        await prefs.setString('currencySymbol', currencySymbol);
        await prefs.setDouble(
            'currencyExchange', double.parse(currencyExchange));
      } else {
        await prefs.setString('currencySymbol', 'Jod');
        await prefs.setDouble('currencyExchange', 1.00);
        await prefs.setInt('currencyId', 1);
      }
    }).catchError((error) {
      print(error);
    });
  }

  _viewPhoto(String photoName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ViewPhoto(photoName.toString(), 'home_slider')));
  }

  needToRefresh() {
    setState(() {
      _getSliderDataList();
    });
  }

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
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
        appBar: styles.theAppBar(
            context, theLanguage, isLogin, '', true, true, notificationsCount),
        body: isLoading == false
            ? CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white, //Colors.red,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(20))),
                            width: 100,
                            height: 260,
                            child: Stack(children: [
                              Positioned(
                                bottom: 90.0,
                                top:0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 51, 1),borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight:Radius.circular(35) )),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset("images/whiteLogo.png" , width: 110,height: 45, ),
                                      SizedBox(width:15),
                                      SizedBox(
                                        height: 90,
                                        width: 200,
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          expands: false,
                                          autocorrect: false,
                                          style: const TextStyle(color: Colors.black87, height: 1.0, fontWeight: FontWeight.w300),
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                                            prefixIcon: const Icon(Icons.search, color: Colors.black87),
                                            enabledBorder: const UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.transparent),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                            ),
                                            suffixIcon: IconButton(
                                              onPressed:() {
                                                // if searched
                                                setState(() {
                                                  _getSearch.text = '';
                                                  searchQuery = '';
                                                });
                                               // _getStoresDataList();
                                              },
                                              icon: const Icon(Icons.clear, color: Colors.grey,),
                                            ),
                                            hintText: context.localeString('search').toString(), hintStyle: styles.inputTextHintStyle,
                                            fillColor: const Color.fromRGBO(250,250,250,1),
                                            filled: true,
                                          ),
                                          controller: _getSearch,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.search,
                                          onSubmitted: (value){
                                            if(value.isNotEmpty){
                                              setState(() {
                                                searchQuery = value;
                                              });
                                              _getStoresDataList();
                                            }
                                          },
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),),
                              ),
                              Positioned(
                                  top: 70,
                                  bottom: 30,
                                  right: 30,
                                  left: 30,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 40,
                                          offset:
                                              Offset(8, 15), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        CarouselSlider(
                                          options: CarouselOptions(
                                              height: 150.0,
                                              initialPage: 0,
                                              viewportFraction: 1,
//                                enlargeCenterPage: true,
                                              autoPlay: true,
                                              reverse: false,
                                              pauseAutoPlayInFiniteScroll:
                                                  false,
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                              enableInfiniteScroll: true,
                                              disableCenter: true,
                                              autoPlayInterval:
                                                  const Duration(seconds: 6),
//                                autoPlayAnimationDuration: const Duration(milliseconds: 4000),
                                              scrollDirection: Axis.horizontal,
                                              onPageChanged: (index, reason) {
                                                setState(() {
                                                  _current = index;
                                                });
                                              }),
                                          items: sliderList.map((sliderPhoto) {
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return GestureDetector(
                                                  onTap: () => {
                                                    if (sliderStoreIdList[
                                                            _current] ==
                                                        "0")
                                                      {
                                                        _viewPhoto(sliderList[
                                                            _current])
                                                      }
                                                    else
                                                      {
                                                        print("Id " +
                                                            sliderStoreIdList[
                                                                _current]),
                                                        print(sliderList),
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => Products(
                                                                  sliderStoreIdList[
                                                                      _current],
                                                                  sliderStoreNameList[
                                                                      _current],
                                                                  'products',
                                                                  '')),
                                                        ),
                                                      }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 150,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        //padding:const EdgeInsets.symmetric(horizontal: 10.0) ,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 5.0),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius
                                                                        .circular(
                                                                            10)),
                                                            child:
                                                                Image.network(
                                                              funcs.mainLink +
                                                                  'public/uploads/php/files/home_slider/thumbnail/' + sliderPhoto,
                                                              fit: BoxFit.cover,
                                                              width: 100,
                                                            )),
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
                                  )),
                            ]),
                          ),
                          Container(
                            height: 80,
                            width: 50,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  homeIcon(
                                      homeicons: IconButton(
                                          onPressed: () {
                                            if (isLogin == true) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Orders()),
                                              );
                                            } else {
                                              styles.needLoginModalBottomSheet(
                                                  context);
                                            }
                                          },
                                          icon: Icon(Icons
                                              .local_grocery_store_rounded),
                                          color: Colors.white),
                                      iconword: context
                                          .localeString('my_orders')
                                          .toString()),
                                  homeIcon(
                                      homeicons: IconButton(
                                        onPressed: () {
                                          if (isLogin == true) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Favourite()),
                                            );
                                          } else {
                                            styles.needLoginModalBottomSheet(
                                                context);
                                          }
                                        },
                                        icon: Icon(
                                            Icons.favorite_outline_outlined),
                                        color: Colors.white,
                                      ),
                                      iconword: context
                                          .localeString('favourite')
                                          .toString()),
                                  homeIcon(
                                      homeicons: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Stores()),
                                          );
                                        },
                                        icon: Icon(Icons.percent),
                                        color: Colors.white,
                                      ),
                                      iconword: context
                                          .localeString('special_offers')
                                          .toString()),


                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    outAdvertisingSliderList != null
                        ? SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      CarouselSlider(
                                        options: CarouselOptions(
                                            height: 160.0,
                                            initialPage: 0,
                                            viewportFraction: 1,
//                                enlargeCenterPage: true,
                                            autoPlay: true,
                                            reverse: false,
                                            pauseAutoPlayInFiniteScroll: false,
                                            autoPlayCurve: Curves.fastOutSlowIn,
                                            enableInfiniteScroll: true,
                                            disableCenter: true,
                                            autoPlayInterval:
                                                const Duration(seconds: 6),
//                                autoPlayAnimationDuration: const Duration(milliseconds: 4000),
                                            scrollDirection: Axis.horizontal,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _outCurrent = index;
                                              });
                                            }),
                                        items: outAdvertisingSliderList
                                            .map((sliderPhoto) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () => styles.openLink(
                                                    outAdvertisingSliderLinkList[
                                                        _outCurrent]),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 130,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5.0),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10)),
                                                          child: Image.network(
                                                            funcs.mainLink +
                                                                'public/uploads/php/files/advertising/thumbnail/' +
                                                                outAdvertisingSliderList[
                                                                    _outCurrent],
                                                            fit: BoxFit.cover,
                                                          )),
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
                                )
                              ],
                            ),
                          )
                        : SliverList(delegate: SliverChildListDelegate([])),
                    homeVideo.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildListDelegate([
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ViewVideo(homeVideo))),
                              child: Container(
                                margin: const EdgeInsets.only(
                                    bottom: 5.0,
                                    left: 15.0,
                                    top: 15.0,
                                    right: 15.0),
                                width: 400.0,
                                height: 230.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0.0),
                                    image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: NetworkImage(
                                            "http://i3.ytimg.com/vi/$homeVideo/hqdefault.jpg"))),
                              ),
                            )
                          ]))
                        : SliverList(delegate: SliverChildListDelegate([])),
                    SliverList(
                        delegate: SliverChildListDelegate([


                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 5.0, left: 15.0, top: 15.0, right: 15.0),
                        child: Text(context.localeString('top_rate_stores'),
                            textDirection: theDirection,
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: theAlignment),
                      ),
                    ])),
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent:
                            MediaQuery.of(context).size.width / 3,
                        childAspectRatio:
                            MediaQuery.of(context).size.width / (600),
//                childAspectRatio: 0.7,
                        mainAxisSpacing: 2.0,
                        crossAxisSpacing: 2.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return styles.widgetStores(
                              scaffoldKey, context, storesList,index);
                        },
                        childCount: storesList.length,
                      ),
                    )
                  ])
            : Container(),
        floatingActionButton:
            isLoading == true ? styles.loadingPage(context) : Container(),
        bottomNavigationBar: BottomNavigationBarWidget(0),
        drawer: DrawerClass(isLogin, fullName),
      ),
    );
  }
}
