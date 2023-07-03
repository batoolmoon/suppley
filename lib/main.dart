import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplyplatform/gui/welcome.dart';
import 'package:provider/provider.dart';
import 'package:supplyplatform/gui/stores.dart';
import 'package:supplyplatform/gui/home.dart';
import 'package:supplyplatform/gui/main_page.dart';
import 'package:supplyplatform/gui/products/products.dart';
import 'package:supplyplatform/gui/members/login.dart';
import 'package:supplyplatform/gui/members/register.dart';
import 'package:supplyplatform/gui/about.dart';
import 'package:supplyplatform/gui/orders/orders.dart';
import 'package:supplyplatform/gui/settings.dart';
import 'package:supplyplatform/gui/products/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supplyplatform/gui/notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supplyplatform/gui/orders/my_store.dart';
import 'package:supplyplatform/components/styles.dart';

import 'gui/delivery/delivery_dashbord.dart';
import 'gui/stores/store_dashboard.dart';




const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
  'default_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
  showBadge: true,
  playSound: true,
//    sound: RawResourceAndroidNotificationSound('default_sound')
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
//  print(message.data['android_channel_id']);
//  print(message.data['sound']);
//  print('A bg message just showed up :  ${message.messageId}');

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);


}


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
//  await Locales.init(['ar', 'en']); //
  await Locales.init(['ar', 'en']); //

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);


  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
      ChangeNotifierProvider(
        create: (_){
          return MyStore();
        },
        child: const MaterialApp(
          home: MyApp(),
        ),
      )
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp>{

  late Widget _screen;
  late Home _home;
  late Welcome _welcome;
  late StoreDashboard _storeDashBord;
  late DeliveryDash _deliveryDash;
  late String theLanguage = 'en';
  late Login _login;
  late String LogInType = '';

  var styles = Styles();

  @override
  void initState(){
    super.initState();



    _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = const InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print('CCCCC');
      if (message != null) {
        Navigator.pushNamed(context,'Notifications');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data['body']);
      print('xxxxx');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  defaultChannel.id,
                  defaultChannel.name,
//                color: Colors.green,
//                enableVibration: true,
                  playSound: true,
//                  sound: const RawResourceAndroidNotificationSound('default_sound'),
                  //icon: '@mipmap/noti_icon',
                  priority: Priority.high,
                  importance: Importance.max
              ),

            ));
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        //Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications()),);
//        showDialog(
//            context: context,
//            builder: (_) {
//              return AlertDialog(
//                title: Text('1111'),
//                content: SingleChildScrollView(
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [Text('222')],
//                  ),
//                ),
//              );
//            });
      }
    });

    getSharedData().then((result){
      if(theLanguage != 'ar' || theLanguage != 'en'){
        theLanguage = 'en';
      }
    });

    ///
    /// Let's save a pointer to this method, should the user wants to change its language
    /// We would then call: applic.onLocaleChanged(new Locale('en',''));
    ///


  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
  }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;
      LogInType = prefs.getString('LogInType')!;

      if(theLanguage == 'ar' || theLanguage == 'en'){
        if(LogInType == 'store' ||LogInType == "factory"){

          _storeDashBord = StoreDashboard() ;
          _screen = _storeDashBord;
        }
        else if(LogInType == "delivery_company"){
          _deliveryDash=DeliveryDash();
          _screen =_deliveryDash;
        }

        else {
          _login = Login();
          _screen = _login;
        }

        if  (LogInType == 'shop'){
          _welcome = Welcome();
          _screen = _welcome;
        }



      }else{
        _home = Home();
        _screen = _home;
      }

    });
  }

  _MyAppState(){
    _home = Home();
    _screen = _home;
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return LocaleBuilder(

      builder: (locale)=> MaterialApp(
        theme: ThemeData(
            fontFamily: 'Cairo',
            primaryColor: const Color.fromRGBO(0, 0, 50, 1),
            scaffoldBackgroundColor: Colors.white,
            secondaryHeaderColor: const Color.fromRGBO(254, 197, 2, 1),
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              elevation: 1,
              shadowColor: Colors.black,
              centerTitle: true,
              actionsIconTheme: IconThemeData(
                color: Colors.white,
              ),
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
            ),
            textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 16.0, color: Color.fromRGBO(0, 0, 51, 1)), // for appBar
              headline2: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17.0), // for titles
              bodyText1: TextStyle(color: Colors.black87, fontSize: 16.0), // for normal text

              button: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
            dividerTheme: const DividerThemeData(
              thickness: 0.3,color: Colors.black38,
            )
        ),

        debugShowCheckedModeBanner: true,
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
debugShowMaterialGrid: false,
        title: 'Supply App',
        routes: <String, WidgetBuilder>{
          '/MainPage': (BuildContext context) => const MainPage(),
          '/Home': (BuildContext context) => Home(),
          '/Login': (BuildContext context) => Login(),
          '/Register': (BuildContext context) => Register(),
          '/About': (BuildContext context) => About(),
          '/Orders': (BuildContext context) => Orders(),
          '/Settings': (BuildContext context) => const Settings(),
          '/Stores': (BuildContext context) => const Stores(),
          //'/StoreOrders': (BuildContext context) => StoreOrders(),
          '/Notifications': (BuildContext context) => Notifications(),
          '/Products': (BuildContext context) => Products('categoryId','categoryTitle','theType',''),
          '/ProductDetails': (BuildContext context) => ProductDetails('productId'),
          '/StoreDashboard': (BuildContext context) => const StoreDashboard(),
          '/DeliveryDash':(BuildContext context) => const DeliveryDash(),
        },
        home: _screen,
      ),
    );
  }

}
