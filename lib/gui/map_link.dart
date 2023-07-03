import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_locales/flutter_locales.dart';

class MapLinks extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MapLinksState();
  }

}

class _MapLinksState extends State<MapLinks> {
  Set<Marker> _markers = {};
  late String theLanguage;

  late String currentLatitude;
  late String currentLongitude;
  late LatLng myCurrentPosition = const LatLng(0.0,0.0);

  @override
  void initState(){

    _determinePosition();

    super.initState();
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    final geolocator = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLatitude = '${geolocator.latitude}';
      currentLongitude = '${geolocator.longitude}';
      myCurrentPosition = LatLng(double.parse(currentLatitude),double.parse(currentLongitude));
      _markers.add(
          Marker(
            markerId: MarkerId("${geolocator.latitude},${geolocator.longitude}"),
            position: LatLng(geolocator.latitude,geolocator.longitude),
            icon: BitmapDescriptor.defaultMarker,

          )
      );
    });

    return await Geolocator.getCurrentPosition();
  }




  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;

    });
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(context.localeString('select_location_title'), style: Theme.of(context).textTheme.headline1,),
        ),
        body: Column(
          children: [
            Expanded(
              child: myCurrentPosition.latitude > 0.0 ? GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: myCurrentPosition,
                  zoom: 14,
                ),
                markers: _markers,
                onTap: (position){
                  setState(() {
                    _markers = {};
                    currentLatitude = "${position.latitude}";
                    currentLongitude = "${position.longitude}";
                    _markers.add(
                        Marker(
                          markerId: MarkerId("${position.latitude},${position.longitude}"),
                          position: position,
                          icon: BitmapDescriptor.defaultMarker,
                        )
                    );
                  });
                },
              ):Container(),
            ),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0 ),
                  elevation: 0.0,
                  primary: Colors.red,),
                //todo shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0), topRight: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),

                onPressed: (){
                  print(currentLatitude);
                  print(currentLongitude);
                },

                child: Text(context.localeString('No'),style: Theme.of(context).textTheme.button, textAlign: TextAlign.center),

              ),
            )
          ],
        )
    );
  }

}
