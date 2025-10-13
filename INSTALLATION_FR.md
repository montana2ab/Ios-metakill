# Guide d'Installation - MetadataKill

Ce guide vous aidera à installer et exécuter MetadataKill sur votre Mac avec Xcode.

## Prérequis

Avant de commencer, assurez-vous d'avoir :
- ✅ macOS 12.0 ou plus récent
- ✅ Xcode 14.0 ou plus récent (15.0+ recommandé)
- ✅ Un compte développeur Apple (pour tester sur appareil)
- ✅ Git installé

## Méthode 1 : Installation Simple (Recommandée)

### Étape 1 : Cloner le Dépôt

```bash
git clone https://github.com/montana2ab/Ios-metakill.git
cd Ios-metakill
```

### Étape 2 : Ouvrir dans Xcode

1. **Lancez Xcode**
2. Allez dans **Fichier > Ouvrir** (ou appuyez sur **⌘O**)
3. Naviguez vers le dossier `Ios-metakill`
4. Sélectionnez le fichier **Package.swift**
5. Cliquez sur **Ouvrir**

Xcode ouvrira le projet en tant que Swift Package.

### Étape 3 : Créer l'Application iOS

Comme il s'agit d'un Swift Package, vous devez créer une application wrapper :

1. Dans Xcode, allez dans **Fichier > Nouveau > Projet**
2. Sélectionnez **iOS > Application**
3. Configurez :
   - **Nom du produit** : `MetadataKill`
   - **Équipe** : Sélectionnez votre équipe de développeur
   - **Identifiant de l'organisation** : `com.votrecompagnie`
   - **Interface** : **SwiftUI**
   - **Langage** : **Swift**
   - **Inclure les tests** : Oui
