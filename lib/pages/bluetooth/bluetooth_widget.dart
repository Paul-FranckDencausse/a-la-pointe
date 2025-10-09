import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  static String routeName = 'BluetoothWidget';
  static String routePath = '/bluetooth';

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  Future<void> _openBluetoothSettings() async {
    try {
      // Ouvre les paramètres généraux de l'app
      await AppSettings.openAppSettings();
    } catch (_) {
      try {
        // Android fallback pour ouvrir directement les paramètres Bluetooth
        final intent = AndroidIntent(action: 'android.settings.BLUETOOTH_SETTINGS');
        await intent.launch();
      } catch (_) {
        // iOS fallback
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Impossible d’ouvrir les paramètres Bluetooth."),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Bluetooth'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.bluetooth),
          label: const Text("Ouvrir les paramètres Bluetooth"),
          onPressed: _openBluetoothSettings,
        ),
      ),
    );
  }
}
