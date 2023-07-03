import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';
import 'package:supplyplatform/components/drawer.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_products.dart';
import 'package:supplyplatform/module/get_categories.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/gui/store_details.dart';

class Products extends StatefulWidget{
  Products(this.storeId, this.storeName, this.theType, this.search, {Key? key}): super(key: key);

  String storeId;
  String storeName;
  String theType;
  String search;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductsState(storeId,storeName,theType,search);
  }

}

class _ProductsState extends State<Products>{
  _ProductsState(this.storeId, this.storeName, this.theType,this.search);
  String storeId;
  String storeName;
  String theType;
  String search;



  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late String listType = 'products';
  late String memberId='';
  late String fullName=' ';

  late String theLanguage='en';
  late bool isLogin=false;
  late int currencyId=1;
  late double currencyExchange=1;
  late TextAlign theAlignment=TextAlign.right;
  late bool isLoading = true;
  late String categoryId = '0';
  late String mainCategoryId = '0';
  late String notificationsCount = '0';
//late String isFav;
  int pageId = 1;
  var funcs = Funcs();
  var styles = Styles();

  final ScrollController _scrollController = ScrollController();

  late String searchQuery = '';
  final TextEditingController _getSearch = TextEditingController();

  var productsList = <GetProducts>[];
  var categoriesList = <GetCategories>[];
  var subCategoriesList = <GetCategories>[];

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getUnreadNotificationsCount();
      _getDataList();
      _getCategoriesDataList();
    });
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        pageId = pageId + 1;
        setState(() {
          isLoading = true;
          _getDataList();
        });
      }
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
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
        currencyId = prefs.getInt('currencyId')!;
        currencyExchange = prefs.getDouble('currencyExchange')!;
        //isFav=prefs.getString('isFav')!;

        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }

  }



  _getCategoriesDataList() {
    GetData.getDataList(funcs.mainLink+'api/getCategories/$theLanguage/$storeId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        categoriesList = list.map((model) => GetCategories.fromJson(model)).toList();
        isLoading = false;
      });
    });

  }

  _getSubCategoriesDataList(String categoryTitle) {
    styles.onLoading(context);
    GetData.getDataList(funcs.mainLink+'api/getSubCategories/$theLanguage/$storeId/$categoryId').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        subCategoriesList = list.map((model) => GetCategories.fromJson(model)).toList();
        Navigator.of(context, rootNavigator: true).pop();
        subCategorySheet(context,categoryTitle);
      });
    });
  }

  _getDataList() async{
    isLoading = true;
    setState(() {});

    //TODO replace the url bellow with you ipv4 address in ipconfig
    var myUrl = Uri.parse(funcs.mainLink + 'api/getProducts');

    var request = http.MultipartRequest('POST', myUrl);

    if(search != ''){
      // from store main page
      searchQuery = search;
    }

    request.fields.addAll({
      "theLanguage": theLanguage,
      "storeId":storeId,
      "categoryId":categoryId,
      "theType":listType,
      "currencyId":currencyId.toString(),
      "pageId": pageId.toString(),
      "searchQuery" : searchQuery,
      "memberId":memberId,
      //"isFav":isFav,
    });
    var response = await request.send();
    http.Response.fromStream(response).then((onValue) {
      try {
        var theResult = json.decode(onValue.body);

        if(theResult['resultFlag'] == 'done'){
          Iterable list = theResult['theData'];
          productsList = list.map((model) => GetProducts.fromJson(model)).toList();
          isLoading = false;
          setState(() {});
        }else{
          styles.showSnackBar(scaffoldKey,context,context.localeString('error_occurred'),'error','');
        }

      } catch (e) {
        // handle exeption
      }
    });
  }


  getUnreadNotificationsCount() async{
    if(isLogin == true){
      notificationsCount = await funcs.getUnreadNotificationsCount();
      setState(() {});
    }
  }

  _getProductsByCategory(String theCategoryId,  int parentCategoryCount, String categoryTitle, String theListType){

      categoryId = theCategoryId;
      mainCategoryId = theCategoryId;
      listType = theListType;

      if(parentCategoryCount == 0){
        _getDataList();

      }else{
        _getSubCategoriesDataList(categoryTitle);
      }

      setState(() {});
  }

  Widget widgetSubCategories(context, categoriesList, index){

    return Column(
      children: [
        index == 0 ? ListTile(
          title: Text(Locales.string(context, 'all'), style: styles.listTileStyle2, textAlign: TextAlign.center),
          onTap: () {
            Navigator.pop(context);
            _getProductsByCategory(subCategoriesList[index].parentCategoryId, 0, subCategoriesList[index].theTitle, 'allSubCategories');
            // for active main tab
            mainCategoryId = subCategoriesList[1].parentCategoryId;
          },
        ):Container(),
        index == 0 ? const Divider() : Container(),

        ListTile(
          title: Text(categoriesList[index].theTitle, style: styles.listTileStyle2, textAlign: TextAlign.center),
          onTap: () {
            Navigator.pop(context);
            _getProductsByCategory(subCategoriesList[index].caId, 0, subCategoriesList[index].theTitle,'products');
            // for active main tab
            mainCategoryId = subCategoriesList[0].parentCategoryId;

            print(mainCategoryId);
          },
        ),
        const Divider()
      ],
    );
  }

  void subCategorySheet(context, String categoryTitle){

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
                  title: Text(categoryTitle, style: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Cairo', fontSize: 17.0,), textAlign: TextAlign.center),
                ),
                const Divider(),
                Container(
                    margin: const EdgeInsets.only(bottom: 0.0),
                    height: 200.0,
                    width: double.infinity,
                    child: ListView.builder(
                        itemCount: subCategoriesList.length,
                        itemBuilder: (BuildContext context, int index){
                          return widgetSubCategories(context, subCategoriesList, index);
                        }
                    )
                )
              ],
            ),
          );
        }
    );
  }


  Widget widgetCategoriesList(){

    return ListView.builder(
      itemCount: categoriesList.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: false,
      itemBuilder: (BuildContext context, int index) =>
      index == 0 ? Row(
        children: [
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(right: 5.0, left: 5.0),
            child: TextButton(
              onPressed: ()=> _getProductsByCategory('0',0,context.localeString('all'),'products'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 2.0, bottom: 2.0 ),

              ),

              child: Text(context.localeString('all'), style: TextStyle(color: mainCategoryId == '0' ?  Theme.of(context).primaryColor : Color.fromRGBO(194, 171, 131, 1), fontSize: 14.0), textAlign: TextAlign.center),
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2.0, color: mainCategoryId == '0'? Theme.of(context).primaryColor : Colors.transparent),
              ),
              color: Colors.white,
            ),
          ),
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(right: 0.0, left: 0.0),
            child: TextButton(
              onPressed: (){
                _getProductsByCategory(categoriesList[index].caId,int.parse(categoriesList[index].parentCategoriesCount), categoriesList[index].theTitle,'products');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 2.0, bottom: 2.0 ),

              ),

              child: int.parse(categoriesList[index].parentCategoriesCount) > 0 ?  Row(
                children: [
                  Text(categoriesList[index].theTitle, style: TextStyle(color: mainCategoryId == categoriesList[index].caId ?Theme.of(context).primaryColor : Color.fromRGBO(194, 171, 131, 1), fontSize: 14.0), textAlign: TextAlign.center),
                  const SizedBox(width: 10.0,),
                  Icon(Icons.arrow_drop_down, color:Color.fromRGBO(194, 171, 131, 1) ,),
                ],
              ):Text(categoriesList[index].theTitle, style: TextStyle(color: mainCategoryId == categoriesList[index].caId ?  Theme.of(context).primaryColor : Color.fromRGBO(194, 171, 131, 1), fontSize: 14.0), textAlign: TextAlign.center),
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2.0, color: mainCategoryId == categoriesList[index].caId ? Theme.of(context).primaryColor : Colors.transparent),
              ),
              color: Colors.white,
            ),
          )
        ],
      ): Container(
        height: 30.0,
        margin: const EdgeInsets.only(right: 5.0, left: 5.0),
        child: TextButton(
          onPressed: (){
            _getProductsByCategory(categoriesList[index].caId,int.parse(categoriesList[index].parentCategoriesCount),categoriesList[index].theTitle,'products');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 2.0, bottom: 2.0 ),

          ),

          child: int.parse(categoriesList[index].parentCategoriesCount) > 0 ?  Row(
            children: [
              Text(categoriesList[index].theTitle, style: TextStyle(color: mainCategoryId == categoriesList[index].caId ?  Theme.of(context).primaryColor : Color.fromRGBO(194, 171, 131, 1), fontSize: 14.0), textAlign: TextAlign.center),
              const SizedBox(width: 10.0,),
              Icon(Icons.arrow_drop_down, color: Color.fromRGBO(194, 171, 131, 1),),
            ],
          ):Text(categoriesList[index].theTitle, style: TextStyle(color: mainCategoryId == categoriesList[index].caId ? Theme.of(context).primaryColor : Color.fromRGBO(194, 171, 131, 1), fontSize: 14.0), textAlign: TextAlign.center),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom:  BorderSide(width: 2.0, color: mainCategoryId == categoriesList[index].caId ? Theme.of(context).primaryColor : Colors.transparent),
          ),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget searchSection(){
    return Container(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 0.0, bottom: 0.0),
      margin: const EdgeInsets.only(top: 10.0, bottom: 5.0, left: 5.0, right: 5.0),
      width: double.infinity,
      height: 42.0,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              expands: false,
              autocorrect: false,
              style: const TextStyle(color: Colors.black87, height: 1.0, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderRadius:BorderRadius.circular(7.0)),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                suffixIcon: IconButton(
                  onPressed:() {
                    // if searched
                    _getSearch.text = '';
                    searchQuery = '';
                    _getDataList();
                    setState(() {

                    });
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
                  _getDataList();
                }
              },
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget widgetProductsData(int pageId){

    return GridView.builder(
      itemCount: productsList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //TODO 1
        childAspectRatio: MediaQuery.of(context).size.width / (690),
      ),
      shrinkWrap: false,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) =>
          styles.widgetProducts(scaffoldKey,context, isLogin, memberId, currencyExchange, productsList,index,'products', currencyId),
    );
  }


  needToRefresh(){
    setState(() {
      _getSearch.text = '';
      _getDataList();
    });
  }


  Future<bool> _onWillPop() async{
    if (Navigator.canPop(context)) {
      Navigator.pop(context,true);
      return false;
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        appBar: styles.theAppBar(context, theLanguage, isLogin, storeName , true, true, notificationsCount),
        body: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: searchSection(),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: GestureDetector(
                      child: Icon(Icons.store, color: Color.fromRGBO(194, 171, 131, 1),),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StoreDetails(storeId)),);
                      },
                    ),
                  )
                ],
              ),
              int.parse(storeId) > 0 || categoriesList.isNotEmpty ? Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                height: 40.0,
                child: widgetCategoriesList(),
              ):Container(),
              Expanded(
                child: widgetProductsData(pageId),
              )
            ],
          )
        ),
        floatingActionButton : isLoading == true ? styles.loadingPage(context):Container(),
        bottomNavigationBar: BottomNavigationBarWidget(1),
        drawer: DrawerClass(isLogin, fullName),
      ),
    );
  }

}