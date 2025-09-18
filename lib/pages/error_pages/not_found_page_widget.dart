import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Pour pouvoir revenir en arrière ou aller à l'accueil

// Optionnel: Si vous utilisez le thème FlutterFlow
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_widgets.dart'; // Pour FFButtonWidget

class NotFoundPageWidget extends StatelessWidget {
  // Optionnel: Si vous voulez que cette page soit accessible via un nom de route direct
  // static const String routeName = 'NotFoundPage';
  // static const String routePath = '/404'; // Attention à ne pas créer de conflit

  final GoRouterState? state; // Pour afficher l'URL qui a causé l'erreur

  const NotFoundPageWidget({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    // Adaptez avec FlutterFlowTheme si vous l'utilisez
    final theme = Theme.of(context);
    // final ffTheme = FlutterFlowTheme.of(context);

    return Scaffold(
      // appBar: AppBar( // Optionnel, selon le design souhaité
      //   title: Text("Page non trouvée", style: TextStyle(color: ffTheme.primaryText)),
      //   backgroundColor: ffTheme.secondaryBackground,
      //   iconTheme: IconThemeData(color: ffTheme.primaryText),
      // ),
      backgroundColor: theme.colorScheme.background, // ffTheme.primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error, // ffTheme.error,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                "Oops! Page non trouvée",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  // color: ffTheme.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (state?.uri != null) // Afficher l'URL erronée si disponible
                Text(
                  "La ressource à l'adresse '${state!.uri.toString()}' n'a pas pu être trouvée.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge, // ffTheme.secondaryText,
                )
              else
                Text(
                  "La page que vous cherchez n'existe pas ou a été déplacée.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge, // ffTheme.secondaryText,
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon( // FFButtonWidget
                icon: const Icon(Icons.home_rounded),
                label: const Text("Retour à l'accueil"),
                onPressed: () {
                  // Naviguer vers la page d'accueil.
                  // Assurez-vous que la route '/' ou le nom de votre page d'accueil est correct.
                  context.go('/'); // Ou context.goNamed(HomePageWidget.routeName);
                },
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: ffTheme.primary,
                //   foregroundColor: Colors.white,
                //   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                //   textStyle: ffTheme.titleSmall.override(
                //                 fontFamily: ffTheme.titleSmallFamily,
                //                 color: Colors.white,
                //               ),
                // ),
                // options: FFButtonOptions( // Pour FFButtonWidget
                //   width: 200,
                //   height: 50,
                //   color: ffTheme.primary,
                //   textStyle: ffTheme.titleSmall.override(
                //                 fontFamily: ffTheme.titleSmallFamily,
                //                 color: Colors.white,
                //               ),
                //   elevation: 2,
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/'); // Fallback si on ne peut pas pop
                  }
                },
                child: const Text("Retourner en arrière"),
                // style: TextButton.styleFrom(foregroundColor: ffTheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

