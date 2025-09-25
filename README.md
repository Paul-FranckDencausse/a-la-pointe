# À la Pointe - Application Mobile

Application mobile Flutter pour la société A la pointe.

## Table des Matières

- [À Propos](#à-propos)
- [Fonctionnalités](#fonctionnalités)
- [Captures d'Écran (Optionnel)](#captures-décran-optionnel)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Structure du Projet](#structure-du-projet)
- [Navigation](#navigation)
- [Dépendances Clés](#dépendances-clés)
- [Contribution (Optionnel)](#contribution-optionnel)
- [Licence (Optionnel)](#licence-optionnel)
- [Contact (Optionnel)](#contact-optionnel)

## À Propos

Application mobile Flutter pour gérer des capteurs ESP32 connectés en Bluetooth fonctionnant
comme cibles pour l'entraînement à l'escrime.L'application gère la connectivité Bluetooth et
permet d'afficher les données reçues par les capteurs, elle renvoie vers les cibles un 
programme d'entraînement au choix parmi quatre.

## Fonctionnalités

Listez les principales fonctionnalités de l'application :

*   **Accueil :** Navigation principale et accès aux différentes sections.
*   **Gestion des Entraînements :**
    *  4 programmes différents
    *  Initiation
    * Loisir
    * Performeur
    * Série
    * Un mode silencieux
*   **Visualisation des Résultats :**
    *  Récupération de l'UUID par Bluetooth.
    *  Affichage des données via des graphiques.
*   **Connectivité Bluetooth :**
    *   Activation directe du Bluetooth (Android) , redirection vers les réglages (IOS).
    * Affichage des appareils connectés et ceux disponibles.
    * Déconnexion.
*   **Boutique en Ligne :**
    *   Redirection vers la boutique web `https://www.a-la-pointe.fr/shop`]
*   **Mentions Légales :**
    *   Accès aux termes et conditions via `https://www.a-la-pointe.fr/terms`
*   **Publicité :**
    *   Utilisation de Google AdMob pour l'affichage de publicité.

## Captures d'Écran 

![img.png](img.png)
![img_1.png](img_1.png)

## Prérequis

Avant de pouvoir exécuter ou développer cette application, assurez-vous d'avoir installé les éléments suivants sur votre système :

1.  **SDK Flutter :**
    *   Téléchargez et installez le SDK Flutter en suivant les instructions officielles sur le site [flutter.dev](https://flutter.dev/docs/get-started/install).
    *   Assurez-vous que la commande `flutter` est accessible depuis votre terminal (vérifiez votre variable d'environnement PATH).
    *   Exécutez `flutter doctor` pour vérifier que votre installation de Flutter est correcte et pour identifier d'éventuels problèmes de configuration.

2.  **Android Studio :**
    *   Téléchargez et installez la dernière version d'Android Studio depuis le site officiel [developer.android.com/studio](https://developer.android.com/studio).
    *   Pendant l'installation d'Android Studio, assurez-vous que les composants suivants sont installés :
        *   Android SDK
        *   Android SDK Platform-Tools
        *   Android SDK Build-Tools
    *   Dans Android Studio, installez les plugins `Flutter` et `Dart` :
        *   Allez dans `File > Settings > Plugins` (ou `Android Studio > Preferences > Plugins` sur macOS).
        *   Recherchez "Flutter" dans la marketplace, installez-le (cela installera également le plugin Dart automatiquement).
        *   Redémarrez Android Studio après l'installation des plugins.

3.  **Un émulateur Android ou un appareil Android physique :**
    *   **Émulateur :** Vous pouvez en configurer un via l'AVD Manager dans Android Studio ("Tools" > "AVD Manager").
    *   **Appareil physique :** Activez les "Options pour les développeurs" et le "Débogage USB" sur votre appareil.


## Exécuter l'application avec Android Studio

Pour lancer l'application sur un émulateur Android ou un appareil physique connecté via Android Studio :

1.  **Ouvrez le projet :**
    *   Lancez Android Studio.
    *   Choisissez "Open" (ou "Open an Existing Project").
    *   Naviguez jusqu'au dossier racine de votre projet Flutter (`a-la-pointe`) et sélectionnez-le. Attendez qu'Android Studio indexe les fichiers et reconnaisse le projet Flutter.
2.  **Sélectionnez un appareil cible :**
    *En haut de la fenêtre d'Android Studio, vous verrez une liste déroulante d'appareils (cela pourrait afficher "No Devices" initialement).
    *   **Pour un émulateur :** Si vous avez déjà configuré des émulateurs Android, sélectionnez-en un dans la liste. Sinon, vous pouvez en créer un via "Tools" > "AVD Manager" (ou l'icône AVD Manager dans la barre d'outils).
    *   **Pour un appareil physique :**
        *   Activez les "Options pour les développeurs" et le "Débogage USB" sur votre appareil Android. (Recherchez en ligne "activer débogage USB [modèle de votre téléphone]" pour des instructions spécifiques).
        *   Connectez votre appareil à votre ordinateur via un câble USB.
        *   Autorisez le débogage USB sur votre téléphone si une invite apparaît.
        *   Votre appareil devrait maintenant apparaître dans la liste des appareils cibles d'Android Studio.
3.  **Configurez le point d'entrée (si nécessaire) :**
    *   Assurez-vous que le fichier `main.dart` (généralement `lib/main.dart`) est sélectionné comme point d'entrée de l'application. Android Studio le détecte souvent automatiquement pour les projets Flutter.
4.  **Exécutez l'application :**
    *   Cliquez sur le bouton vert "Run 'main.dart'" (l'icône de lecture ▶️) dans la barre d'outils supérieure.
    *   Alternativement, vous pouvez utiliser le raccourci `Shift + F10` (Windows/Linux) ou `Control + R` (macOS).
5.  **Attendez la compilation et le lancement :**
    *   Android Studio va compiler l'application Flutter et l'installer sur l'appareil ou l'émulateur sélectionné. La première compilation peut prendre un certain temps.
    *   Une fois lancée, vous devriez voir votre application s'exécuter. La console "Run" dans Android Studio affichera les journaux de l'application, y compris les messages de `debugPrint()` et les éventuelles erreurs.

**Utiliser le Hot Reload / Hot Restart :**
*   Pendant que l'application est en cours d'exécution, vous pouvez modifier votre code Dart.
*   **Hot Reload (Ctrl + \` ou `Cmd + \`) :** Applique les changements de code rapidement sans redémarrer l'application, préservant l'état actuel. Idéal pour les changements d'UI.
*   **Hot Restart (Ctrl + Shift + \` ou `Cmd + Shift + \`) :** Redémarre l'application mais est plus rapide qu'un redémarrage complet. L'état de l'application est perdu.

