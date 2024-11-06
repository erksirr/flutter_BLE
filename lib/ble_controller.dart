// import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  // Bluetooth device instance
  // static const String DEVICE_NAME_PREFIX = 'Hcare GO5';
  // static const String GLUCOSE_SERVICE_UUID =
  //     '1800'; // Standard Glucose Service UUID
  // static const String GLUCOSE_MEASUREMENT_CHAR_UUID =
  //     '1800'; // Standard Glucose Measurement
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan(); // Stop scan before connecting
      await device.connect(timeout: Duration(seconds: 5));
      print("Connected to device: $device");
      connectedDevice = device; // Set the connected device
      update(); // Update the UI

      // Discover and list services
      await _discoverServices(); // Call to discover services
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> scanDevices() async {
    if (await _requestPermissions()) {
      try {
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      } catch (e) {
        print('Error starting scan: $e');
      }
    } else {
      print('Permissions not granted');
    }
  }

  // Getter for scan results stream
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
        connectedDevice = null; // Clear the connected device
        update(); // Update the UI
        // print('aod love wee');
        print('disconnecting from that device');
      } catch (e) {
        print('Error disconnecting from device: $e');
      }
    }
  }

  Future<void> _discoverServices() async {
    if (connectedDevice != null) {
      try {
        services = await connectedDevice!.discoverServices();
        print('Services discovered: ${services.length}');

        for (var service in services) {
          print(
              'Service UUID: ${service.uuid}--------------------------------------------');

          // Print characteristics for each service
          for (var characteristic in service.characteristics) {
            // print('  └─ Characteristic UUID: ${characteristic.uuid}');
            // print('     Properties:');
            // print('       - Read: ${characteristic.properties.read}');
            // print('       - Write: ${characteristic.properties.write}');
            // print('       - Notify: ${characteristic.properties.notify}');
            // print('       - Indicate: ${characteristic.properties.indicate}');
            List<int> value = await characteristic.read();
            // แปลงค่าที่อ่านได้เป็นน้ำตาล (ควรปรับตามประเภทข้อมูลที่ได้รับ)
            print('Characteristic.uuid: ${characteristic.uuid}');
            print("value: $value ");
          }
        }

        update(); // Update the UI if you display services there
      } catch (e) {
        print('Error discovering services: $e');
      }
    } else {
      print('No connected device');
    }
  }
}

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';

// class HCareService {
//   // HCare Go 5 specific UUIDs
//   static const String DEVICE_NAME_PREFIX = 'HUAWEI WATCH GT 2-298';
//   static const String GLUCOSE_SERVICE_UUID =
//       '1800'; // Standard Glucose Service UUID
//   static const String GLUCOSE_MEASUREMENT_CHAR_UUID =
//       '2A04'; // Standard Glucose Measurement

//  BluetoothDevice? _device;

//   Future<void> initialize() async {
//     try {
//       // Initialize Flutter Binding
//       WidgetsFlutterBinding.ensureInitialized();

//       // Check if Bluetooth is turned on
//       final state = await FlutterBluePlus.adapterState.first;
//       print('Bluetooth adapter state: $state');

//       if (state == BluetoothAdapterState.off) {
//         throw Exception('Bluetooth is turned off');
//       }

//       await _requestPermissions();
//     } catch (e) {
//       throw Exception('Failed to initialize Bluetooth: $e');
//     }
//   }

//   Future<void> _requestPermissions() async {
//     // Request location permission which is needed for BLE scanning
//     // Implementation depends on your permission handling package
//   }

//   Future<bool> connectToWatch() async {
//     try {
//       print('Starting scan for HCare Go 5...');

//       // Make sure no scan is in progress
//       if (await FlutterBluePlus.isScanning.first) {
//         print('Stopping existing scan...');
//         await FlutterBluePlus.stopScan();
//       }

//       bool deviceFound = false;
//       BluetoothDevice? foundDevice;

//       // Start listening for scan results before starting scan
//       final subscription = FlutterBluePlus.scanResults.listen((results) {
//         print('Scan results received: ${results.length} devices');
//         for (ScanResult result in results) {
//           print(
//               'Found device: ${result.device.platformName} (${result.device.remoteId})');
              
//           if (result.device.platformName==DEVICE_NAME_PREFIX) {
//             print(
//                 'Found matching HCare Go 5 device: ${result.device.platformName}');
//             foundDevice = result.device;
//             deviceFound = true;
//           }
//         }
//       }, onError: (error) {
//         print('Scan error: $error');
//       });

//       // Start scanning
//       await FlutterBluePlus.startScan(
//         timeout: const Duration(seconds: 10),
//         androidUsesFineLocation: true,
//       );

