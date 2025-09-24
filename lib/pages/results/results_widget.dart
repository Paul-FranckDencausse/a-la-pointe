// lib/pages/results/results_widget.dart

import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'results_model.dart';
export 'results_model.dart';

// 🔹 BLE
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ResultsWidget extends StatefulWidget {
  final String? deviceId;

  const ResultsWidget({
    super.key,
    this.deviceId,
  });

  static String routeName = 'Results';
  static String routePath = '/results';

  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  late ResultsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyCharacteristic;

  // Données dynamiques
  List<String> hitsLog = [];
  List<int> reactionTimes = [];
  int hitCount = 0;
  int maxHits = 5;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultsModel());

    if (widget.deviceId != null) {
      debugPrint("📡 Connexion à l'appareil: ${widget.deviceId}");
      connectToDevice(widget.deviceId!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    connectedDevice?.disconnect();
    _model.dispose();
    super.dispose();
  }

  /// 🔹 Connexion BLE
  Future<void> connectToDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect();
      connectedDevice = device;

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.notify) {
            notifyCharacteristic = char;
            await char.setNotifyValue(true);
            char.value.listen((value) {
              final msg = String.fromCharCodes(value);
              parseSensorMessage(msg);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Erreur connexion BLE: $e");
    }
  }

  /// 🔹 Parse les messages envoyés par l’ESP32
  void parseSensorMessage(String msg) {
    debugPrint("📩 Message reçu: $msg");

    if (msg.contains("HIT")) {
      hitsLog.add(msg);
      hitCount++;

      // Extraire le temps de réaction
      final regex = RegExp(r"Reaction time: (\d+) ms");
      final match = regex.firstMatch(msg);
      if (match != null) {
        final reactionTime = int.parse(match.group(1)!);
        reactionTimes.add(reactionTime);
        debugPrint("⏱ Temps de réaction: $reactionTime ms");
      }

      // Mise à jour du modèle pour le graphique et le pourcentage
      setState(() {
        _model.lineChartData = [
          FFLineChartData(
            xData: List.generate(reactionTimes.length, (i) => i + 1),
            yData: reactionTimes,
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
          ),
        ];
        _model.percentValue = (hitCount / maxHits).clamp(0.0, 1.0);
      });
    }
  }

  /// 🔹 Navigation bas
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
            queryParameters:
            widget.deviceId != null ? {'deviceId': widget.deviceId!} : {},
          );
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

  // ======================================================
  // ====================== BUILD =========================
  // ======================================================
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

                // Titre
                Text(
                  widget.deviceId != null
                      ? 'Résultats pour Appareil (...${widget.deviceId!.substring(widget.deviceId!.length - 5)})'
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

                // Graphique
                Container(
                  width: double.infinity,
                  height: 230,
                  child: (_model.lineChartData == null ||
                      _model.lineChartData!.isEmpty)
                      ? Center(
                    child: Text(
                      widget.deviceId == null
                          ? "Aucune cible connectée.\nConnectez-vous via Bluetooth pour afficher les résultats."
                          : "Aucune donnée pour l'instant.",
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  )
                      : FlutterFlowLineChart(
                    data: _model.lineChartData!,
                    chartStylingInfo: ChartStylingInfo(
                      backgroundColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                      showBorder: false,
                    ),
                    axisBounds: AxisBounds(),
                    xAxisLabelInfo: AxisLabelInfo(
                        reservedSize: 32, showLabels: true),
                    yAxisLabelInfo: AxisLabelInfo(
                        reservedSize: 40, showLabels: true),
                  ),
                ),

                const SizedBox(height: 20),

                // Pourcentage
                CircularPercentIndicator(
                  percent: widget.deviceId == null ? 0.0 : _model.percentValue,
                  radius: 70,
                  lineWidth: 14,
                  animation: true,
                  progressColor: FlutterFlowTheme.of(context).secondary,
                  backgroundColor:
                  FlutterFlowTheme.of(context).accent4.withOpacity(0.5),
                  center: Text(
                    widget.deviceId == null
                        ? "–"
                        : "${(_model.percentValue * 100).toStringAsFixed(0)}%",
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                ),

                const SizedBox(height: 20),

                // Logs
                if (widget.deviceId == null)
                  Text(
                    "Connectez-vous à une cible via la page Bluetooth pour voir les résultats.",
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  )
                else if (hitsLog.isEmpty)
                  Text(
                    "Aucun hit enregistré pour le moment.",
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    hitsLog.map((msg) => Text("• $msg")).toList(),
                  ),
              ],
            ),
          ),
        ),

        // ✅ Navigation placée correctement
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: FlutterFlowTheme.of(context).secondary,
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center), label: 'Training'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Résultats'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bluetooth_sharp), label: 'Bluetooth'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined), label: 'Boutique'),
          ],
        ),
      ),
    );
  }
}
