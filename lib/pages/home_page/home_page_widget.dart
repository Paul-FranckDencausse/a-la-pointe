import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/pages/training/training_widget.dart';
import '/pages/results/results_widget.dart';
import '/pages/bluetooth/bluetooth_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _selectedIndex = 0;

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
          title: InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(HomePageWidget.routeName);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/picto-alp-bleu_(1).png',
                width: 70,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ✅ Bannière pub
                FlutterFlowAdBanner(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  showsTestAd: true,
                ),

                const SizedBox(height: 24),

                // ✅ Section Présentation "À la Pointe"
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Titre
                      Text(
                        'Bienvenue chez À la Pointe !',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                          fontFamily: FlutterFlowTheme.of(context)
                              .headlineMediumFamily,
                          color:
                          FlutterFlowTheme.of(context).primaryText,
                          fontWeight: FontWeight.bold,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              FlutterFlowTheme.of(context)
                                  .headlineMediumFamily),
                        ),
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () async {
                          const videoUrl = 'https://www.youtube.com/watch?v=gLiqPg28OK0'; // <<< VOTRE URL YOUTUBE ICI
                          if (await canLaunchUrl(Uri.parse(videoUrl))) {
                            await launchUrl(Uri.parse(videoUrl));
                          } else {
                            // Gérer l'erreur si l'URL ne peut pas être lancée
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Impossible d\'ouvrir la vidéo.')),
                            );
                            debugPrint('Could not launch $videoUrl');
                          }
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          constraints: const BoxConstraints(
                            maxHeight: 200, // Ajustez la hauteur pour une miniature
                            minHeight: 150, // Hauteur minimale optionnelle
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300], // Couleur de fond pendant le chargement
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Miniature de la vidéo depuis le web
                                Image.network(
                                  'https://img.youtube.com/vi/gLiqPg28OK0/maxresdefault.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity, // Pour remplir le Container
                                  height: double.infinity, // Pour remplir le Container
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                    return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                  },
                                ),
                                // Icône "Play" superposée (optionnel mais recommandé)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 40.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Paragraphe descriptif
                      Text(
                        'Découvrez nos cibles d\'escrime intelligentes, connectées en Bluetooth ! Révolutionnez vos entraînements grâce à une analyse précise de vos performances et un suivi en temps réel. Conçues pour les passionnés et les professionnels de l\'escrime.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                          fontFamily: FlutterFlowTheme.of(context)
                              .bodyLargeFamily,
                          color: FlutterFlowTheme.of(context)
                              .secondaryText,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              FlutterFlowTheme.of(context)
                                  .bodyLargeFamily),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ✅ Navigation officielle
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
        ), // ← VIRGULE IMPORTANTE ICI

        // ✅ Mentions légales sous forme de footer flottant
        bottomSheet: Container(
          height: 40,
          color: FlutterFlowTheme.of(context).alternate,
          child: Center(
            child: InkWell(
              onTap: () async {
                await launchURL('https://www.a-la-pointe.fr/terms');
              },
              child: Text(
                'Mentions légales',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontWeight: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontWeight,
                  fontStyle: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontStyle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
