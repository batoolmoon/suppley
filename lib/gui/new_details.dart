import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';


class NewsDetails extends StatefulWidget{
  NewsDetails(this.newsId);
  String newsId;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _NewsDetailsState(newsId);
  }

}

class _NewsDetailsState extends State<NewsDetails>{
  _NewsDetailsState(this.newsId);
  late String newsId;

  late String newsTitle = '';
  late String newsPhoto  = '';
  late String newsDetails  = '';
  late String newsLink  = '';
  late String theLanguage;
  late String memberId;
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();


  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getData().then((result) {
        setState(() {
          newsTitle = result['newsDetails'][0]['theTitle'];
          newsPhoto = result['newsDetails'][0]['thePhoto'];
          newsDetails = result['newsDetails'][0]['theDetails'];
          newsLink = result['newsDetails'][0]['theLink'];
        });
      });
    });

  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      memberId = prefs.getString('memberId')!;
      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }
    });
  }


  Future<Map> getData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/getNewsDetails/$theLanguage/$newsId/$memberId');
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


  void _openLink(String theLink) async{
    await launch(theLink);
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
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: styles.theAppBar(context, theLanguage, false, newsTitle, true, false, '0'),
        body: ListView(
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            newsPhoto != '' ? Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.0),
                child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: funcs.mainLink+"public/uploads/php/files/news/thumbnail/$newsPhoto"),
              ),
            ):Container(),
            Container(
              padding: const EdgeInsets.all(15.0),
              child: Html(
                  data: newsDetails,
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
            newsLink != null ? ListTile(
              title: Text(newsLink, textDirection: theDirection, style: Theme.of(context).textTheme.bodyText1, textAlign: theAlignment),
              onTap: ()=> _openLink(newsLink),
            ):Container(),

          ],
        ),
        floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      ),
    );
  }

}