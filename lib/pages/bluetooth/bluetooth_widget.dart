import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart'; // Pour ouvrir les paramètres
import 'package:google_fonts/google_fonts.dart'; // Si vous l'utilisez pour le style

// Vous pouvez supprimer les imports de flutter_blue_plus et d'autres logiques de scan// si vous ne les utilisez plus dans cette version simplifiée.

// --- Début de ErreurWidget (version simplifiée pour l'exemple) ---
// Vous pouvez garder votre ErreurWidget si vous voulez afficher des messages
// d'erreur spécifiques liés à l'impossibilité d'ouvrir les paramètres (très rare).
class ErrorAction {
  final String label;
  final VoidCallback onPressed;
  ErrorAction({required this.label, required this.onPressed});
}

class ErreurWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final List<ErrorAction>? actions;

  const ErreurWidget({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.error_outline, color: Colors.red, size: 60),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(title!, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (actions != null) ...[
              const SizedBox(height: 24),
              ...actions!.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(onPressed: action.onPressed, child: Text(action.label)),
              )).toList(),
            ]
          ],
        ),
      ),
    );
  }
}
// --- Fin de ErreurWidget ---


class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  static String routeName = 'BluetoothSettingsPage'; // Nom de route mis à jour
  static String routePath = '/bluetooth-settings';   // Chemin mis à jour

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Plus besoin des états liés au scan, aux appareils, à la connexion, etc.
  // bool _bluetoothOn = false;
  // List<BluetoothDevice> _pairedDevices = [];
  // etc.

  // Vous pouvez garder _showSnackbar si vous voulez afficher des messages
  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openBluetoothSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } catch (e) {
      // Gérer l'erreur si l'ouverture des paramètres échoue (rare)
      debugPrint("Erreur lors de l'ouverture des paramètres Bluetooth: $e");
      _showSnackbar("Impossible d'ouvrir les paramètres Bluetooth.");
      // Optionnellement, afficher un ErreurWidget plus détaillé
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adaptez le thème si vous n'utilisez pas FlutterFlowTheme directement
    // final theme = FlutterFlowTheme.of(context); // Exemple
    final theme = Theme.of(context); // Utilisation du thème standard de Flutter

    return Scaffold(
      key: scaffoldKey,
      // backgroundColor: theme.primaryBackground, // Exemple
      appBar: AppBar(
        // backgroundColor: theme.primary, // Exemple
        title: Text(
          'Paramètres Bluetooth',
          style: GoogleFonts.interTight( // Exemple d'utilisation de Google Fonts
            // color: theme.primaryText, // Exemple
            // fontSize: 22, // Exemple
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.bluetooth,
                size: 80,
                color: theme.colorScheme.primary, // Utilisation du schéma de couleurs du thème
              ),
              const SizedBox(height: 24),
              Text(
                'Gérez vos appareils Bluetooth et vos connexions directement dans les paramètres de votre téléphone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.interTight(fontSize: 16), // Exemple
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Ouvrir les Paramètres Bluetooth',
                    style: GoogleFonts.interTight(fontSize: 16), // Exemple
                  ),
                ),
                onPressed: _openBluetoothSettings,
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: theme.colorScheme.primary, // Exemple
                //   foregroundColor: theme.colorScheme.onPrimary, // Exemple
                // ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Naviguer en arrière ou vers une autre page si nécessaire
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Alternative si on ne peut pas pop (ex: aller à l'accueil)
                    // context.goNamed(HomePageWidget.routeName); // Nécessite go_router et la définition de HomePageWidget
                  }
                },
                child: Text(
                  'Retour',
                  style: GoogleFonts.interTight(
                    color: theme.colorScheme.secondary, // Exemple
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
