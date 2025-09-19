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
          leading: Opacity(
            opacity: 0.0,
            child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Opacity(
                opacity: 0.0,
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(HomePageWidget.routeName);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/picto-alp-bleu_(1).png',
                    width: 70.1,
                    height: 56.6,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView( // ✅ Pour éviter l’overflow
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(TrainingWidget.routeName);
                      },
                      child: Icon(
                        Icons.sports_gymnastics,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36.0,
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () async {
                        context.pushNamed(ResultsWidget.routeName);
                      },
                      child: Icon(
                        Icons.data_thresholding_sharp,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36.0,
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () async {
                        context.pushNamed(BluetoothWidget.routeName);
                      },
                      child: Icon(
                        Icons.bluetooth_sharp,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36.0,
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () async {
                        await launchURL('https://www.a-la-pointe.fr/shop');
                      },
                      child: Icon(
                        Icons.shopping_cart,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36.0,
                      ),
                    ),
                  ],
                ),
                FlutterFlowAdBanner(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 50.0,
                  showsTestAd: true,
                ),
                SizedBox(height: 20),
                Text(
                  'Entraînements',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context)
                          .titleLarge
                          .fontWeight,
                      fontStyle: FlutterFlowTheme.of(context)
                          .titleLarge
                          .fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondary,
                    letterSpacing: 0.0,
                  ),
                ),
                SizedBox(height: 20),
                FlutterFlowDropDown<String>(
                  controller: _model.dropDownValueController ??= FormFieldController<String>(null),
                  options: ['Initiation', 'Loisir', 'Performeur', 'Série'],
                  onChanged: (val) => safeSetState(() => _model.dropDownValue = val),
                  width: 200.0,
                  height: 40.0,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium, // ✅ obligatoire
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
                  margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0), // ✅ obligatoire
                  hidesUnderline: true,
                  isOverButton: false,
                  isSearchable: false,
                  isMultiSelect: false,
                ),

                SizedBox(height: 20),
                FlutterFlowRadioButton(
                  options: ['Sabre', 'Epée', 'Fleuret'].toList(),
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
                SizedBox(height: 20),
                Text('Intensité',
                    style: FlutterFlowTheme.of(context).bodyMedium),
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
                    safeSetState(() => _model.checkboxListTileValue1 = newValue!);
                  },
                  title: Text('Contre-la-montre'),
                  activeColor: FlutterFlowTheme.of(context).secondary,
                  checkColor: FlutterFlowTheme.of(context).info,
                ),
                CheckboxListTile(
                  value: _model.checkboxListTileValue2 ??= true,
                  onChanged: (newValue) {
                    safeSetState(() => _model.checkboxListTileValue2 = newValue!);
                  },
                  title: Text('Chronométré'),
                  activeColor: FlutterFlowTheme.of(context).secondary,
                  checkColor: FlutterFlowTheme.of(context).info,
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 80,
                  color: FlutterFlowTheme.of(context).alternate,
                  alignment: Alignment.center,
                  child: Text('Mentions légales',
                      style: FlutterFlowTheme.of(context).bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
