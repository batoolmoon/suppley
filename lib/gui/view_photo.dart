import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:photo_view/photo_view.dart';

import '../components/funcs.dart';



class ViewPhoto extends StatefulWidget{
  ViewPhoto(this.thePhotoName, this.theType);
  String thePhotoName;
  String theType;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewPhotoState(thePhotoName, theType);
  }

}

class _ViewPhotoState extends State<ViewPhoto> {
  _ViewPhotoState(this.thePhotoName, this.theType);
  String thePhotoName;
  String theType;

  var funcs = Funcs();

  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(funcs.mainLink+"public/uploads/php/files/$theType/medium/$thePhotoName"),
              initialScale: PhotoViewComputedScale.contained * 0.9,
              maxScale: 4.0,
//              imageProvider: AssetImage('images/logo.png'),
//            minScale: ,
            )
        )
    );
  }

}
