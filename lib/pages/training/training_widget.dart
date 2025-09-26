import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'training_model.dart';
export 'training_model.dart';

class TrainingWidget extends StatefulWidget {
  const TrainingWidget({super.key});

  static String routeName = 'Training';
  static String routePath = '/training';

  @override
  State<TrainingWidget> createState() => _TrainingWidgetState();
}

class _TrainingWidgetState extends State<TrainingWidget> {
  late TrainingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // ✅ Variable de connexion Bluetooth (factice pour l’instant)
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrainingModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.pushNamed(TrainingWidget.routeName);
        break;
      case 1:
        context.pushNamed(ResultsWidget.routeName);
        break;
      case 2:
        context.pushNamed(BluetoothWidget.routeName);
        break;
      case 3:
        await launchURL('https://www.a-la-pointe.fr/shop');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(HomePageWidget.routeName);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/picto-alp-bleu_(1).png',
                width: 70,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),

        // ✅ Corps : affiche en fonction de la connexion
        body: SafeArea(
          top: true,
          child: isConnected
              ? _buildTrainingForm(context)
              : _buildNotConnected(context),
        ),

        // ✅ Navigation
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: FlutterFlowTheme.of(context).secondary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_gymnastics),
              label: 'Training',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.data_thresholding_sharp),
              label: 'Résultats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_sharp),
              label: 'Bluetooth',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Boutique',
            ),
          ],
        ),

        // ✅ Mentions légales
        bottomSheet: Container(
          height: 40,
          color: FlutterFlowTheme.of(context).alternate,
          alignment: Alignment.center,
          child: InkWell(
            onTap: () async {
              await launchURL('https://www.a-la-pointe.fr/terms');
            },
            child: Text(
              'Mentions légales',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: GoogleFonts.inter().fontFamily,
                fontWeight:
                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle:
                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Écran quand aucune cible n’est connectée
  Widget _buildNotConnected(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled,
                size: 80, color: FlutterFlowTheme.of(context).secondaryText),
            const SizedBox(height: 20),
            Text(
              "Aucune cible connectée",
              style: FlutterFlowTheme.of(context).titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "Active ton Bluetooth et connecte une cible\navant de commencer l’entraînement.",
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.pushNamed(BluetoothWidget.routeName);
              },
              icon: const Icon(Icons.bluetooth),
              label: const Text("Se connecter à une cible"),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Formulaire complet quand connecté
  Widget _buildTrainingForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 16),
          FlutterFlowAdBanner(
            width: MediaQuery.sizeOf(context).width,
            height: 50.0,
            showsTestAd: true,
          ),
          const SizedBox(height: 20),
          Text(
            'Entraînements',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              fontFamily: GoogleFonts.interTight().fontFamily,
              fontWeight:
              FlutterFlowTheme.of(context).titleLarge.fontWeight,
              fontStyle:
              FlutterFlowTheme.of(context).titleLarge.fontStyle,
              color: FlutterFlowTheme.of(context).secondary,
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown
          FlutterFlowDropDown<String>(
            controller: _model.dropDownValueController ??=
                FormFieldController<String>(null),
            options: ['Initiation', 'Loisir', 'Performeur', 'Série'],
            onChanged: (val) =>
                safeSetState(() => _model.dropDownValue = val),
            width: 200.0,
            height: 40.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            hintText: 'Type d\'entraînement',
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: Colors.transparent,
            borderWidth: 0.0,
            borderRadius: 8.0,
            margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            hidesUnderline: true,
            isOverButton: false,
            isSearchable: false,
            isMultiSelect: false,
          ),

          const SizedBox(height: 20),
          // Radio boutons
          FlutterFlowRadioButton(
            options: ['Sabre', 'Épée', 'Fleuret'].toList(),
            onChanged: (val) => safeSetState(() {}),
            controller: _model.radioButtonValueController ??=
                FormFieldController<String>(null),
            optionHeight: 32.0,
            textStyle: FlutterFlowTheme.of(context).labelMedium,
            selectedTextStyle: FlutterFlowTheme.of(context).bodyMedium,
            buttonPosition: RadioButtonPosition.left,
            direction: Axis.vertical,
            radioButtonColor: FlutterFlowTheme.of(context).secondary,
            inactiveRadioButtonColor:
            FlutterFlowTheme.of(context).secondaryText,
            toggleable: false,
            horizontalAlignment: WrapAlignment.start,
            verticalAlignment: WrapCrossAlignment.start,
          ),

          const SizedBox(height: 20),
          Text(
            'Intensité',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          Slider(
            activeColor: FlutterFlowTheme.of(context).secondary,
            inactiveColor: FlutterFlowTheme.of(context).alternate,
            min: 0.0,
            max: 10.0,
            value: _model.sliderValue ??= 5.0,
            onChanged: (newValue) {
              newValue = double.parse(newValue.toStringAsFixed(2));
              safeSetState(() => _model.sliderValue = newValue);
            },
          ),

          CheckboxListTile(
            value: _model.checkboxListTileValue1 ??= true,
            onChanged: (newValue) {
              safeSetState(
                      () => _model.checkboxListTileValue1 = newValue!);
            },
            title: const Text('Silencieux'),
            activeColor: FlutterFlowTheme.of(context).secondary,
            checkColor: FlutterFlowTheme.of(context).info,
          ),
          CheckboxListTile(
            value: _model.checkboxListTileValue2 ??= true,
            onChanged: (newValue) {
              safeSetState(
                      () => _model.checkboxListTileValue2 = newValue!);
            },
            title: const Text('Buzzer'),
            activeColor: FlutterFlowTheme.of(context).secondary,
            checkColor: FlutterFlowTheme.of(context).info,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
