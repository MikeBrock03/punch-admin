import 'dart:async';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import '../../../config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';


class MiniMap extends StatefulWidget {
  
  final location;
  
  MiniMap({ this.location });
  
  @override
  _MiniMapState createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {

  MapboxMapController mapController;
  bool isMapVisible = false;
  LatLng pinLocation;

  @override
  void initState() {
    super.initState();
    
    if(widget.location != null){
      List<String> res = widget.location.toString().split(',');
      pinLocation = LatLng(double.parse(res[0]), double.parse(res[1]));
    }
    
  }
  
  @override
  Widget build(BuildContext context) {
    return mapContainer();
  }
  
  Widget mapContainer(){

    LatLng center = pinLocation != null ? pinLocation : LatLng(35.434776, -97.661731);

    return Container(
      child: Stack(
        children: <Widget>[
          FadeIn(
            delay: Duration(milliseconds: 1000),
            child: MapboxMap(
                accessToken: AppConfig.mapAccessToken,
                logoViewMargins: Point(-100, -100),
                attributionButtonMargins: Point(-100, -100),
                trackCameraPosition: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                compassEnabled: false,
                myLocationRenderMode: MyLocationRenderMode.NORMAL,
                //myLocationEnabled: false,
                onMapCreated: (MapboxMapController controller){
                  this.mapController = controller;
                },

                onStyleLoadedCallback: () async{
                  await Future.delayed(Duration(milliseconds: 500),(){
                    setState(() { isMapVisible = true;  });
                  });

                  if(pinLocation != null){
                    mapController.addSymbol(
                        SymbolOptions(
                          geometry: pinLocation,
                          iconSize: 0.3,
                          iconImage: "assets/images/pin.png",
                        )
                    );
                  }

                },

                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 14.0,
                )
            ),
          ),

          Visibility(visible: !isMapVisible,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
