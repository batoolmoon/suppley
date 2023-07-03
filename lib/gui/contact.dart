import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supplyplatform/gui/contact_details.dart';
import 'package:supplyplatform/module/get_data.dart';
import 'package:supplyplatform/module/get_branches.dart';
import 'package:supplyplatform/components/funcs.dart';
import 'package:supplyplatform/components/styles.dart';
import 'package:supplyplatform/components/bottom_navigation_bar.dart';

class Contact extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ContactState();
  }

}

class _ContactState extends State<Contact>{

  late String theLanguage;
  late TextAlign theAlignment;
  bool isLoading = true;

  var branchesList = <GetBranches>[];
  var funcs = Funcs();
  var styles = Styles();

  _getDataList() {
    GetData.getDataList(funcs.mainLink+'api/getBranches/$theLanguage/').then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        branchesList = list.map((model) => GetBranches.fromJson(model)).toList();
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

  @override
  void dispose(){
    super.dispose();
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;

      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
      }else{
        theAlignment = TextAlign.left;
      }

    });
  }
  

  _openContactDetailsPage(String contactId, String branchName){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ContactDetails(contactId.toString(), branchName.toString())));
  }

  Widget widgetBranchesList(){

    return ListView.builder(
      itemCount: branchesList.length,
      itemBuilder: (BuildContext context, int index) =>
      Column(
        children: <Widget>[
          ListTile(
            title: Text(branchesList[index].theBranchName, style: styles.listTileStyle2, textAlign: theAlignment),
            onTap: ()=> _openContactDetailsPage(branchesList[index].coId, branchesList[index].theBranchName),
          ),
          const Divider(),
        ],
      ),
    );

  }


  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return Scaffold(
      appBar: styles.theAppBar(context, theLanguage, true, '' , true, false, '0'),
      body: Container(
        child: widgetBranchesList()
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      bottomNavigationBar: BottomNavigationBarWidget(0),
    );
  }

}
