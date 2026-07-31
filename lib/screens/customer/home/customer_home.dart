import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>{
  GoogleMapController? mapController;
  BitmapDescriptor? customMarker;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(19.0330, 73.0297), // Nerul
    zoom: 14,
  );

  late final Set<Marker> markers;

  @override
  void initState() {
    super.initState();

    _loadCustomMarker();

    markers = {
      Marker(
        markerId: const MarkerId("1"),
        position: const LatLng(19.0342, 73.0285),
        icon: customMarker ?? BitmapDescriptor.defaultMarker,
        onTap: () {
          _showChargerDetails(
            "Fast Charger",
            "₹18 / kWh",
            "⭐ 4.8",
            "22kW DC Fast Charger",
          );
        },
      ),
      Marker(
        markerId: const MarkerId("2"),
        position: const LatLng(19.0308, 73.0260),
        icon: customMarker ?? BitmapDescriptor.defaultMarker, 
        onTap: () {
          _showChargerDetails(
            "Bhimanshankar Station",
            "₹20 / kWh",
            "⭐ 4.6",
            "15kW Fast Charger",
          );
        },
      ),
      Marker(
        markerId: const MarkerId("3"),
        position: const LatLng(19.0370, 73.0320),
        icon: customMarker ?? BitmapDescriptor.defaultMarker, 
        onTap: () {
          _showChargerDetails(
            "Kharghar Charger",
            "₹15 / kWh",
            "⭐ 4.5",
            "7kW AC Charger",
          );
        },
      ),
      Marker(
        markerId: const MarkerId("4"),
        position: const LatLng(19.0290, 73.0345),
        icon: customMarker ?? BitmapDescriptor.defaultMarker,
        onTap: () {
          _showChargerDetails(
            "EV Point",
            "₹17 / kWh",
            "⭐ 4.7",
            "11kW Charger",
          );
        },
      ),
      Marker(
        markerId: const MarkerId("5"),
        position: const LatLng(19.0355, 73.0362),
        icon: customMarker ?? BitmapDescriptor.defaultMarker, 
        onTap: () {
          _showChargerDetails(
            "Car Charger Jewels",
            "₹22 / kWh",
            "⭐ 5.0",
            "50kW DC Fast Charger",
          );
        },
      ),
    };
  }
  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(
        size: Size(60, 60),
      ),
      'assets/icons/ev_marker.png',
    );

    setState(() {});
  }

  void _showChargerDetails(
    String name,
    String price,
    String rating,
    String type,

  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 10),
                  Text(
                    rating,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.ev_station, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    type,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 14),
                  SizedBox(width: 10),
                  Text(
                    "Available Now",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Booking $name..."),
                      ),
                    );
                  },
                  child: const Text(
                    "Book Now",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("ChargeLink")),
    body: const Center(
      child: Text(
        "Customer Home Loaded!",
        style: TextStyle(fontSize: 28),
      ),
    ),
  );
}
}