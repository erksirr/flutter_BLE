import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLETEST')),
      body: GetBuilder<BleController>(
        init: BleController(),
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
                            // Debugging: Check advertisement data
                            // print('Advertisement Data: ${data.advertisementData}');
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(data.device.platformName.isNotEmpty
                                    ? data.device.platformName
                                    : "Unknown Device"),
                                subtitle: Text(data.device.id.toString()),
                                trailing: Text(data.rssi.toString()),
                                onTap: ()=>controller.connectToDevice(data.device),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        return Center(child: Text("No Devices Found"));
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: Text("SCAN"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// class BleExample extends StatefulWidget {
//   @override
//   _BleExampleState createState() => _BleExampleState();
// }

// class _BleExampleState extends State<BleExample> {
//   BleController _bleController = BleController();
//   List<ScanResult> _scanResults = [];

//   @override
//   void initState() {
//     super.initState();
//     _bleController.initBle();
//   }

//   @override
//   void dispose() {
//     _bleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('BLE Example')),
//       body: ListView.builder(
//         itemCount: _scanResults.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(_bleController.getBestDeviceName(_scanResults[index])),
//             subtitle: Text('ID: ${_scanResults[index].device.id.toString()}\nRSSI: ${_scanResults[index].rssi} dBm'),
//             trailing: Text('${_scanResults[index].rssi} dBm'),
//             onTap: () => _connectToDevice(_scanResults[index].device),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _startScan,
//         child: Icon(Icons.search),
//       ),
//     );
//   }

//   void _startScan() async {
//     try {
//       setState(() => _scanResults = []);
//       _scanResults = await _bleController.scanDevices();
//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error scanning: $e')),
//       );
//     }
//   }

//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       bool connected = await _bleController.connectToDevice(device);
//       if (connected) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Connected to ${device.name}')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to connect to ${device.name}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error connecting: $e')),
//       );
//     }
//   }
// }