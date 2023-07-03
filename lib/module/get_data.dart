import 'dart:async';
import 'package:http/http.dart' as http;

class GetData {
  static Future getDataList(String theLink) {
    var url = Uri.parse(theLink);
    return http.get(url);
  }
}