// lib/pages/results/results_widget.dart

import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Supposons que results_model.dart est correctement importé si createModel en dépend
// ou si ResultsModel est utilisé directement dans _ResultsWidgetState.
// Si vous exportez le modèle depuis ce fichier, l'importation du modèle ici n'est pas strictement pour le widget lui-même.
import 'results_model.dart'; // Cet import est pour la ligne 'export' et pour createModel
export 'results_model.dart';

class ResultsWidget extends StatefulWidget {
  final String? deviceId;

  const ResultsWidget({
    super.key,
    this.deviceId,
  });

  static String routeName = 'Results';
  static String routePath = '/results';

  // 👇👇👇 MÉTHODE MANQUANTE À AJOUTER OU À CORRIGER 👇👇👇
  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  late ResultsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultsModel());

    if (widget.deviceId != null) {
      debugPrint("ResultsWidget a reçu deviceId via constructeur: ${widget.deviceId}");
      fetchResultsForDevice(widget.deviceId!);
    } else {
      debugPrint("ResultsWidget: Aucun deviceId n'a été fourni via constructeur.");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index != 1) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.pushNamed(TrainingWidget.routeName);
        break;
      case 1:
        if (ModalRoute.of(context)?.settings.name != ResultsWidget.routeName) {
          context.pushNamed(
            ResultsWidget.routeName,
            queryParameters: widget.deviceId != null ? {'deviceId': widget.deviceId!} : {},
          );
        } else if (widget.deviceId != null) {
          fetchResultsForDevice(widget.deviceId!);
        }
        break;
      case 2:
        context.pushNamed(BluetoothWidget.routeName);
        break;
      case 3:
        launchURL('https://www.a-la-pointe.fr/shop');
        break;
    }
  }

  void fetchResultsForDevice(String deviceId) {
    debugPrint("Chargement des résultats pour l'appareil : $deviceId");
    setState(() {
      final idBasedSeed = deviceId.hashCode % 10;
      _model.lineChartData = [
        FFLineChartData(
          xData: List.generate(7, (index) => index * (idBasedSeed + 1)),
          yData: List.generate(7, (index) => random_data.randomInteger(5, 20) + idBasedSeed),
          settings: LineChartBarData(
            color: FlutterFlowTheme.of(context).secondary,
            barWidth: 2.5,
            isCurved: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: FlutterFlowTheme.of(context).secondary.withOpacity(0.2),
            ),
          ),
        )
      ];
      _model.percentValue = (random_data.randomInteger(30, 90 + idBasedSeed) / 100.0).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: InkWell(
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
          elevation: 2.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                FlutterFlowAdBanner(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  showsTestAd: true,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.deviceId != null
                      ? 'Résultats pour Cible (...${widget.deviceId!.length > 5 ? widget.deviceId!.substring(widget.deviceId!.length - 5) : widget.deviceId})'
                      : 'Résultats Généraux',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: GoogleFonts.interTight().fontFamily,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).secondary,
                    useGoogleFonts: true,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 230,
                  child: (widget.deviceId == null && (_model.lineChartData == null || _model.lineChartData!.isEmpty))
                      ? Center(child: Text("Aucune donnée de graphique.", style: FlutterFlowTheme.of(context).bodyMedium))
                      : (_model.lineChartData != null && _model.lineChartData!.isNotEmpty)
                      ? FlutterFlowLineChart(
                    data: _model.lineChartData!,
                    chartStylingInfo: ChartStylingInfo(
                      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                      showBorder: false,
                    ),
                    axisBounds: AxisBounds(),
                    xAxisLabelInfo: AxisLabelInfo(reservedSize: 32, showLabels: true),
                    yAxisLabelInfo: AxisLabelInfo(reservedSize: 40, showLabels: true),
                  )
                      : Center(child: Text("Chargement des données du graphique...", style: FlutterFlowTheme.of(context).bodyMedium)),
                ),
                const SizedBox(height: 30),
                CircularPercentIndicator(
                  percent: _model.percentValue,
                  radius: 70,
                  lineWidth: 14,
                  animation: true,
                  animationDuration: 1200,
                  progressColor: FlutterFlowTheme.of(context).secondary,
                  backgroundColor: FlutterFlowTheme.of(context).accent4.withOpacity(0.5),
                  center: Text(
                    '${(_model.percentValue * 100).toStringAsFixed(0)}%',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: GoogleFonts.interTight().fontFamily,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (widget.deviceId != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Rafraîchir les Données"),
                    onPressed: () => fetchResultsForDevice(widget.deviceId!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: FlutterFlowTheme.of(context).primaryText,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: FlutterFlowTheme.of(context).titleSmall,
                    ),
                  )
                else
                  Text(
                    "Connectez-vous à une cible via la page Bluetooth pour voir ses résultats spécifiques.",
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: FlutterFlowTheme.of(context).secondary,
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Training'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Résultats'),
            BottomNavigationBarItem(icon: Icon(Icons.bluetooth_sharp), label: 'Bluetooth'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Boutique'),
          ],
        ),
      ),
    );
  }
}

