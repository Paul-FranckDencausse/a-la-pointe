// lib/pages/results/results_model.dart
import '/pages/results/results_widget.dart';
import '/flutter_flow/flutter_flow_util.dart'; // Importe FlutterFlowModel
// Importez d'autres dépendances si ResultsModel en a besoin, par ex. pour FFLineChartData
import '/flutter_flow/flutter_flow_charts.dart';
import 'package:flutter/material.dart'; // Pour BuildContext

// Si ResultsWidget est utilisé comme type générique, importez-le (facultatif si non utilisé directement dans le modèle)
// import 'results_widget.dart';


class ResultsModel extends FlutterFlowModel<ResultsWidget> { // Assurez-vous que le type générique est correct
  ///  State fields for stateful widgets in this page.

  // Champ pour le graphique linéaire
  List<FFLineChartData>? lineChartData;

  // Champ pour la valeur du pourcentage (celui qui manquait)
  double percentValue = 0.0; // Valeur par défaut, par exemple 0.0 pour 0% ou 0.5 pour 50%  // Vous pourriez avoir d'autres champs ici si nécessaire pour votre page Results
  // final unfocusNode = FocusNode(); // Exemple de champ que FlutterFlow pourrait générer

  @override
  void initState(BuildContext context) {
    // Initialisez ici les données si elles ne dépendent pas de paramètres externes
    // ou si elles ont une valeur par défaut complexe.
    // Par exemple, pour lineChartData si vous voulez des données de démarrage :
    // lineChartData = [
    //   FFLineChartData(
    //     xData: [1, 2, 3, 4, 5],
    //     yData: [10, 8, 12, 7, 9],
    //     settings: LineChartBarData(
    //       color: Colors.blue, // Exemple de couleur
    //       barWidth: 2,
    //       isCurved: true,
    //     ),
    //   )
    // ];
    // percentValue est déjà initialisé avec sa valeur par défaut lors de sa déclaration.
  }

  @override
  void dispose() {
    // Si vous avez des FocusNode ou d'autres ressources à libérer :
    // unfocusNode.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
