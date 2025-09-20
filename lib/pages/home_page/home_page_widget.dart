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
              padding: const EdgeInsets.all(16.0), // Padding général pour la section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centre les éléments horizontalement
                children: [
                  // Titre
                  Text(
                    'Bienvenue chez À la Pointe !',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                      color: FlutterFlowTheme.of(context).primaryText, // Ou une autre couleur
                      fontWeight: FontWeight.bold, // Mettre en gras
                      useGoogleFonts: GoogleFonts.asMap().containsKey(FlutterFlowTheme.of(context).headlineMediumFamily),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image de présentation
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.8, // 80% de la largeur de l'écran
                    constraints: const BoxConstraints(
                      maxHeight: 250, // Hauteur maximale pour l'image
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // Coins arrondis pour l'image
                      boxShadow: [ // Ombre portée subtile
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect( // Pour appliquer le borderRadius à l'image
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/cibles_connectees.png', // <<< VOTRE IMAGE ICI
                        fit: BoxFit.cover, // Ou BoxFit.contain selon votre image
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Paragraphe descriptif
                  Text(
                    'Découvrez nos cibles d\'escrime intelligentes, connectées en Bluetooth ! Révolutionnez vos entraînements grâce à une analyse précise de vos performances et un suivi en temps réel. Conçues pour les passionnés et les professionnels de l\'escrime.',
                    textAlign: TextAlign.center, // Ou TextAlign.justify pour un look plus formel
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                      color: FlutterFlowTheme.of(context).secondaryText, // Ou une autre couleur
                      useGoogleFonts: GoogleFonts.asMap().containsKey(FlutterFlowTheme.of(context).bodyLargeFamily),
                    ),
                  ),
                  const SizedBox(height: 24), // Espace avant l'élément suivant ou la fin
                ],
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
        ),

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
