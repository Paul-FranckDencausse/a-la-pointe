import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

// Import de la logique principale de l'application (si nécessaire pour AppStateNotifier ou autre)
import '/main.dart'; // Assurez-vous que ce chemin est correct et que MyApp est ici ou un équivalent

// Imports des utilitaires FlutterFlow
import '/flutter_flow/flutter_flow_theme.dart'; // Si vous l'utilisez
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart'; // Pour FFParameters, ParamType, etc.
import 'serialization_util.dart'; // Pour deserializeParam

// Importez VOS PAGES ici
import '/pages/home_page/home_page_widget.dart';
import '/pages/training/training_widget.dart';
import '/pages/results/results_widget.dart';
import '/pages/bluetooth/bluetooth_widget.dart';
import '/pages/error_pages/not_found_page_widget.dart'; // << Page 404

export 'package:go_router/go_router.dart';
export 'serialization_util.dart'; // Exportez si d'autres parties de FF l'utilisent

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  // Exemple: Gérer l'état de l'image de démarrage
  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }

// Ajoutez d'autres états globaux d'application ici si nécessaire
// bool loggedIn = false; // Par exemple
// void login() {
//   loggedIn = true;
//   notifyListeners();
// }
// void logout() {
//   loggedIn = false;
//   notifyListeners();
// }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true, // Très utile pendant le développement
  refreshListenable: appStateNotifier, // Permet la redirection basée sur l'état
  navigatorKey: appNavigatorKey,
  errorBuilder: (context, state) => NotFoundPageWidget(state: state), // << Page 404 personnalisée
  routes: [
    FFRoute(
      name: '_initialize', // Souvent utilisé pour le splash ou la logique initiale
      path: '/',
      builder: (context, params) {
        // Ici, vous pourriez avoir un SplashScreen qui décide où aller ensuite
        // ou directement votre HomePageWidget
        return HomePageWidget(); // Ou par exemple: SplashScreen();
      },
      // Exemple de redirection si vous utilisez AppStateNotifier pour l'authentification
      // redirect: (context, state) {
      //   final loggedIn = appStateNotifier.loggedIn;
      //   final loggingIn = state.matchedLocation == '/login'; // Ajustez le chemin de login
      //   if (!loggedIn && !loggingIn) return '/login'; // Redirige vers login si non connecté
      //   if (loggedIn && loggingIn) return '/'; // Redirige vers l'accueil si connecté et sur login
      //   return null; // Pas de redirection
      // },
    ),
    FFRoute(
      name: HomePageWidget.routeName, // Assurez-vous que HomePageWidget.routeName est défini
      path: HomePageWidget.routePath,   // Assurez-vous que HomePageWidget.routePath est défini
      builder: (context, params) => HomePageWidget(),
    ),
    FFRoute(
      name: TrainingWidget.routeName,
      path: TrainingWidget.routePath,
      builder: (context, params) => TrainingWidget(
        // Example: si TrainingWidget prend des paramètres
        // trainingId: params.getParam('id', ParamType.String),
      ),
    ),
    FFRoute(
      name: ResultsWidget.routeName,
      path: ResultsWidget.routePath,
      builder: (context, params) => ResultsWidget(
        // Example: si ResultsWidget prend des paramètres
        // resultsData: params.getParam('data', ParamType.JSON) ?? {},
      ),
    ),
    FFRoute(
      name: BluetoothWidget.routeName,
      path: BluetoothWidget.routePath,
      builder: (context, params) => BluetoothWidget(),
    ),
    // Optionnel: si vous voulez pouvoir naviguer vers NotFoundPageWidget par un nom de route
    // FFRoute(
    //   name: NotFoundPageWidget.routeName, // si défini dans NotFoundPageWidget
    //   path: NotFoundPageWidget.routePath,   // si défini dans NotFoundPageWidget
    //   builder: (context, params) => NotFoundPageWidget(state: params.state),
    // ),
  ].map((r) => r.toRoute(appStateNotifier)).toList(),
);

