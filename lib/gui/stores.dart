import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/module/get_stores.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/drawer.dart';

class Stores extends StatefulWidget{

  const Stores ({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return  _StoresState();
  }

}

class _StoresState extends State<Stores>{
  _StoresState();

  late String memberId;
  late String fullName = '';
  late String theLanguage='en';
  late int currencyId;
  late double currencyExchange;
  late TextAlign theAlignment;
  late TextDirection theDirection;
  late bool isLoading = true;
  late bool isLogin = false;
  late int pageId = 1;
  late String user;
  String userkind = 'please_select';
  var kindRegister = [
    'please_select',
    'factory',
    'delivery_company'
  ];
//var uss=["store"];
  late String notificationsCount = '0';

  var funcs = Funcs();
  var styles = Styles();

  late String searchQuery = '';
  final TextEditingController _getSearch = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var storesList = <GetStores>[];
 var filterStore= <GetStores>[];
  GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

 // get newValue => null
  List FilterStore(String value){
          if (value=='please_select'){
            print('i in select');
            return storesList;
                              }
          else if (value=='delivery_company'){
            print('i in delivery');
          return storesList.where((store) => store.theType=='delivery_company').toList();
                               }
          else {
            print('i in factory');
            print(storesList.where((store) => store.theType=='factory').toList());

            return storesList.where((store) => store.theType=='factory').toList();
          }


          }


  @override
  void initState(){
 //   print("list");
   // print(storesList);
    super.initState();
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      _getStoresDataList();
    });

    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        pageId = pageId + 1;
        setState(() {
          isLoading = true;
          _getStoresDataList();
        });
      }
    });

  }

  @override
  void dispose(){
    super.dispose();
  }


  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  _getStoresDataList() async{

    setState(() {isLoading = true;});

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
          print ("my list with indeex ");
           print (storesList[0]);
           print(pageId);

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
      fullName = prefs.getString('fullName')!;
      currencyId = prefs.getInt('currencyId')!;
      currencyExchange = prefs.getDouble('currencyExchange')!;
      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }

    });
  }

  Widget searchSection(){
    return Container(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 0.0, bottom: 0.0),
      margin: const EdgeInsets.only(top: 10.0, bottom: 5.0, left: 5.0, right: 5.0),
      width: double.infinity,
      height: 42.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
    /*Container(
        padding: EdgeInsets.only(top: 5),
        alignment: Alignment.topCenter,
        height: 40,width: 90,
        decoration:const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
               color: Colors.white70,
           boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 40,
            offset: Offset(8, 15),
          )
        ]
          ) ,
        child: DropdownButton(
          underline: Container(),
          isExpanded: true,
          dropdownColor: Colors.white,
          value: userkind,
          items: kindRegister.map((String kind) {
            return DropdownMenuItem(

              alignment: Alignment.center,
              value: kind,
              child: Center(
                  child: Text(
                    context.localeString(kind).toString(),
                    style: const TextStyle(
                      color: Color.fromRGBO(0, 0, 51, 1),
                      fontSize: 20,
                    ),
                  )),
            );
          }).toList(),
        onChanged: (String? value) {
    setState(() {
    userkind = value!;
    FilterStore(userkind);
    });
    },
        ),

        ),*/
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),

            onPressed: () {
              showModalBottomSheet(context: context,


                  builder: (BuildContext context)
            {return Container( padding: EdgeInsets.only(top: 5),
              alignment: Alignment.topCenter,
              height: 40,width: 90,
              decoration:const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white70,
                  // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 40,
            //     offset: Offset(8, 15),
            //   )
            // ]
            ) ,
           child: DropdownButton(

              borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
            underline: Container(),
            isExpanded: true,
            dropdownColor: Colors.white,//.fromRGBO(194, 171, 131, 1),

                value: userkind,
                items: kindRegister.map((String kind) {
                  return DropdownMenuItem(

                    alignment: Alignment.center,
                    value: kind,
                    child: Center(
                        child: Text(
                          context.localeString(kind).toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        )),
                  );
                }).toList(),
                onChanged: (String? Newvalue) {
                  setState(() {
                    userkind = Newvalue!;
                     FilterStore(userkind);
                  });
                },
              ),
            );} );  }, child: Icon(Icons.filter_alt_outlined,color: Color.fromRGBO(194, 171, 131, 1),),),
         SizedBox(width: 3,),
          Expanded(
            child: TextField(
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
                    _getStoresDataList();
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
      ),
    );
  }

  needToRefresh(){
    setState(() {
      _getStoresDataList();    });

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
        appBar: styles.theAppBar(context, theLanguage, isLogin, '', true, true, notificationsCount),
        body: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const ClampingScrollPhysics(),
            controller: _scrollController,
            slivers: <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate([
                    searchSection(),
                    const Divider(),
                  ])
              ),

              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width/3 ,
                  childAspectRatio: MediaQuery.of(context).size.width / (400),
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 3.0,
                ),
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {

                          return styles.widgetStores(scaffoldKey,context, FilterStore(userkind),index);},

                  childCount:FilterStore(userkind).length,
                ),
              )
            ]
        ),
        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(1),
        drawer: DrawerClass(isLogin, fullName),
      ),
    );
  }
}
