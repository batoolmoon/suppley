import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/funcs.dart';


class Welcome extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WelcomeState();
  }

}



class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin{

  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;


  late String theLanguage;
  late TextAlign theAlignment;
  late String welcomeTitle;
  bool isLoading = true;

  var funcs = Funcs();

  late Timer _timer;
  int _start = 3;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -2.4),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));

    startTimer();
    getSharedData().then((result) {
    });

  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
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

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
            if(_start == 0){
                  Navigator.of(context).pushNamedAndRemoveUntil('/MainPage',(Route<dynamic> route) => false);
            }
            if(_start == 1){
              _controller.forward();
            }
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'images/whiteLogo.png',
                width: 150.0,
              )
          ),
        ),
      )
    );
  }
}
