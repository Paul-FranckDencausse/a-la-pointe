import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// =======================
/// UUID BLE (DOIVENT MATCHER L'ESP32)
/// =======================
const String serviceUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
const String cmdCharUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
const String evtCharUUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  BluetoothDevice? device;
  BluetoothCharacteristic? cmdChar;
  BluetoothCharacteristic? evtChar;

  bool isConnected = false;
  bool buzzerEnabled = true;
  bool silentMode = false;

  String selectedMode = "Initiation";
  String status = "Non connecté";

  /// =======================
  /// CONNEXION BLE
  /// =======================
  Future<void> connectBLE() async {
    setState(() => status = "Recherche de la cible…");

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.device.name == "OptiMove-S3") {
          device = r.device;
          await FlutterBluePlus.stopScan();
          await device!.connect();
          await discoverServices();
          setState(() {
            isConnected = true;
            status = "Connecté ✔️";
          });
        }
      }
    });
  }

  /// =======================
  /// DÉCOUVERTE SERVICES
  /// =======================
  Future<void> discoverServices() async {
    final services = await device!.discoverServices();
    for (final s in services) {
      if (s.uuid.toString() == serviceUUID) {
        for (final c in s.characteristics) {
          if (c.uuid.toString() == cmdCharUUID) cmdChar = c;
          if (c.uuid.toString() == evtCharUUID) {
            evtChar = c;
            await evtChar!.setNotifyValue(true);
            evtChar!.value.listen(handleEvent);
          }
        }
      }
    }
  }

  /// =======================
  /// ENVOI COMMANDE
  /// =======================
  Future<void> sendCommand(Map<String, dynamic> data) async {
    if (cmdChar == null) return;
    final payload = jsonEncode(data);
    await cmdChar!.write(utf8.encode(payload), withoutResponse: false);
  }

  /// =======================
  /// ÉVÉNEMENTS ESP32
  /// =======================
  void handleEvent(List<int> value) {
    final decoded = utf8.decode(value);
    final event = jsonDecode(decoded);

    debugPrint("📥 EVENT: $event");

    if (event["event"] == "TARGET") {
      debugPrint("🎯 Cible ${event["data"]["target"]}");
    }
  }

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OptiMove – Training"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isConnected ? buildTrainingUI() : buildNotConnectedUI(),
      ),
    );
  }

  /// =======================
  /// ÉCRAN NON CONNECTÉ
  /// =======================
  Widget buildNotConnectedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.bluetooth_disabled, size: 80),
        const SizedBox(height: 20),
        Text(status),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: connectBLE,
          icon: const Icon(Icons.bluetooth),
          label: const Text("Se connecter à OptiMove"),
        )
      ],
    );
  }

  /// =======================
  /// ÉCRAN ENTRAINEMENT
  /// =======================
  Widget buildTrainingUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statut : $status"),
          const SizedBox(height: 20),

          /// MODE
          DropdownButtonFormField<String>(
            value: selectedMode,
            decoration: const InputDecoration(labelText: "Mode"),
            items: const [
              DropdownMenuItem(value: "Initiation", child: Text("Initiation")),
              DropdownMenuItem(value: "Loisir", child: Text("Loisir")),
              DropdownMenuItem(value: "Performeurs", child: Text("Performeurs")),
              DropdownMenuItem(value: "Serie", child: Text("Série")),
            ],
            onChanged: (v) => setState(() => selectedMode = v!),
          ),

          const SizedBox(height: 20),

          /// OPTIONS
          SwitchListTile(
            title: const Text("Buzzer"),
            value: buzzerEnabled,
            onChanged: (v) => setState(() => buzzerEnabled = v),
          ),

          SwitchListTile(
            title: const Text("Mode silencieux"),
            value: silentMode,
            onChanged: (v) => setState(() => silentMode = v),
          ),

          const SizedBox(height: 30),

          /// START
          ElevatedButton(
            onPressed: () {
              sendCommand({
                "cmd": "START",
                "mode": selectedMode,
                "targets": 3,
                "delay_ms": selectedMode == "Initiation"
                    ? 3000
                    : selectedMode == "Loisir"
                    ? 1500
                    : 800,
                "buzzer": buzzerEnabled && !silentMode
              });
            },
            child: const Text("Démarrer l'entraînement"),
          ),

          const SizedBox(height: 10),

          /// STOP
          OutlinedButton(
            onPressed: () {
              sendCommand({"cmd": "STOP"});
            },
            child: const Text("Arrêter"),
          ),
        ],
      ),
    );
  }
}
