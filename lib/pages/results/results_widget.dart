// lib/pages/results/results_widget.dart

import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:convert';                   // ← POUR JSON
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'results_model.dart';
export 'results_model.dart';

// BLE
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ResultsWidget extends StatefulWidget {
  final String? deviceId;

  const ResultsWidget({super.key, this.deviceId});

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
  List<int> reactionTimes = [];
  List<String> hitsLog = [];

  int hitCount = 0;
  int maxHits = 10;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultsModel());

    if (widget.deviceId != null) {
      connectToDevice(widget.deviceId!);
    }
  }

  @override
  void dispose() {
    connectedDevice?.disconnect();
    _model.dispose();
    super.dispose();
  }

  /* ---------------------------------------------------
     CONNEXION BLE + LECTURE NOTIFICATIONS JSON
     --------------------------------------------------- */
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
            char.value.listen(onBleData);
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Erreur connexion BLE: $e");
    }
  }

  /* ---------------------------------------------------
     PARSE JSON REÇU
     --------------------------------------------------- */
  void onBleData(List<int> rawData) {
    final str = utf8.decode(rawData);
    debugPrint("📩 JSON reçu → $str");

    dynamic json;
    try {
      json = jsonDecode(str);
    } catch (e) {
      debugPrint("⚠️ JSON invalide");
      return;
    }

    // ▬▬▬▬▬▬ EVENT TEMPS RÉEL ▬▬▬▬▬▬
    if (json is Map && json['event'] == 'TARGET') {
      final int target = json['data']['target'];
      final int ts = json['ts'];

      hitsLog.add("Cible $target à ${ts}ms");
      reactionTimes.add(ts);

      setState(() {
        hitCount++;
        _updateChart();
      });
    }

    // ▬▬▬▬▬▬ RÉSULTATS COMPLETS ▬▬▬▬▬▬
    if (json is Map && json['results'] != null) {
      final List results = json['results'];

      reactionTimes.clear();
      hitsLog.clear();

      for (var entry in results) {
        reactionTimes.add(entry['reaction']);
        hitsLog.add("Cible ${entry['target']} → ${entry['reaction']}ms");
      }

      setState(() {
        hitCount = reactionTimes.length;
        _updateChart();
      });
    }
  }

  /* ---------------------------------------------------
     MET À JOUR LE GRAPH
     --------------------------------------------------- */
  void _updateChart() {
    _model.percentValue = (hitCount / maxHits).clamp(0.0, 1.0);

    _model.lineChartData = [
      FFLineChartData(
        xData: List.generate(reactionTimes.length, (i) => i + 1),
        yData: reactionTimes,
        settings: LineChartBarData(
          color: FlutterFlowTheme.of(context).secondary,
          barWidth: 3,
          isCurved: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: FlutterFlowTheme.of(context).secondary.withOpacity(0.2),
          ),
        ),
      ),
    ];
  }

  /* ---------------------------------------------------
     NAVIGATION
     --------------------------------------------------- */
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.pushNamed(TrainingWidget.routeName);
        break;
      case 1:
        context.pushNamed(
          ResultsWidget.routeName,
          queryParameters: widget.deviceId != null
              ? {'deviceId': widget.deviceId!}
              : {},
        );
        break;
      case 2:
        context.pushNamed(BluetoothWidget.routeName);
        break;
      case 3:
        launchURL("https://www.a-la-pointe.fr/shop");
        break;
    }
  }

  /* ---------------------------------------------------
     BUILD UI
     --------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,

      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 1,
        title: Text(
          "Résultats",
          style: FlutterFlowTheme.of(context).titleMedium,
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FlutterFlowAdBanner(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                showsTestAd: true,
              ),

              const SizedBox(height: 20),

              Text(
                "Temps de réaction",
                style: FlutterFlowTheme.of(context).titleLarge,
              ),

              const SizedBox(height: 20),

              // ▬▬▬▬▬▬ GRAPHIQUE ▬▬▬▬▬▬
              Container(
                height: 220,
                child: _model.lineChartData == null ||
                    _model.lineChartData!.isEmpty
                    ? Center(
                  child: Text("Aucune donnée reçue."),
                )
                    : FlutterFlowLineChart(
                  data: _model.lineChartData!,
                  chartStylingInfo: ChartStylingInfo(
                    showGrid: true,
                    showBorder: false,
                  ),
                  axisBounds: AxisBounds(),
                  xAxisLabelInfo: AxisLabelInfo(showLabels: true),
                  yAxisLabelInfo: AxisLabelInfo(showLabels: true),
                ),
              ),

              const SizedBox(height: 20),

              // ▬▬▬▬▬▬ POURCENTAGE ▬▬▬▬▬▬
              CircularPercentIndicator(
                percent: _model.percentValue,
                radius: 70,
                lineWidth: 14,
                animation: true,
                progressColor: FlutterFlowTheme.of(context).secondary,
                center: Text(
                  "${(_model.percentValue * 100).toStringAsFixed(0)}%",
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
              ),

              const SizedBox(height: 20),

              // ▬▬▬▬▬▬ LOGS TEXTE ▬▬▬▬▬▬
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hitsLog.map((e) => Text("• $e")).toList(),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: FlutterFlowTheme.of(context).secondary,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_gymnastics), label: "Training"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Résultats"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth), label: "Bluetooth"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Boutique"),
        ],
      ),

    );
  }
}