4. **Enregistrez** dans un dossier **à côté** (pas à l'intérieur) du dossier `Ios-metakill`

### Étape 4 : Lier le Package Local

1. Dans le navigateur de projet Xcode, sélectionnez votre projet
2. Sélectionnez votre cible d'application
3. Allez dans l'onglet **Général**
4. Faites défiler jusqu'à **Frameworks, Libraries, and Embedded Content**
5. Cliquez sur **+**
6. Cliquez sur **Ajouter Autre... > Ajouter une Dépendance de Package...**
7. Cliquez sur **Ajouter Localement...**
8. Naviguez vers le dossier `Ios-metakill` que vous avez cloné
9. Sélectionnez-le et cliquez sur **Ajouter le Package**
10. Sélectionnez la bibliothèque **App**
11. Cliquez sur **Ajouter**

### Étape 5 : Configurer le Fichier Principal de l'App

Remplacez le contenu du fichier Swift principal auto-généré par :

```swift
import SwiftUI
import App

@main
struct MetadataKillApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppState())
        }
    }
}
```

### Étape 6 : Configurer Info.plist

1. Ouvrez le fichier `Info.plist` de votre projet
2. Ajoutez ces entrées (clic droit > **Ajouter une Ligne**) :

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>MetadataKill a besoin d'accéder à vos photos pour supprimer les métadonnées et protéger votre vie privée.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>MetadataKill enregistre les photos nettoyées dans votre bibliothèque.</string>
```

### Étape 7 : Configurer la Signature

1. Sélectionnez votre projet dans Xcode
2. Allez dans **Signature et Capacités**
3. Sélectionnez votre **Équipe**
4. Xcode créera automatiquement un profil de provisionnement

### Étape 8 : Compiler et Exécuter

#### Sur Simulateur
1. Sélectionnez un simulateur dans le menu des appareils (ex: iPhone 15 Pro)
2. Appuyez sur **⌘R** ou cliquez sur le bouton **Lecture**
3. L'application se compilera et se lancera dans le simulateur

#### Sur Appareil Physique
1. Connectez votre iPhone ou iPad avec un câble
2. Sélectionnez-le dans le menu des appareils
3. Appuyez sur **⌘R**
4. L'application s'installera et se lancera sur votre appareil

**Note** : La première fois, vous devez faire confiance au certificat de développeur sur l'appareil :
- Réglages > Général > Gestion VPN et de l'appareil
- Faites confiance à votre certificat de développeur

## Méthode 2 : Construction en Ligne de Commande

### Compiler le Package

```bash
cd Ios-metakill
swift build
```

**Note** : Cette commande ne créera pas une application iOS complète car elle nécessite Xcode pour les frameworks iOS.

## Résolution des Problèmes

### Erreurs de Compilation

**Erreur** : "No such module 'App'"
- **Solution** : Vérifiez que vous avez ajouté le package local correctement à l'Étape 4

**Erreur** : "No such module 'CoreGraphics'"
- **Solution** : Vous devez compiler sur macOS avec Xcode, pas sur Linux

**Erreur** : "Failed to resolve dependencies"
- **Solution** : Exécutez `swift package update` ou utilisez **Fichier > Packages > Mettre à Jour vers les Dernières Versions des Packages** dans Xcode

### Problèmes d'Exécution

**Le sélecteur de photos n'apparaît pas**
- **Solution** : Accordez la permission d'accès à la bibliothèque de photos lorsque demandé

**L'application plante au lancement**
- **Solution** : Vérifiez la console Xcode pour les messages d'erreur
- Assurez-vous que tous les frameworks requis sont liés

**Les fichiers nettoyés ne sont pas trouvés**
- **Solution** : Vérifiez le dossier Documents/MetadataKill_Clean/
- Assurez-vous d'avoir suffisamment d'espace de stockage

## Tester l'Application

### Flux de Test de Base

1. **Lancez l'application**
   - Vous devriez voir l'écran d'accueil avec trois options principales

2. **Testez le nettoyage d'image** :
   - Appuyez sur "Nettoyer les Photos"
   - Appuyez sur "Sélectionner depuis Photos" (nécessite la permission photos)
   - Sélectionnez une image de test
   - Appuyez sur "Nettoyer 1 Photo"
   - Consultez les résultats

3. **Configurez les paramètres** :
   - Appuyez sur l'icône d'engrenage (⚙️)
   - Ajustez les paramètres selon vos besoins
   - Les modifications sont enregistrées automatiquement

4. **Vérifiez la sortie** :
   - Les fichiers nettoyés sont enregistrés dans : Documents/MetadataKill_Clean/
   - Ouvrez l'application Fichiers pour voir les fichiers nettoyés

## Vérifier la Suppression des Métadonnées

Utilisez les outils en ligne de commande pour vérifier :

```bash
# Vérifier les données EXIF avant
exiftool test_image.jpg

# Nettoyer avec l'application

# Vérifier les données EXIF après
exiftool test_image_clean.jpg

# Devrait montrer un minimum de métadonnées
```

## Changer la Langue de l'Application

L'application détecte automatiquement la langue de votre appareil :

### Sur Simulateur iOS
1. Ouvrez l'application **Réglages** dans le simulateur
2. Allez dans **Général > Langue et région**
3. Changez la langue en **Français**
4. Relancez l'application MetadataKill

### Sur Appareil Physique
1. Ouvrez **Réglages** sur votre iPhone/iPad
2. Allez dans **Général > Langue et région**
3. Changez la langue préférée en **Français**
4. Relancez l'application MetadataKill

### Forcer la Langue en Français dans Xcode (Pour le Test)
1. Dans Xcode, sélectionnez le schéma de votre app
2. Cliquez sur **Modifier le Schéma** (à côté du bouton d'exécution)
3. Sélectionnez **Exécuter** dans la barre latérale
4. Allez dans l'onglet **Options**
5. Sous **Langue de l'Application**, sélectionnez **Français**
6. Cliquez sur **Fermer**
7. Exécutez l'application (⌘R)

L'application s'affichera maintenant entièrement en français !

## Raccourcis Xcode Utiles

- **⌘R** : Compiler et Exécuter
- **⌘B** : Compiler
- **⌘U** : Exécuter les Tests
- **⌘.** : Arrêter l'Exécution
- **⌘K** : Effacer la Console
- **⌘⇧F** : Rechercher dans le Projet
- **⌘⇧O** : Ouvrir Rapidement

## Besoin d'Aide ?

- **Documentation** : Consultez README.md et les autres docs
- **Problèmes** : Recherchez dans les issues GitHub
- **Discussions** : Démarrez une Discussion GitHub
- **Revue de Code** : Soumettez une PR et posez des questions

## Prochaines Étapes

- [ ] Lire [CONTRIBUTING.md](CONTRIBUTING.md) pour les directives de contribution
- [ ] Consulter [ARCHITECTURE.md](ARCHITECTURE.md) pour la structure du code
- [ ] Vérifier [PRIVACY.md](PRIVACY.md) pour la politique de confidentialité
- [ ] Explorer les issues sur GitHub pour les tâches à faire

---

Bon développement ! 🚀 Si vous rencontrez des problèmes, veuillez ouvrir une issue GitHub avec les détails.