//       // Wait for the scan to complete
//       await Future.delayed(const Duration(seconds: 11));

//       // Clean up
//       await subscription.cancel();
//       await FlutterBluePlus.stopScan();

//       if (foundDevice != null) {
//         print('Attempting to connect to device...');
//         _device = foundDevice;
//         try {
//           await _device!.connect(timeout: const Duration(seconds: 10));
//           final isConnected = await _device!.isConnected;
//           print(
//               'Connection status: ${isConnected ? 'connected' : 'not connected'}');
//           return isConnected;
//         } catch (e) {
//           print('Connection error: $e');
//           return false;
//         }
//       } else {
//         print('No matching device found');
//         return false;
//       }
//     } catch (e) {
//       print('Error during device scan/connect: $e');
//       return false;
//     }
//   }

// Future<List<GlucoseReading>> getGlucoseReadings() async {
//     if (_device == null) {
//       throw Exception('Device not connected');
//     }

//     List<GlucoseReading> readings = [];

//     try {
//       print('Discovering services...');
//       List<BluetoothService> services = await _device!.discoverServices();
//       print('Found ${services.length} services');

//       // Print details of all services
//       for (var service in services) {
//         print('Service: ${service.uuid}');
//         print('Service UUID in uppercase: ${service.uuid.toString().toUpperCase()}');
        
//         // Print characteristics for each service
//         for (var characteristic in service.characteristics) {
//           print('  └─ Characteristic: ${characteristic.uuid}');
//           print('     Properties: ');
//           print('       - Read: ${characteristic.properties.read}');
//           print('       - Write: ${characteristic.properties.write}');
//           print('       - Notify: ${characteristic.properties.notify}');
//           print('       - Indicate: ${characteristic.properties.indicate}');
//         }
//         print('-------------------');
//       }

//       // Try to find glucose service
//       var glucoseService = services.firstWhere(
//         (service) => service.uuid.toString().toUpperCase().contains(GLUCOSE_SERVICE_UUID),
//         orElse: () {
//           print('Could not find service with UUID containing: $GLUCOSE_SERVICE_UUID');
//           print('Available service UUIDs:');
//           services.forEach((s) => print('- ${s.uuid}'));
//           throw Exception('Glucose service not found');
//         },
//       );
//       print('Found glucose service: ${glucoseService.uuid}');

//       // Get glucose measurement characteristic
//       var glucoseChar = glucoseService.characteristics.firstWhere(
//         (char) => char.uuid.toString().toUpperCase().contains(GLUCOSE_MEASUREMENT_CHAR_UUID),
//         orElse: () {
//           print('Could not find characteristic with UUID containing: $GLUCOSE_MEASUREMENT_CHAR_UUID');
//           print('Available characteristic UUIDs:');
//           glucoseService.characteristics.forEach((c) => print('- ${c.uuid}'));
//           throw Exception('Glucose measurement characteristic not found');
//         },
//       );
//       print('Found glucose characteristic: ${glucoseChar.uuid}');

//       // Enable notifications
//       await glucoseChar.setNotifyValue(true);

//       // Read historical data
//       final value = await glucoseChar.read();
//       print('value: ${value}');
//       print('Read value length: ${value.length}');
//       if (value.isNotEmpty) {
//         readings.add(_parseGlucoseData(value));
//       }

//       return readings;
//     } catch (e) {
//       print('Error getting glucose readings: $e');
//       throw Exception('Failed to get glucose readings: $e');
//     }
//   }


//   GlucoseReading _parseGlucoseData(List<int> data) {
//     // Implementation of parsing logic based on HCare Go 5 data format
//     // This is a simplified example - actual implementation will depend on
//     // the specific data format used by HCare Go 5
//     return GlucoseReading(
//         value: _extractGlucoseValue(data),
//         timestamp: DateTime.now(),
//         unit: 'mg/dL');
//   }

//   double _extractGlucoseValue(List<int> data) {
//     // Implement actual parsing logic based on HCare Go 5 data format
//     // This is a placeholder implementation
//     print(data);
//     if (data.length >= 2) {
//       return (data[1] << 8 | data[0]).toDouble();
//     }
//     return 0.0;
//   }
// }

// // Data model for glucose readings
// class GlucoseReading {
//   final double value;
//   final DateTime timestamp;
//   final String unit;

//   GlucoseReading({
//     required this.value,
//     required this.timestamp,
//     required this.unit,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'value': value,
//       'timestamp': timestamp.toIso8601String(),
//       'unit': unit,
//     };
//   }
// }