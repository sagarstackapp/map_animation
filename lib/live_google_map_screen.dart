import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;

  const MapScreen({
    Key? key,
    required this.origin,
    required this.destination,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late Marker _marker;
  Set<Marker> _markers = {};
  Polyline? _polyline;
  Set<Polyline> _polylines = {};
  late CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: MarkerId('destination'),
      position: widget.origin,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    _markers.add(_marker);
    _cameraPosition = CameraPosition(
      target: widget.origin,
      zoom: 14,
    );
  }

  void _animateMarker() {
    double t = 0;
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (t > 1) {
        timer.cancel();
        return;
      }
      LatLng interpolatedLatLng = LatLng(
          widget.origin.latitude +
              t * (widget.destination.latitude - widget.origin.latitude),
          widget.origin.longitude +
              t *
                  (widget.destination.longitude - widget.origin.longitude));
      Marker updatedMarker = _marker.copyWith(
        positionParam: interpolatedLatLng,
      );
      setState(() {
        _markers.remove(_marker);
        _markers.add(updatedMarker);
        _marker = updatedMarker;
        _polyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: [_marker.position, widget.destination],
        );
        _polylines.add(_polyline!);
      });
      t += 0.05;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: GoogleMap(
        markers: _markers,
        polylines: _polylines,
        initialCameraPosition: _cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _animateMarker();
        },
      ),
    );
  }
}
