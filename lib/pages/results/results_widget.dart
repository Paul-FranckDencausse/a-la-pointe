import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'results_model.dart';
export 'results_model.dart';

class ResultsWidget extends StatefulWidget {
  const ResultsWidget({super.key});

  static String routeName = 'Results';
  static String routePath = '/results';

  @override
  State<ResultsWidget> createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  late ResultsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultsModel());

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
          title: InkWell(
            onTap: () async {
              context.pushNamed(HomePageWidget.routeName);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/picto-alp-bleu_(1).png',
                width: 56,
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
                // Navigation Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => context.pushNamed(TrainingWidget.routeName),
                      child: Icon(
                        Icons.sports_gymnastics,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pushNamed(ResultsWidget.routeName),
                      child: Icon(
                        Icons.data_thresholding_sharp,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.pushNamed(BluetoothWidget.routeName),
                      child: Icon(
                        Icons.bluetooth_sharp,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await launchURL('https://www.a-la-pointe.fr/shop');
                      },
                      child: Icon(
                        Icons.shopping_cart,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                FlutterFlowAdBanner(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  showsTestAd: true,
                ),

                const SizedBox(height: 20),

                Text(
                  'Résultats',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                    ),
                    color: FlutterFlowTheme.of(context).secondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Line Chart
                Container(
                  width: double.infinity,
                  height: 230,
                  child: FlutterFlowLineChart(
                    data: [
                      FFLineChartData(
                        xData: List.generate(5,
                                (index) => random_data.randomInteger(0, 10)),
                        yData: List.generate(5,
                                (index) => random_data.randomInteger(0, 10)),
                        settings: LineChartBarData(
                          color: FlutterFlowTheme.of(context).secondary,
                          barWidth: 2.0,
                          isCurved: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                        ),
                      )
                    ],
                    chartStylingInfo: ChartStylingInfo(
                      backgroundColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                      showBorder: false,
                    ),
                    axisBounds: AxisBounds(),
                    xAxisLabelInfo: AxisLabelInfo(
                      reservedSize: 32,
                    ),
                    yAxisLabelInfo: AxisLabelInfo(
                      reservedSize: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                CircularPercentIndicator(
                  percent: 0.5,
                  radius: 60,
                  lineWidth: 12,
                  animation: true,
                  progressColor: FlutterFlowTheme.of(context).secondary,
                  backgroundColor: FlutterFlowTheme.of(context).accent4,
                  center: Text(
                    '50%',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80), // Pour laisser de la place avant le footer
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 60,
          color: FlutterFlowTheme.of(context).alternate,
          child: Center(
            child: InkWell(
              onTap: () async {
                await launchURL('https://www.a-la-pointe.fr/terms');
              },
              child: Text(
                'Mentions légales',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