// --- Extensions et Classes Utilitaires FlutterFlow ---

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
    entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!)),
  );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // Si la page actuelle peut être retirée de la pile, faites-le.
    // Sinon, (si c'est la seule page), allez à la route initiale.
    if (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop();
    } else {
      // Navigue vers la route racine. Assurez-vous que '/' est votre page d'accueil.
      GoRouter.of(this).go('/');
    }
  }

  // Fonctions de navigation FlutterFlow typiques (ajustez si votre FF a des versions différentes)
  void goNamed(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
        Object? extra,
      }) =>
      GoRouter.of(this).goNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  void pushNamed(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
        Object? extra,
      }) =>
      GoRouter.of(this).pushNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  void replaceNamed(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
        Object? extra,
      }) =>
      GoRouter.of(this).replaceNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );
}


extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap); // Combine tous les types de paramètres

  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  bool get isEmpty =>
      state.allParams.isEmpty ||
          (state.allParams.length == 1 &&
              state.extraMap.containsKey(kTransitionInfoKey));

  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;

  bool get hasFutures => state.allParams.entries.any(isAsyncParam);

  Future<bool> completeFutures() => Future.wait(
    state.allParams.entries.where(isAsyncParam).map(
          (param) async {
        final doc = await asyncParams[param.key]!(param.value)
            .onError((_, __) => null);
        if (doc != null) {
          futureParamValues[param.key] = doc;
          return true;
        }
        return false;
      },
    ),
  ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
      String paramName,
      ParamType type, {
        bool isList = false,
      }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      // Gérer les cas où le paramètre n'est pas trouvé.
      // Retourner null ou une valeur par défaut appropriée selon le type T.
      // Par exemple, pour un bool, vous pourriez vouloir false par défaut.
      // if (type == ParamType.bool) return false as T;
      return null;
    }
    final param = state.allParams[paramName];

    // Si le paramètre n'est pas une chaîne, il a probablement été passé via 'extra'
    // et pourrait déjà être du bon type ou nécessiter une conversion simple.
    if (param is! String) {
      if (param is T) return param; // Déjà du bon type
      // Tentatives de conversion pour les types communs si T est différent
      try {
        if (type == ParamType.int && param is num) return param.toInt() as T;
        if (type == ParamType.double && param is num) return param.toDouble() as T;
        if (type == ParamType.String && param != null) return param.toString() as T;
        if (type == ParamType.bool) { // Gestion plus robuste pour bool
          if (param is bool) return param as T;
          if (param is String) return (param.toLowerCase() == 'true') as T;
          if (param is num) return (param != 0) as T;
        }
        // Pour les types plus complexes (DateTime, LatLng, DocumentReference, JSON),
        // la désérialisation à partir de types non-string peut nécessiter une logique spécifique.
        // Si T est un type complexe et 'param' est un Map/List (souvent de JSON),
        // vous pourriez avoir besoin d'une fonction de désérialisation ici.
      } catch (e) {
        print("Erreur de conversion de paramètre '$paramName' (type non-string): $e");
        return null; // ou une valeur par défaut pour T
      }
      return param as T; // Tentative de cast direct si aucune conversion spécifique n'a fonctionné
    }

    // Si le paramètre est une chaîne (venant de pathParameters ou queryParameters),
    // utilisez la fonction de désérialisation.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false, // À utiliser avec un système d'authentification
    this.asyncParams = const {},
    this.routes = const [], // Pour les sous-routes (nested navigation)
    this.redirect,
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;
  final FutureOr<String?> Function(BuildContext, GoRouterState)? redirect;


  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
    name: name,
    path: path,
    redirect: (context, state) {
      // Logique de redirection personnalisée si fournie
      if (redirect != null) {
        return redirect!(context, state);
      }
      // Exemple de redirection basée sur l'authentification (si requireAuth est vrai)
      // final loggedIn = appStateNotifier.loggedIn; // Suppose que loggedIn est dans AppStateNotifier
      // if (requireAuth && !loggedIn) {
      //   return '/login'; // Ajustez vers votre route de login
      // }
      return null; // Pas de redirection
    },
    pageBuilder: (context, state) {
      // fixStatusBarOniOS16AndBelow(context); // Commentez ou supprimez si cette fonction n'est pas définie
      final ffParams = FFParameters(state, asyncParams);

      final pageContent = ffParams.hasFutures
          ? FutureBuilder<bool>(
        future: ffParams.completeFutures(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
            // Afficher une erreur si les paramètres asynchrones ne se chargent pas
            print("Erreur de chargement des paramètres asynchrones pour la route ${state.uri}: ${snapshot.error}");
            return NotFoundPageWidget(state: state); // Ou un widget d'erreur plus spécifique
          }
          return builder(context, ffParams);
        },
      )
          : builder(context, ffParams);

      // Envelopper avec AuthenticatedPage si requireAuth est vrai et un système d'auth est en place
      // final child = requireAuth ? AuthenticatedPage(child: pageContent) : pageContent;
      final child = pageContent; // Simplifié pour l'instant

      final transitionInfo = state.transitionInfo;
      if (transitionInfo.hasTransition) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionDuration: transitionInfo.duration,
          transitionsBuilder: (context, animation, secondaryAnimation, Cchild) =>
              PageTransition(
                type: transitionInfo.transitionType,
                duration: transitionInfo.duration,
                reverseDuration: transitionInfo.duration,
                alignment: transitionInfo.alignment,
                child: Cchild, // Renommé pour éviter conflit de nom
              ).buildTransitions(context, animation, secondaryAnimation, Cchild),
        );
      }
      return MaterialPage(key: state.pageKey, child: child);
    },
    routes: routes,
  );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade, // Type de transition par défaut
    this.duration = const Duration(milliseconds: 300), // Durée par défaut
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

