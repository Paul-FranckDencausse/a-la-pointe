// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:url_launcher/url_launcher.dart';

Future<bool> checkAndRequestBluetooth(BuildContext context) async {
  // Vérifie que le Bluetooth est supporté
  if (!await FlutterBluePlus.isSupported) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bluetooth non supporté sur cet appareil.")),
    );
    return false;
  }

  // Vérifie l’état actuel du Bluetooth
  final state = await FlutterBluePlus.adapterState.first;
  if (state == BluetoothAdapterState.on) {
    return true; // ✅ Bluetooth déjà activé
  }



  // Android → ouvre la page Bluetooth des paramètres
  if (Theme.of(context).platform == TargetPlatform.android) {
    final Uri settingsUri = Uri.parse("bluetooth:");
    if (await canLaunchUrl(settingsUri)) {
      await launchUrl(settingsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Impossible d’ouvrir les paramètres Bluetooth.")),
      );
    }
    return false;
  }

  // iOS → affiche un message car activation impossible par code
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Activez le Bluetooth dans Réglages.")),
    );
    return false;
  }

  return false;
}
