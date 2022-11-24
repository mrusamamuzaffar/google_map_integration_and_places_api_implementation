import 'package:flutter/material.dart';
import 'package:google_map_integration/select_location_from_map/screen/select_location_from_map.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Google Map Flutter',
      debugShowCheckedModeBanner: false,
      home: SelectLocationFromMap(),
    ),
  );
}
