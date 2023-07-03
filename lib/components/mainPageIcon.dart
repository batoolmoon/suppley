import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class homeIcon extends StatelessWidget {
  const homeIcon({Key? key, required this.homeicons, required this.iconword}) : super(key: key);
  final IconButton homeicons;
  final String iconword;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       // SizedBox(width:MediaQuery.of(context).size.width-265 ,),
        Container(
          width: 60.0,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color.fromRGBO(194, 171, 131, 1),
        ),
        child: homeicons,
        ),
        Text(iconword,style: TextStyle(fontWeight: FontWeight.bold , color: Color.fromRGBO(0, 0, 51, 1),fontSize: 15),)
      ],
    );
  }
}
