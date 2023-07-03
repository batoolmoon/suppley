import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/funcs.dart';
import '../components/styles.dart';


class TextData extends StatefulWidget{
  TextData(this.theType);
  String theType;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TextDataState(theType);
  }

}

class _TextDataState extends State<TextData> {
  _TextDataState(this.theType);
  late String theType;
  late String theLanguage="en";
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
      getAboutData(theLanguage).then((result) {
        setState(() {
          textdataTitle = result['textData'][0]['theTitle'];
          textdataText = result['textData'][0]['theDetails'];
        });
      });
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

  Future<Map> getAboutData(String lang) async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/textdata/$theType/$lang');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result = json.decode(response.body);
    }catch(e){
      print(e);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, theLanguage, false, textdataTitle, true, false, '0'),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
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
          const SizedBox(height: 125.0,),
        ],
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
    );
  }

}
