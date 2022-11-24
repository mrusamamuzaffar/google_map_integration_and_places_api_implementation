import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../helper/network_connectivity_handler.dart';
import 'Suggestion.dart';
import 'package:http/http.dart' as http;

class PlaceApiProvider with ConnectivityHandler{
  static String sessionToken = '';
  static const apiKey = 'AIzaSyBTkuLuVTgLyz_obA6NZrnXvZ3bjEs3y7g';

  Future<List<Suggestion>> fetchSuggestions(BuildContext context, {required String query,}) async {
    if (await checkForInternetServiceAvailability(context)) {
      try {
        http.Response response = await http.get(Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&sessiontoken=$sessionToken&types=establishment&language=ar|en&key=$apiKey'),);

        if (response.statusCode == 200) {
          Map<String, dynamic> result = json.decode(response.body);
          final String status = result['status'] is String ? result['status'] : '';

          if (status == 'OK') {
            return result['predictions'].map<Suggestion>((prediction) => Suggestion(prediction['place_id'], prediction['description'])).toList();
          }

          if (result['status'] == 'ZERO_RESULTS') {
            return [];
          }
        }
      } on Exception {}
    }
    return [];
  }

  Future<LatLng?> getPlaceDetailFromId(BuildContext context, {required String placeId}) async {
    if (await checkForInternetServiceAvailability(context)) {
      try {
        final response = await http.get(Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey&sessiontoken=$sessionToken'),);

        final LatLng latLng;

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          final String status =
          result['status'] is String ? result['status'] : '';
          if (status == 'OK') {
            Map<String, dynamic> geometry =
            result['result']['geometry']['location'] is Map<String, dynamic>
                ? result['result']['geometry']['location']
                : {};

            if (geometry.isNotEmpty) {
              latLng = LatLng(geometry['lat'], geometry['lng']);
              return latLng;
            }
          }
        }
      } on Exception {}
    }
    return null;
  }
}