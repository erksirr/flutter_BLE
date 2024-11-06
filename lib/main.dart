import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fuckproject_/ble_controller.dart';
import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLETEST',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BleController controller = Get.put(BleController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLETEST')),
      body: GetBuilder<BleController>(
        builder: (BleController controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: StreamBuilder<List<ScanResult>>(
                    stream: controller.scanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data![index];
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(data.device.name.isNotEmpty
                                    ? data.device.name
                                    : "-"),
                                subtitle: Text(data.device.id.toString()),
                                trailing: Text(data.rssi.toString()),
                                onTap: () {
                                  controller.connectToDevice(data.device);
                                },
                              ),
                            );
                          },
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        return const Center(child: Text("No Devices Found"));
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: const Text("SCAN"),
                ),
                if (controller.connectedDevice != null) ...[
                  ElevatedButton(
                    onPressed: () {
                      controller.disconnectDevice();
                    },
                    child: const Text("DISCONNECT"),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fuckproject_/ble_controller.dart';

// void main() async {
//   final hcareService = HCareService();

//   // Initialize the service
//   await hcareService.initialize();

//   // Connect to watch
//   bool connected = await hcareService.connectToWatch();
//   if (connected) {
//     print('Successfully connected to HCare Go 5');

//     // Get glucose readings
//     try {
//       List<GlucoseReading> readings = await hcareService.getGlucoseReadings();
//       for (var reading in readings) {
//         print(
//             'Glucose: ${reading.value} ${reading.unit} at ${reading.timestamp}');
//       }
//     } catch (e) {
//       print('Error getting readings: $e');
//     }
//   } else {
//     print('Failed to connect to watch');
//   }
// }
