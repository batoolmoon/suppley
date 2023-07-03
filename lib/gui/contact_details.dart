import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';

class ContactDetails extends StatefulWidget{
  ContactDetails(this.contactId, this.branchName);
  String contactId;
  String branchName;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ContactDetailsState(contactId, branchName);
  }

}

class _ContactDetailsState extends State<ContactDetails> {
  _ContactDetailsState(this.contactId, this.branchName);
  String contactId;
  String branchName;
  late String theLanguage;
  String theAddress = '';
  String phoneNumber = '';
  String emailAddress = '';
  String website = '';
  String facebook = '';
  String instagram = '';
  String twitter = '';
  late TextAlign theAlignment;
  bool isLoading = true;

  var funcs = Funcs();
  var styles = Styles();

  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getContactData(theLanguage).then((result) {
        setState(() {
          theAddress = result['contactData'][0]['theAddress'];
          phoneNumber = result['contactData'][0]['phoneNumber'];
          emailAddress = result['contactData'][0]['emailAddress'];
          website = result['contactData'][0]['website'];
          facebook = result['contactData'][0]['facebook'];
          instagram = result['contactData'][0]['instgram'];
          twitter = result['contactData'][0]['twitter'];
        });
      });
    });
  }


  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted){
      setState(() {
        theLanguage = prefs.getString('theLanguage')!;
        if(theLanguage == 'ar'){
          theAlignment = TextAlign.right;
        }else{
          theAlignment = TextAlign.left;
        }
      });
    }
  }

  Future<Map> getContactData(String lang) async{
    setState(() {
      isLoading = true;
    });
    var result;
    var myUrl = Uri.parse(funcs.mainLink+'api/contactus/$lang/$contactId');
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
      appBar: styles.theAppBar(context, theLanguage, true, '' , true, false, '0'),
      body: isLoading == false ? ListView(
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
          const SizedBox(height: 10.0,),
          ListTile(
            title: Text(context.localeString('address'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(theAddress, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
          ),
          const Divider(),
          ListTile(
            title: Text(context.localeString('phone_number'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(phoneNumber, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> styles.makeCall(phoneNumber),
          ),
          const Divider(),

          emailAddress != null && emailAddress != ''?
      ListTile(
            title: Text(context.localeString('email_address'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(emailAddress, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> styles.openEmail(emailAddress),
           ):Container()
           ,
          emailAddress != null && emailAddress != ''? const Divider():Container()
        ,

          website != null && website != '' ? ListTile(
            title: Text(context.localeString('website'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(website, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> styles.openLink(website),
          ):Container(),
          website != null && website != '' ? const Divider():Container(),

          facebook != null && facebook != '' ? ListTile(
            title: Text(context.localeString('facebook'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(facebook, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> styles.openLink(facebook),
          ):Container(),
          facebook != null && facebook != '' ? const Divider():Container(),
//
          instagram != null && instagram != ''? ListTile(
            title: Text(context.localeString('instagram'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(instagram, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> styles.openLink(instagram),
          ):Container(),
          instagram != null && instagram != '' ? const Divider():Container(),

          twitter != null && twitter != '' ? ListTile(
            title: Text(context.localeString('twitter'), textDirection: TextDirection.ltr, style: styles.listTileTitleStyle, textAlign: theAlignment),
            subtitle: Text(twitter, textDirection: TextDirection.ltr, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> styles.openLink(twitter),
          ):Container(),
          const SizedBox(height: 125.0,),
        ],
      ):Container(),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(0),
    );
  }

}