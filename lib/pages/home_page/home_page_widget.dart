import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

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
            opacity: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Opacity(
                opacity: 0,
                child: Container(
                  width: 100,
                  height: 100,
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
                  borderRadius: BorderRadius.circular(8),
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
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
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
                          size: 36,
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          width: 65.25,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(ResultsWidget.routeName);
                        },
                        child: Icon(
                          Icons.data_thresholding_sharp,
                          color: FlutterFlowTheme.of(context).secondary,
                          size: 36,
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          width: 55.04,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(BluetoothWidget.routeName);
                        },
                        child: Icon(
                          Icons.bluetooth_sharp,
                          color: FlutterFlowTheme.of(context).secondary,
                          size: 36,
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          width: 72.64,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
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
                  FlutterFlowAdBanner(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    showsTestAd: true,
                  ),
                  Text(
                    'Connexion\nBluetooth\n interrompue',
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
                      fontWeight: FlutterFlowTheme.of(context)
                          .titleLarge
                          .fontWeight,
                      fontStyle:
                      FlutterFlowTheme.of(context).titleLarge.fontStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ✅ Mentions légales en bas
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
                    fontWeight:
                    FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                    FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