// Assurez-vous que ParamType est défini (généralement dans flutter_flow_util.dart ou serialization_util.dart)
// Exemple de définition si elle manque :
// enum ParamType { String, int, double, bool, DateTime, LatLng, Color, Document, DocumentReference, JSON }

// Assurez-vous que deserializeParam est défini (généralement dans serialization_util.dart)
// Exemple de squelette pour deserializeParam si elle manque :
/*
T? deserializeParam<T>(
  String? value,
  ParamType paramType,
  bool isList,
) {
  if (value == null) {
    return null;
  }
  // Logique de désérialisation basée sur paramType et isList
  // ... (cela peut devenir assez complexe) ...
  // Par exemple:
  // if (paramType == ParamType.int) {
  //   return int.tryParse(value) as T?;
  // }
  // if (paramType == ParamType.String) {
  //   return value as T?;
  // }
  // ... etc. ...
  try {
    if (isList) {
      final List<String> listValues = jsonDecode(value).map<String>((s) => s.toString()).toList();
      // Désérialiser chaque élément de la liste
      // return listValues.map((e) => deserializeParam<T>(e, paramType, false)).whereType<T>().toList() as T;
      // La ligne ci-dessus est conceptuelle, la désérialisation de liste de type T est complexe
      // et dépend du type T lui-même.
      throw UnimplementedError('La désérialisation de liste pour le type $T n\'est pas complètement implémentée dans cet exemple.');
    } else {
      switch (paramType) {
        case ParamType.int:
          return int.tryParse(value) as T?;
        case ParamType.double:
          return double.tryParse(value) as T?;
        case ParamType.String:
          return value as T?;
        case ParamType.bool:
          return (value.toLowerCase() == 'true') as T?;
        // ... autres types ...
        default:
          return null; // Ou jeter une erreur si le type n'est pas géré
      }
    }
  } catch(e) {
    print("Erreur de désérialisation pour la valeur '$value', type $paramType: $e");
    return null;
  }
}
*/
