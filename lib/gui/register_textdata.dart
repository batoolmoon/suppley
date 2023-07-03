import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:flutter_locales/flutter_locales.dart';

class RegisterTextData extends StatefulWidget{
  RegisterTextData(this.theType);
  String theType;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RegisterTextDataState(theType);
  }

}

class _RegisterTextDataState extends State<RegisterTextData> {
  _RegisterTextDataState(this.theType);
  late String theType;
  late String theLanguage;
  late String textdataTitle = '';
  late String textdataText = '';
  late TextAlign theAlignment;
  late TextDirection theDirection;
  late bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getAboutData();
    });
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }
    });
  }

  Future<Map> getAboutData() async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/textdata/$theType/$theLanguage');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);

      textdataTitle = result['textData'][0]['theTitle'];
      textdataText = result['textData'][0]['theDetails'];

      setState(() {});

    }catch(e){
      print(e);
    }

    return result;
  }

  Widget widgetTopTabsList(){

    return Container(
      child: Row(
        children: [
          Container(
            height: 50.0,
            margin: const EdgeInsets.only(right: 0.0, left: 0.0),
            child: TextButton(
              onPressed: (){
                setState(() {
                  theType = 'privacy';
                });
                getAboutData();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 2.0, bottom: 2.0  ),
              ),
              child: Text(context.localeString('privacy_policy'), style: theType == 'privacy' ? styles.activeWhiteTabsTitle : styles.whiteTabsTitle, textAlign: TextAlign.center),
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 3.0, color: theType == 'privacy' ? Theme.of(context).primaryColor : Colors.transparent),
              ),
            ),
          ),
          Container(
            height: 50.0,
            margin: const EdgeInsets.only(right: 0.0, left: 0.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 3.0, color: theType == 'terms_and_conditions' ? Theme.of(context).primaryColor : Colors.transparent),
              ),
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 2.0, bottom: 2.0 ),
              ),
              onPressed: (){
                setState(() {
                  theType = 'terms_and_conditions';
                });
                getAboutData();
              },

              child: Text(context.localeString('terms_and_conditions'), style: theType == 'terms_and_conditions' ? styles.activeWhiteTabsTitle : styles.whiteTabsTitle, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, theLanguage, false, '' , true, false, ''),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: <Widget>[
            widgetTopTabsList(),
            const SizedBox(height: 10.0,),
            Html(
                data: textdataText,
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
//          const SizedBox(height: 125.0,),
          ],
        ),
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
    );
  }

}
