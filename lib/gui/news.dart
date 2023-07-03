import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:supplyplatform/gui/new_details.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_news.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/drawer.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';

class News extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _NewsState();
  }

}

class _NewsState extends State<News>{

  late String theLanguage;
  late String fullName = '';
  late bool isLogin = false;
  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  var newsList = <GetNews>[];
  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getNews/$theLanguage').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        newsList = list.map((model) => GetNews.fromJson(model)).toList();
        isLoading = false;
      });
    });
  }

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      _getDataList();
    });
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        isLogin = prefs.getBool('isLogin')!;
        fullName = prefs.getString('fullName')!;
        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }
  }

  _openNewsDetailsPage(String newsId){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NewsDetails(newsId.toString())));
  }

  Widget getNewsList(){

    return ListView.builder(
      itemCount: newsList.length,
      itemBuilder: (BuildContext context, int index) =>
          Container(
            width: double.infinity,
            color: Colors.transparent,
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: ()=> _openNewsDetailsPage(newsList[index].neId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Column(
                        children: <Widget>[
                          newsList[index].thePhoto != '' ? ClipRRect(
                            borderRadius: BorderRadius.circular(13.0),
                            child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: funcs.mainLink+"public/uploads/php/files/news/thumbnail/${newsList[index].thePhoto}"),
                          ):Container(),
                          const Padding(padding: EdgeInsets.only(top: 10.0)),
                          Container(
                            child: Text(newsList[index].theTitle, style: Theme.of(context).textTheme.headline2, textAlign: theAlignment),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 20.0)),
                          Divider(),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, theLanguage, false, context.localeString('news'), true, false, '0'),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: newsList.isNotEmpty || isLoading == true ? getNewsList():
        Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Image.asset(
                'images/nodatafound.png',
                width: 200.0,
              ),
              Text(context.localeString('no_data')),
            ],
          ),
        ),
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(3),
      drawer: DrawerClass(isLogin, fullName),
    );
  }

}