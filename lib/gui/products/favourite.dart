import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_favourite.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/drawer.dart';

class Favourite extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FavouriteState();
  }

}

class _FavouriteState extends State<Favourite>{

  late bool isLogin;
  late String memberId;
  late String fullName = '';
  late String theLanguage;
  late int currencyId;
  late double currencyExchange;
  late TextAlign theAlignment;
  bool isLoading = true;
  int pageId = 1;

  var funcs = Funcs();
  var styles = Styles();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  var favList = <GetFavourite>[];
  _getDataList(int pageId) {
    print("mem"+memberId);

    GetData.getDataList(funcs.mainLink+'api/getFavouriteData/$theLanguage/$memberId/$currencyId/$pageId').then((response) {
      setState(() {

        Iterable list = json.decode(response.body);
        favList = list.map((model) => GetFavourite.fromJson(model)).toList();
        isLoading = false;
      });
    });

  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      _getDataList(pageId);
    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        pageId = pageId + 1;
        setState(() {
          isLoading = true;
          _getDataList(pageId);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        memberId = prefs.getString('memberId')!;
        fullName = prefs.getString('fullName')!;
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;
        currencyExchange = prefs.getDouble('currencyExchange')!;
        currencyId = prefs.getInt('currencyId')!;

        if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        }else{
        theAlignment = TextAlign.left;
        }
      });
    }
  }

  Widget widgetProductsData(int pageId){

    return GridView.builder(
      itemCount: favList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.width / (750),
      ),
      shrinkWrap: false,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) =>
          styles.widgetProducts(scaffoldKey,context,isLogin, memberId, currencyExchange, favList,index,'favourite',currencyId),
    );
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: styles.theAppBar(context, theLanguage, isLogin, context.localeString('favourite') , true, false, '0'),
      body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: widgetProductsData(pageId),
              )
            ],
          )
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}