import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/utils/basic_import.dart';

/// package

//  google_maps_flutter: ^2.5.0
//   geocoding: ^2.1.1
//   geolocator: ^10.1.0

/// OnTap use

//            () => LocationPickerWidget(
//                   selectedAddress: controller.selectedAddress,
//                   selectedLatLng: controller.selectedLatLng,
//                   googleApiKey: controller.googleApiKey,
//                   primaryColor: CustomColors.rejected,
//                   appBarColor: CustomColors.rejected,
//                   initialLatLng: LatLng(23.8103, 90.4125),
//                 ),

/// Controller

//  final RxString selectedAddress = "".obs;
//   final Rxn<LatLng> selectedLatLng = Rxn<LatLng>();
//   final String googleApiKey = "AIzaSyC_qKHmzl-HHB9hr8-fWGmhETSVR2H0894";

class LocationPickerWidget extends StatefulWidget {
  final RxString selectedAddress;
  final Rxn<LatLng> selectedLatLng;
  final String googleApiKey;
  final Color? primaryColor;
  final Color? buttonTextColor;
  final Color? appBarColor;
  final LatLng? initialLatLng;

  const LocationPickerWidget({
    super.key,
    required this.selectedAddress,
    required this.selectedLatLng,
    required this.googleApiKey,
    this.primaryColor,
    this.buttonTextColor,
    this.appBarColor,
    this.initialLatLng, // NEW
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentPosition = const LatLng(57.77626523533849, -101.67807676458044); // default
  String _currentAddress = '';
  List<PlaceSuggestion> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingAddress = false;
  bool _isMapLoading = true;
  bool _hasLocationSelected = false;

  Color get _primaryColor => widget.primaryColor ?? Colors.blue;

  Color get _buttonTextColor => widget.buttonTextColor ?? Colors.white;

  Color get _appBarColor => widget.appBarColor ?? Colors.blue;

  @override
  void initState() {
    super.initState();

    /// 1️⃣ if user previously selected location → use that
    if (widget.selectedLatLng.value != null) {
      _currentPosition = widget.selectedLatLng.value!;
      _currentAddress = widget.selectedAddress.value;
      _hasLocationSelected = true;
    }
    /// 2️⃣ else if initialLatLng is provided → use that
    else if (widget.initialLatLng != null) {
      _currentPosition = widget.initialLatLng!;
    }
    /// 3️⃣ else → keep default Dhaka
    else {
      _currentPosition = const LatLng(57.77626523533849, -101.67807676458044);
    }
  }

  // Google Places Autocomplete API
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${widget.googleApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          setState(() {
            _searchResults = predictions
                .map(
                  (p) => PlaceSuggestion(
                    placeId: p['place_id'],
                    description: p['description'],
                  ),
                )
                .toList();
            _isSearching = false;
          });
        } else {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      CustomSnackBar.error('Failed to search location');
    }
  }

  // Get place details from place_id
  Future<void> _getPlaceDetails(String placeId) async {
    setState(() => _isLoadingAddress = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${widget.googleApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final address = data['result']['formatted_address'];

          final position = LatLng(location['lat'], location['lng']);

          setState(() {
            _currentPosition = position;
            _currentAddress = address;
            _searchResults = [];
            _isLoadingAddress = false;
            _hasLocationSelected = true;
          });

          _searchController.clear();
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(position, 16),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoadingAddress = false);
      CustomSnackBar.error('Failed to get place details');
    }
  }

  // Reverse Geocoding - Get address from coordinates
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${widget.googleApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          setState(() {
            _currentAddress = data['results'][0]['formatted_address'];
            _isLoadingAddress = false;
            _hasLocationSelected = true;
          });
        } else {
          setState(() {
            _currentAddress = 'Address not found';
            _isLoadingAddress = false;
            _hasLocationSelected = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Failed to get address';
        _isLoadingAddress = false;
        _hasLocationSelected = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapLoading = false;
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _currentPosition = position;
    });
    _getAddressFromLatLng(position);
  }

  void _confirmLocation() {
    if (!_hasLocationSelected ||
        _currentAddress.isEmpty ||
        _currentAddress == 'Address not found') {
      CustomSnackBar.error('Please select a location');
      return;
    }

    widget.selectedLatLng.value = _currentPosition;
    widget.selectedAddress.value = _currentAddress;
    Get.back();
    CustomSnackBar.success(message: 'Location confirmed', title: 'Success');
  }

  // Get current device location
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Service Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          CustomSnackBar.error('Location permission is required');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        CustomSnackBar.error(
          'Location permission is permanently denied. Please enable from settings',
        );
        return;
      }

      // Show loading
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: CustomColors.primary),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Get.back();

      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = currentLatLng;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 16),
      );

      _getAddressFromLatLng(currentLatLng);
    } catch (e) {
      Get.back();
      CustomSnackBar.error('Failed to get current location: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.close(1),
          icon: Icon(Icons.arrow_back_ios_new, color: _buttonTextColor),
        ),
        title: TextWidget(
          'Select Location',
          color: _buttonTextColor,
          fontSize: Dimensions.titleLarge * 0.9,
        ),
        backgroundColor: _appBarColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: _buttonTextColor),
            onPressed: _getCurrentLocation,
            tooltip: 'Current Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 10,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            // myLocationEnabled: true,
            // zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            // <-- keep zoom buttons visible
            // liteModeEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onTap: _onMapTapped,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _currentPosition,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() => _currentPosition = newPosition);
                  _getAddressFromLatLng(newPosition);
                },
              ),
            },
          ),

          // Map Loading Indicator
          if (_isMapLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: _primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Search Bar and Results
          if (!_isMapLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Search Field
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.black.withAlpha(852)),
                      // 🔵 user input text color
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        hintStyle: TextStyle(
                          color: Colors.black.withAlpha(852),
                        ),
                        prefixIcon: Icon(Icons.search, color: _primaryColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults = []);
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        _searchLocation(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Loading Indicator
                  if (_isSearching)
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Searching...'),
                          ],
                        ),
                      ),
                    ),

                  // Search Results
                  if (_searchResults.isNotEmpty)
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, indent: 56),
                          itemBuilder: (context, index) {
                            final suggestion = _searchResults[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: _primaryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                suggestion.description,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () => _getPlaceDetails(suggestion.placeId),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Bottom Section - Address Display and Confirm Button
          if (!_isMapLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Selected Location Label
                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Address Display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: _primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _isLoadingAddress
                                    ? Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: _primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Loading address...',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        _currentAddress.isEmpty
                                            ? 'Tap on map to select location'
                                            : _currentAddress,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _currentAddress.isEmpty
                                              ? Colors.grey[400]
                                              : Colors.black87,
                                          height: 1.4,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                (_isLoadingAddress || !_hasLocationSelected)
                                ? null
                                : _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoadingAddress
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _buttonTextColor,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: _buttonTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Confirm Location',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _buttonTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});
}
