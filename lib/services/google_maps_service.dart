import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_webservice/directions.dart' as directions_api;
import 'package:google_maps_webservice/distance.dart' as distance_api;

class GoogleMapsService {
  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with actual key
  
  final PolylinePoints _polylinePoints = PolylinePoints();
  final directions_api.GoogleMapsDirections _directionsApi = 
      directions_api.GoogleMapsDirections(apiKey: apiKey);
  final distance_api.GoogleDistanceMatrix _distanceApi = 
      distance_api.GoogleDistanceMatrix(apiKey: apiKey);

  StreamSubscription<Position>? _locationSubscription;

  // ============= LOCATION PERMISSIONS =============

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // ============= GET CURRENT LOCATION =============

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // ============= LOCATION TRACKING =============

  Stream<Position> trackLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  void startLocationTracking(Function(Position) onLocationUpdate) {
    _locationSubscription = trackLocation().listen(
      (Position position) {
        onLocationUpdate(position);
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  // ============= GEOCODING =============

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return 'Unknown location';

      final place = placemarks.first;
      return '${place.street}, ${place.subLocality}, ${place.locality}';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }

  // Get coordinates from address
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  // ============= DISTANCE CALCULATION =============

  // Calculate distance between two points (in kilometers)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  // Get distance and duration using Google Distance Matrix API
  Future<Map<String, dynamic>?> getDistanceAndDuration(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final response = await _distanceApi.distanceWithLocation(
        [distance_api.Location(lat: origin.latitude, lng: origin.longitude)],
        [distance_api.Location(lat: destination.latitude, lng: destination.longitude)],
        travelMode: distance_api.TravelMode.driving,
      );

      if (response.isOkay && response.results.isNotEmpty) {
        final element = response.results.first.elements.first;
        
        return {
          'distance': element.distance.value / 1000, // Convert to km
          'distanceText': element.distance.text,
          'duration': element.duration.value / 60, // Convert to minutes
          'durationText': element.duration.text,
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting distance: $e');
      return null;
    }
  }

  // ============= DIRECTIONS & POLYLINES =============

  // Get route polyline between two points
  Future<List<LatLng>> getRoutePolyline(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting route: $e');
      return [];
    }
  }

  // Get detailed directions
  Future<directions_api.DirectionsResult?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final response = await _directionsApi.directionsWithLocation(
        directions_api.Location(lat: origin.latitude, lng: origin.longitude),
        directions_api.Location(lat: destination.latitude, lng: destination.longitude),
        travelMode: directions_api.TravelMode.driving,
      );

      if (response.isOkay && response.routes.isNotEmpty) {
        return response;
      }
      
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  // ============= MAP MARKERS =============

  // Create custom marker for pickup location
  BitmapDescriptor? _pickupMarker;
  BitmapDescriptor? _deliveryMarker;
  BitmapDescriptor? _riderMarker;

  Future<void> loadCustomMarkers() async {
    _pickupMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/pickup_marker.png',
    );
    
    _deliveryMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/delivery_marker.png',
    );
    
    _riderMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/rider_marker.png',
    );
  }

  Set<Marker> createOrderMarkers({
    required LatLng pickupLocation,
    required LatLng deliveryLocation,
    LatLng? riderLocation,
  }) {
    final markers = <Marker>{};

    // Pickup marker
    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLocation,
      icon: _pickupMarker ?? BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      infoWindow: const InfoWindow(title: 'Pickup Location'),
    ));

    // Delivery marker
    markers.add(Marker(
      markerId: const MarkerId('delivery'),
      position: deliveryLocation,
      icon: _deliveryMarker ?? BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      infoWindow: const InfoWindow(title: 'Delivery Location'),
    ));

    // Rider marker (if available)
    if (riderLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('rider'),
        position: riderLocation,
        icon: _riderMarker ?? BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        infoWindow: const InfoWindow(title: 'Rider Location'),
      ));
    }

    return markers;
  }

  // ============= CAMERA POSITION =============

  // Get camera position to show all markers
  CameraPosition getCameraPositionForBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return const CameraPosition(
        target: LatLng(-6.7924, 39.2083), // Dar es Salaam
        zoom: 12,
      );
    }

    if (points.length == 1) {
      return CameraPosition(
        target: points.first,
        zoom: 15,
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: 12,
    );
  }

  // Move camera to show route
  Future<void> showRoute(
    GoogleMapController controller,
    LatLng origin,
    LatLng destination,
  ) async {
    final bounds = LatLngBounds(
      southwest: LatLng(
        origin.latitude < destination.latitude ? origin.latitude : destination.latitude,
        origin.longitude < destination.longitude ? origin.longitude : destination.longitude,
      ),
      northeast: LatLng(
        origin.latitude > destination.latitude ? origin.latitude : destination.latitude,
        origin.longitude > destination.longitude ? origin.longitude : destination.longitude,
      ),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // ============= ETA CALCULATION =============

  Future<DateTime?> calculateETA(
    LatLng currentLocation,
    LatLng destination,
  ) async {
    try {
      final distanceInfo = await getDistanceAndDuration(
        currentLocation,
        destination,
      );

      if (distanceInfo != null) {
        final durationMinutes = distanceInfo['duration'] as double;
        return DateTime.now().add(Duration(minutes: durationMinutes.round()));
      }
      
      return null;
    } catch (e) {
      print('Error calculating ETA: $e');
      return null;
    }
  }

  // ============= CLEANUP =============

  void dispose() {
    stopLocationTracking();
  }
}
