import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  // ไม่จำเป็นต้องสร้าง instance แล้ว เนื่องจาก FlutterBluePlus เป็น singleton
  
  // ฟังก์ชันสำหรับขอ permission
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // ฟังก์ชันสำหรับสแกนอุปกรณ์
  Future<void> scanDevices() async {
    if (await _requestPermissions()) {
      try {
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      } catch (e) {
        print('Error starting scan: $e');
      } finally {
        // FlutterBluePlus จะหยุดสแกนอัตโนมัติหลังจาก timeout
        // แต่เราสามารถเรียกหยุดสแกนเองได้ถ้าต้องการ
        // await FlutterBluePlus.stopScan();
      }
    } else {
      print('Permissions not granted');
      // คุณอาจต้องการจัดการกรณีที่ไม่ได้รับ permission ตามที่เหมาะสม
    }
  }

  // Getter สำหรับ stream ของผลลัพธ์การสแกน
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // ฟังก์ชันสำหรับเชื่อมต่อกับอุปกรณ์
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
     
      await device.connect(timeout: Duration(seconds: 5));
       print("Device connecting to: ${device}");
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }
  
  // ฟังก์ชันสำหรับตัดการเชื่อมต่อ
  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }

  // ฟังก์ชันสำหรับตรวจสอบสถานะ Bluetooth
  Future<bool> isBluetoothAvailable() async {
    return await FlutterBluePlus.isAvailable;
  }

  // ฟังก์ชันสำหรับเปิด Bluetooth (ถ้าปิดอยู่)
  Future<void> turnOnBluetooth() async {
    if (!(await FlutterBluePlus.isOn)) {
      await FlutterBluePlus.turnOn();
    }
  }

  @override
  void onInit() {
    super.onInit();
    // คุณสามารถเพิ่มโค้ดเริ่มต้นที่นี่ เช่น ตรวจสอบสถานะ Bluetooth
  }

  @override
  void onClose() {
    // ทำความสะอาดทรัพยากรถ้าจำเป็น
    super.onClose();
  }
}


// import 'dart:async';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class BleController {
//   BluetoothDevice? _connectedDevice;
//   StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

//   // เริ่มต้นการทำงานของ BLE
//   Future<void> initBle() async {
//     _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
//       if (state == BluetoothAdapterState.on) {
//         // Bluetooth เปิดอยู่
//       } else {
//         // Bluetooth ปิดอยู่หรือไม่พร้อมใช้งาน
//       }
//     });
//   }
//   String getBestDeviceName(ScanResult result) {
//     if (result.device.platformName.isNotEmpty) {
//       return result.device.platformName;
//     }
//     return 'Unknown device';
//   }
//   // สแกนหาอุปกรณ์ Bluetooth
//   Future<List<ScanResult>> scanDevices() async {
//     if (!await FlutterBluePlus.isSupported) {
//       throw Exception('Bluetooth ไม่รองรับบนอุปกรณ์นี้');
//     }

//     List<ScanResult> scanResults = [];
//     await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
//     FlutterBluePlus.scanResults.listen((results) {
//       scanResults = results;
//     });
//     await FlutterBluePlus.stopScan();
//     return scanResults;
//   }

//   // เชื่อมต่อกับอุปกรณ์
//   Future<bool> connectToDevice(BluetoothDevice device) async {
//     await device.connect();
//     device.connectionState.listen((BluetoothConnectionState state) {
//       if (state == BluetoothConnectionState.connected) {
//         _connectedDevice = device;
//       } else {
//         _connectedDevice = null;
//       }
//     });
//     return _connectedDevice != null;
//   }

//   // ยกเลิกการเชื่อมต่อ
//   Future<void> disconnect() async {
//     if (_connectedDevice != null) {
//       await _connectedDevice!.disconnect();
//     }
//     _connectedDevice = null;
//   }

//   // ส่งข้อมูลไปยังอุปกรณ์
//   Future<void> writeData(List<int> data, String serviceUuid, String characteristicUuid) async {
//     if (_connectedDevice == null) {
//       throw Exception('ไม่ได้เชื่อมต่อกับอุปกรณ์');
//     }

//     List<BluetoothService> services = await _connectedDevice!.discoverServices();
//     for (BluetoothService service in services) {
//       if (service.uuid.toString() == serviceUuid) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.uuid.toString() == characteristicUuid) {
//             await characteristic.write(data);
//             return;
//           }
//         }
//       }
//     }
//     throw Exception('ไม่พบ service หรือ characteristic ที่ระบุ');
//   }

//   // อ่านข้อมูลจากอุปกรณ์
//   Future<List<int>> readData(String serviceUuid, String characteristicUuid) async {
//     if (_connectedDevice == null) {
//       throw Exception('ไม่ได้เชื่อมต่อกับอุปกรณ์');
//     }

//     List<BluetoothService> services = await _connectedDevice!.discoverServices();
//     for (BluetoothService service in services) {
//       if (service.uuid.toString() == serviceUuid) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.uuid.toString() == characteristicUuid) {
//             List<int> value = await characteristic.read();
//             return value;
//           }
//         }
//       }
//     }
//     throw Exception('ไม่พบ service หรือ characteristic ที่ระบุ');
//   }

//   // ยกเลิกการสมัครรับข้อมูลทั้งหมด
//   void dispose() {
//     _adapterStateSubscription?.cancel();
//   }
// }