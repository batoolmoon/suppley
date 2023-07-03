import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';

class About extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AboutState();
  }

}

class _AboutState extends State<About> {

  late String theLanguage;
  String aboutTitle = '';
  String aboutText = '';
  String thePhoto = '';
  late TextAlign theAlignment;
  late TextDirection theDirection;
  bool isLoading = false;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getAboutData(theLanguage).then((result) {
        setState(() {
          aboutTitle = result['aboutData'][0]['theTitle'];
          aboutText = result['aboutData'][0]['theDetails'];
          thePhoto = result['aboutData'][0]['thePhoto'];
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
    var myUrl = Uri.parse(funcs.mainLink+'api/about/$lang');
    http.Response response = await http.get(myUrl, headers: {"Accept": "application/json"});
    try{
      setState(() {
        isLoading = false;
      });
      result =  json.decode(response.body);
    }catch(e){
      print(e);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, theLanguage, true, context.localeString('about') , true, false, '0'),
      body: CustomScrollView(
          slivers:[
            SliverList(
                delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Image.network(

                          funcs.mainLink+'public/uploads/php/files/about/medium/'+thePhoto,
                          fit: BoxFit.contain,

                        ),
                      )
                    ]
                )
            ),

            SliverList(
                delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 10.0,),
                    ]
                )
            ),
            SliverList(
                delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: <Widget>[
                            Text(aboutTitle, textDirection: theDirection, style: styles.paragraphTitle, textAlign: theAlignment),
                            const SizedBox(height: 25.0,),
                            Html(
                                data: aboutText,
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
                      )

                    ]
                )
            ),
          ]
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
    );
  }

}
