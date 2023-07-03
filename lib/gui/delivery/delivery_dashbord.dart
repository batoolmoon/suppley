import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/funcs.dart';
import '../../components/styles.dart';
import '../members/edit_profile.dart';
import 'delivery_drawer.dart';
import 'package:http/http.dart' as http;

import 'delivery_status.dart';


class DeliveryDash extends StatefulWidget {
  const DeliveryDash({Key? key}) : super(key: key);

  @override
  _DeliveryDashState createState() => _DeliveryDashState();
}

class _DeliveryDashState extends State<DeliveryDash> {
  late String theLanguage='en';
  late bool isLogin=true;
  late String deliveryId='';
  String deliveryName='';
  late String deliveryEmail='';
  late String deliveryMobile='';
  late String LogInType='';
  late TextAlign theAlignment;
  late TextDirection theDirection;
  late bool isLoading = true;
  late String notificationsCount='0' ;
  late String pendingOrderNumber='0';
  late String confirmedOrderNumber='0';
  late String shippedOrderNumber='0';
  late String deliveredOrderNumber='0';
  late String canceledOrderNumber='0';
  late String dashClickType='';
  var funcs = Funcs();
  var styles = Styles();
  @override
  @override
  void initState(){
    super.initState();
    getSharedData().then((result) {
      getDeliveryDashboard();
    });

  }

  getDeliveryDashboard()async{
     // styles.onLoading(context);
    setState(() {
      isLoading=true;
    });
      http.post(Uri.parse(funcs.mainLink+'api/getDeliveryDashboard'), body: {
      deliveryId:"deliveryId"}).then((result) async{
        var theResult = json.decode(result.body);
        setState(() {
          pendingOrderNumber=theResult['pending'][0]['pendingOrders'];
          canceledOrderNumber=theResult['canceled'][0]['canceledOrders'];
          deliveredOrderNumber=theResult['delivered'][0]["deliveredOrders"];
          shippedOrderNumber=theResult['shipped'][0]['shippedOrders'];
          confirmedOrderNumber=theResult['confirmed'][0]['confirmedOrders'];
          isLoading=false;
        });

      }).catchError((error) {
        print("error");
      });





  }

  getSharedData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      isLogin = prefs.getBool('isLogin')!;
      deliveryId = prefs.getString('deliveryId')!;
      deliveryName= prefs.getString('deliveryName')!;
      deliveryEmail = prefs.getString('deliveryEmail')!;
      deliveryMobile = prefs.getString('deliveryMobile')!;
      LogInType=prefs.getString('LogInType')!;


      if(theLanguage == 'ar'){
        theAlignment = TextAlign.right;
        theDirection = TextDirection.rtl;
      }else{
        theAlignment = TextAlign.left;
        theDirection = TextDirection.ltr;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  styles.theAppBar(context, theLanguage, isLogin, '', true, true, notificationsCount),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.only(top: 10),
            margin:EdgeInsets.only(top: 20) ,
            decoration: BoxDecoration(
             // color: Colors.black12,
               // borderRadius: BorderRadius.circular(20)
            ),
            width: 200,
            height: 80,
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(deliveryName, style: TextStyle(color: Colors.black), ),
                    SizedBox(width: 10,),
                    GestureDetector(child: Icon(Icons.settings_sharp) , onTap:(){

                      Navigator.push(context,  MaterialPageRoute(builder: (context) =>  EditProfile()));})
                  ],
                ),
                Text(deliveryMobile, style: TextStyle(color: Colors.black), ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: (){
              print("DelName " +deliveryName);
              dashClickType="1";
        Navigator.push(context,  MaterialPageRoute(builder: (context) =>   deliveryStatus(dashClickType)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),

              ),
              color: Colors.white60,
              child: Container(
                margin: EdgeInsets.all(5),
                height: 70,
                decoration:const  BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 40,
                        offset: Offset(8, 15),
                      )
                    ]
                ),
                child: Center(
                  child: ListTile(leading: Container(  height: 40,width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),color: Colors.green,),
                    child: Text(pendingOrderNumber, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20,color: Colors.white),),),
                    title: Text( context.localeString('pending'),style: styles.listTileStyle2),
                    trailing: Icon(Icons.arrow_forward_ios , size: 30, color: Colors.black38,),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              dashClickType="2";
              Navigator.push(context,  MaterialPageRoute(builder: (context) =>  deliveryStatus(dashClickType)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),

              ),
              color: Colors.white60,
              child: Container(
                margin: EdgeInsets.all(5),
                height: 70,
                decoration:const  BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 40,
                        offset: Offset(8, 15),
                      )
                    ]
                ),
                child: Center(
                  child: ListTile(leading: Container(  height: 40,width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),color: Colors.green,),
                    child: Text(confirmedOrderNumber, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20,color: Colors.white),),),
                    title: Text( context.localeString("confirmed_title"),style: styles.listTileStyle2),
                    trailing: Icon(Icons.arrow_forward_ios , size: 30, color: Colors.black38,),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){dashClickType="4";
          Navigator.push(context,  MaterialPageRoute(builder: (context) =>  deliveryStatus(dashClickType)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),

              ),
              color: Colors.white60,
              child: Container(
                margin: EdgeInsets.all(5),
                height: 70,
                decoration:const  BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 40,
                        offset: Offset(8, 15),
                      )
                    ]
                ),
                child: Center(
                  child: ListTile(leading: Container(  height: 40,width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),color: Colors.red,),
                    child:Text(deliveredOrderNumber, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20,color: Colors.white),),) ,
                    title: Text( context.localeString('delivered_title'),style: styles.listTileStyle2),
                    trailing: Icon(Icons.arrow_forward_ios , size: 30, color: Colors.black38,),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              dashClickType="0";
             Navigator.push(context,  MaterialPageRoute(builder: (context) =>  deliveryStatus(dashClickType)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),

              ),
              color: Colors.white60,
              child: Container(
                margin: EdgeInsets.all(5),
                height: 70,
                decoration:const  BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 40,
                        offset: Offset(8, 15),
                      )
                    ]
                ),
                child: Center(
                  child: ListTile(leading: Container(  height: 40,width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),color: Colors.red,),
                    child: Text(canceledOrderNumber, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20,color: Colors.white),),),
                    title: Text( context.localeString('canceled_title'),style: styles.listTileStyle2),
                    trailing: Icon(Icons.arrow_forward_ios , size: 30, color: Colors.black38,),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              dashClickType="3";
              Navigator.push(context,  MaterialPageRoute(builder: (context) => deliveryStatus(dashClickType)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),

              ),
              color: Colors.white60,
              child: Container(
                margin: EdgeInsets.all(5),
                height: 70,
                decoration:const  BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 40,
                        offset: Offset(8, 15),
                      )
                    ]
                ),
                child: Center(
                  child: ListTile(leading: Container(  height: 40,width: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),color: Colors.yellow,),
                    child: Text(shippedOrderNumber, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20,color: Colors.white),),),
                    title: Text( context.localeString('shipped_title'),style: styles.listTileStyle2),
                    trailing: Icon(Icons.arrow_forward_ios , size: 30, color: Colors.black38,),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isLoading == true ? styles.loadingPage(context):Container(),
      drawer: deliveryDrawerClass(true),);
  }

}
