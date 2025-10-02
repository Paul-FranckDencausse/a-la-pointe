import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Retrait de flutter_flow_widgets car les boutons standards seront utilisés
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Provider n'est pas utilisé directement ici, mais peut l'être par createModel
// import 'package:provider/provider.dart';
import '/pages/training/training_widget.dart';
import '/pages/results/results_widget.dart';
import '/pages/bluetooth/bluetooth_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {  const HomePageWidget({super.key});

static String routeName = 'HomePage';
static String routePath = '/homePage';

@override
State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0; // Index 0 pour l'accueil/training, ajustez si besoin

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

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le lien : $urlString')),
        );
      }
      debugPrint('Could not launch $urlString');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Ne rien faire si l'onglet actuel est recliqué

    setState(() {
      _selectedIndex = index;
    });

    // Gestion de la navigation
    // Note: Si HomePage est l'index 0 du BottomNavBar,
    // on ne re-navigue pas vers HomePageWidget en cliquant dessus.
    // La navigation est gérée pour les autres onglets.
    switch (index) {
      case 0: // Training (ou Accueil si c'est la même page)
      // Si HomePageWidget est la page pour l'index 0, et que nous y sommes déjà,
      // pas besoin de naviguer. Si "Training" est une page distincte, naviguez.
      // Pour cet exemple, je suppose que l'index 0 est cette HomePage.
      // Si vous voulez que l'index 0 soit "Training", alors :
      // context.pushNamed(TrainingWidget.routeName);
        break;
      case 1: // Résultats
        context.pushNamed(ResultsWidget.routeName);
        break;
      case 2: // Bluetooth
        context.pushNamed(BluetoothWidget.routeName);
        break;
      case 3: // Boutique
        _launchURL('https://www.a-la-pointe.fr/shop');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          automaticallyImplyLeading: false, // Cache le bouton retour si c'est la page principale
          title: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              // Si on est déjà sur la HomePage (index 0), on ne fait rien
              // ou on peut remonter en haut de la page si elle est scrollable.
              if (_selectedIndex != 0) {
                // Si vous avez un ScrollController pour le SingleChildScrollView :
                // _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                // Sinon, si on veut que le logo ramène toujours à l'état initial de la homepage :
                if (ModalRoute.of(context)?.settings.name != HomePageWidget.routePath) {
                  context.pushNamed(HomePageWidget.routeName);
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/picto-alp-bleu_(1).png', // Logo de l'entreprise
                width: 60, // Taille ajustée pour la barre d'app
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            // controller: _scrollController, // Déclarez un _scrollController si besoin
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les enfants en largeur
              children: [
                // Bannière publicitaire
                if (isFirebaseConfigured && showsAds) // Condition pour afficher les pubs
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: FlutterFlowAdBanner(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      showsTestAd: true, // Mettez à false pour la production
                      // adUnitID: 'ca-app-pub- VOTRE_AD_UNIT_ID', // Décommentez pour la prod
                    ),
                  ),

                // Section "Bienvenue" avec l'image de la cible
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: theme.secondaryBackground,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bienvenue chez À la Pointe !',
                          textAlign: TextAlign.center,
                          style: theme.displaySmall.override(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            color: theme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            'assets/images/cible.webp',
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            height: 180, // Hauteur fixe
                            fit: BoxFit.contain, // ou BoxFit.cover 
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Révolutionnez vos entraînements d\'escrime avec nos cibles connectées et intelligentes.',
                          textAlign: TextAlign.center,
                          style: theme.bodyLarge.override(
                            fontFamily: GoogleFonts.readexPro().fontFamily,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Section Vidéo de présentation
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: theme.secondaryBackground,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Découvrez notre technologie',
                          style: theme.titleLarge.override(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            const videoUrl = 'https://www.youtube.com/watch?v=gLiqPg28OK0';
                            _launchURL(videoUrl);
                          },
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black, // Fond noir pour la vidéo
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    'https://img.youtube.com/vi/gLiqPg28OK0/maxresdefault.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: theme.primary,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.play_circle_outline,
                                          size: 60, color: theme.secondaryText);
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 50.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliquez pour voir notre vidéo de présentation.',
                          style: theme.bodyMedium.override(
                            fontFamily: GoogleFonts.readexPro().fontFamily,
                            color: theme.accent2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Paragraphe descriptif plus détaillé (si besoin, sinon retirer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: Text(
                    'Nos cibles d\'escrime intelligentes, connectées en Bluetooth, analysent précisément vos performances et offrent un suivi en temps réel. Elles sont conçues pour les passionnés et les professionnels de l\'escrime souhaitant passer au niveau supérieur.',
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium.override(
                      fontFamily: GoogleFonts.readexPro().fontFamily,
                      color: theme.secondaryText,
                      fontSize: 15,
                      height: 1.5, // Interligne
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Espace avant le footer
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Pour que tous les libellés soient visibles
          backgroundColor: theme.secondaryBackground, // Fond de la barre de navigation
          currentIndex: _selectedIndex,
          selectedItemColor: theme.primary, // Couleur de l'icône et du libellé sélectionnés
          unselectedItemColor: theme.secondaryText, // Couleur pour les non sélectionnés
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.outfit().fontFamily),
          unselectedLabelStyle: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily),
          onTap: _onItemTapped,
          elevation: 8.0, // Ombre sous la barre
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), // Ou Icons.fitness_center si c'est la page training
              activeIcon: Icon(Icons.home_filled), // Icône quand sélectionné
              label: 'Accueil', // Ou 'Training'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Résultats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_outlined),
              activeIcon: Icon(Icons.bluetooth),
              label: 'Bluetooth',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Boutique',
            ),
          ],
        ),
        bottomSheet: Container( // Footer pour les mentions légales
          height: 45,
          color: theme.alternate,
          width: double.infinity,
          child: Center(
            child: InkWell(
              onTap: () async {
                _launchURL('https://www.a-la-pointe.fr/terms');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Mentions légales',
                  style: theme.bodySmall.override(
                    fontFamily: GoogleFonts.readexPro().fontFamily,
                    color: theme.secondaryText,
                    decoration: TextDecoration.underline,
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
