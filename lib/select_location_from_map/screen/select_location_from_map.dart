import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../global_members.dart';
import '../behavior/Suggestion.dart';
import '../behavior/place_api_provider.dart';

class SelectLocationFromMap extends StatefulWidget {
  const SelectLocationFromMap({Key? key,}) : super(key: key);

  @override
  State<SelectLocationFromMap> createState() => SelectLocationFromMapState();
}

class SelectLocationFromMapState extends State<SelectLocationFromMap> {

  late GoogleMapController googleMapController;
  Position? myCurrentPosition;
  PlaceApiProvider placeApiProvider = PlaceApiProvider();
  LatLng defaultLondonCoordinates = const LatLng(51.5072, 0.1276);
  TextEditingController textEditingController = TextEditingController();

  Future<void> getUserCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      myCurrentPosition = await Geolocator.getCurrentPosition();
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(myCurrentPosition!.latitude, myCurrentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
      Navigator.pop(context);
      setState(() {});
    }
  }

  @override
  void initState() {
    getUserCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Stack(
            children: [
              AppBar(
                leadingWidth: 0,
                toolbarHeight: 100,
                leading: const SizedBox(
                  height: 0,
                  width: 0,
                ),
                elevation: 0,
                backgroundColor: const Color(MyGoogleMapProjectColors.primaryColor),
                title: SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 7,
                      ),
                      const AutoSizeText(
                        'search new address',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 57,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                alignment: Alignment.center,
                                height: 43,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            Center(
                              child: TextField(
                                controller: textEditingController,
                                readOnly: true,
                                onTap: () async {
                                  PlaceApiProvider.sessionToken = const Uuid().v4();
                                  final Suggestion? result = await showSearch(
                                    context: context,
                                    delegate: AddressSearch(),
                                  );

                                  if (result != null) {
                                    LatLng? latLng = await placeApiProvider.getPlaceDetailFromId(context, placeId: result.placeId);
                                    if(latLng != null) {
                                      myCurrentPosition = Position(longitude: latLng.longitude, latitude: latLng.latitude, timestamp: null, accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
                                      googleMapController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: latLng,
                                            zoom: 15,
                                          ),
                                        ),
                                      );
                                      setState(() {});
                                    }
                                    textEditingController.text = result.description;
                                  }
                                },
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent)),
                                  hintText: 'Search for area, building name...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF535353),
                                  ),
                                  suffixIcon: const SizedBox(),
                                ),
                              ),
                            ),
                            const Positioned(
                                top: 17,
                                bottom: 17,
                                right: 13,
                                child: Image(
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.fill,
                                  image: AssetImage('assets/images/search_icon.png'),
                                ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
                systemOverlayStyle: const SystemUiOverlayStyle(
                  // status bar color
                  statusBarColor: Color(MyGoogleMapProjectColors.primaryColor),
                  // Status bar brightness (optional)
                  statusBarIconBrightness:
                      Brightness.light, // For Android (dark icons)
                  statusBarBrightness: Brightness.light, // For iOS (dark icons)
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 80,
                  width: 70,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                InkWell(
                  onTap: () async {
                    textEditingController.text = '';
                    PermissionStatus locationPermissionStatus = await Permission.location.request();
                    if (locationPermissionStatus.isGranted) {
                      myCurrentPosition = await Geolocator.getCurrentPosition();
                      googleMapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(myCurrentPosition!.latitude,
                                myCurrentPosition!.longitude),
                            zoom: 15,
                          ),
                        ),
                      );
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: SizedBox(
                      height: 44,
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Image(
                              height: 24,
                              width: 24,
                              image: AssetImage(
                                  'assets/images/current_location_icon.png'),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            AutoSizeText(
                              'Use my current location',
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
            Positioned(
              top: 44,
              bottom: 0,
              left: 0,
              right: 0,
              child: GoogleMap(
                /*onCameraMove: (position) {
                  myCurrentPosition = Position(longitude: position.target.longitude, latitude: position.target.latitude, timestamp: null, accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
                },*/
                onTap: (latLng) {
                  textEditingController.text = '';
                  myCurrentPosition = Position(longitude: latLng.longitude, latitude: latLng.latitude, timestamp: null, accuracy: 0.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
                  setState(() {});
                },
                /*onCameraIdle: () {
                  setState(() {});
                },*/
                onCameraMoveStarted: () {},
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: defaultLondonCoordinates,
                  // zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('1'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    position: myCurrentPosition != null ?  LatLng(myCurrentPosition!.latitude, myCurrentPosition!.longitude) : const LatLng(0.0, 0.0),
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  googleMapController = controller;
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
                child: Container(
                  height: 70,
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                  myCurrentPosition!.latitude, myCurrentPosition!.longitude),
                              zoom: 15,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.15),
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(MyGoogleMapProjectColors.primaryColor),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressSearch extends SearchDelegate<Suggestion> {
  PlaceApiProvider placeApiProvider = PlaceApiProvider();
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Suggestion('', ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      future: placeApiProvider.fetchSuggestions(context, query: query),
      builder: (context, snapshot) => snapshot.hasData
          ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    minLeadingWidth: 0,
                    leading: const Icon(Icons.location_on_outlined, color: Color(MyGoogleMapProjectColors.primaryColor),),
                    title: Text(snapshot.data![index].description,),
                    onTap: () {
                      close(context, snapshot.data![index]);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()),),
    );
  }
}

