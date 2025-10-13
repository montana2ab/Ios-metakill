# 🚀 COMMENCER ICI - Guide Rapide

> **Vous n'arrivez pas à installer l'application ?** Ce guide simplifié est fait pour vous !

## ⚠️ Important à Savoir

MetadataKill est un **projet de code source** (Swift Package), pas une application prête à l'emploi. Vous devez :
1. Avoir un Mac avec Xcode installé
2. Créer une "enveloppe" d'application iOS
3. Lier le code source à cette enveloppe
4. Compiler et exécuter

**Pas de fichier .ipa ou .app disponible** pour installation directe.

## ✅ Ce dont Vous Avez Besoin

- [ ] Un Mac (macOS 12.0 ou plus récent)
- [ ] Xcode 14.0 ou plus récent (télécharger depuis l'App Store)
- [ ] Un compte développeur Apple (gratuit pour tester)
- [ ] 10-15 minutes

## 📋 Guide en 5 Étapes Simples

### Étape 1 : Télécharger le Code

```bash
# Ouvrir Terminal (Applications > Utilitaires > Terminal)
git clone https://github.com/montana2ab/Ios-metakill.git
cd Ios-metakill
```

Si vous n'avez pas `git`, installez-le via les Command Line Tools :
```bash
xcode-select --install
```

### Étape 2 : Ouvrir Xcode

```bash
# Dans Terminal
open Package.swift
```

Xcode va s'ouvrir avec le projet.

### Étape 3 : Créer l'Application iOS

C'est l'étape la plus importante !

1. **Dans Xcode**, allez dans le menu : `Fichier > Nouveau > Projet...`

2. **Sélectionnez** : `iOS` puis `App`

3. **Configurez** :
   - **Nom du produit** : `MetadataKill`
   - **Équipe** : Sélectionnez votre compte Apple
   - **Identifiant d'organisation** : `com.monnom` (remplacez par votre nom)
   - **Interface** : `SwiftUI`
   - **Langage** : `Swift`

4. **Enregistrez** le projet dans un dossier **différent** (pas dans `Ios-metakill`)

### Étape 4 : Lier le Code Source

1. Dans le **navigateur de projet** (barre latérale gauche), cliquez sur votre projet

2. Sélectionnez votre **cible** (target) "MetadataKill"

3. Allez dans l'onglet **Général**

4. Descendez jusqu'à **"Frameworks, Libraries, and Embedded Content"**

5. Cliquez sur le bouton **+**

6. Cliquez sur **"Add Other..."** puis **"Add Package Dependency..."**

7. Cliquez sur **"Add Local..."**

8. Naviguez vers le dossier `Ios-metakill` que vous avez cloné

9. Sélectionnez-le et cliquez sur **"Add Package"**

10. Dans la liste qui apparaît, cochez **"App"**

11. Cliquez sur **"Add"**

### Étape 5 : Modifier le Fichier Principal

1. Dans le navigateur de projet, trouvez le fichier Swift principal (celui avec `@main`)

2. **Remplacez tout son contenu** par :

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

3. **Enregistrez** (⌘S)

### Étape 6 : Ajouter les Permissions

1. Dans le navigateur, trouvez le fichier `Info.plist`

2. **Clic droit** dessus > **Ouvrir comme** > **Code Source**

3. Ajoutez ces lignes **avant** la balise `</dict>` :

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>MetadataKill a besoin d'accéder à vos photos pour supprimer les métadonnées.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>MetadataKill enregistre les photos nettoyées dans votre bibliothèque.</string>
```

### Étape 7 : Lancer l'Application !

1. En haut de Xcode, sélectionnez un **simulateur** (ex: iPhone 15 Pro)

2. Appuyez sur le **bouton Play** (▶️) ou **⌘R**

3. L'application va compiler (peut prendre 1-2 minutes la première fois)

4. L'application s'ouvre dans le simulateur !

## 🎉 Félicitations !

Vous avez réussi ! L'application devrait maintenant s'afficher dans le simulateur.

### Pour Utiliser en Français

L'application détecte automatiquement la langue du simulateur. Pour changer :

1. Dans le simulateur : **Settings** > **General** > **Language & Region**
2. Changez en **Français**
3. Relancez l'app

## 🐛 Problèmes Courants

### "No such module 'App'"
- **Solution** : Vous avez oublié l'Étape 4. Retournez-y et liez le package local.

### "Build Failed"
- **Solution** : Vérifiez que vous avez bien modifié le fichier principal (Étape 5).
- Nettoyez le build : Menu `Product` > `Clean Build Folder` (⇧⌘K)
- Relancez la compilation

### "Cannot find package"
- **Solution** : Assurez-vous d'avoir cloné le dépôt dans l'Étape 1.
- Vérifiez le chemin lors de l'ajout du package local.

### L'application plante au lancement
- **Solution** : Vérifiez la console Xcode (en bas) pour les erreurs.
- Assurez-vous d'avoir ajouté les permissions Info.plist (Étape 6).

## 📚 Documentation Complète

- **Guide d'Installation Détaillé** : [INSTALLATION_FR.md](INSTALLATION_FR.md)
- **Guide Rapide en Anglais** : [QUICKSTART.md](QUICKSTART.md)
- **README Principal** : [README.md](README.md)

## 💡 Vous Avez Encore des Problèmes ?

1. **Vérifiez** que vous avez suivi toutes les étapes dans l'ordre
2. **Lisez** [INSTALLATION_FR.md](INSTALLATION_FR.md) pour plus de détails
3. **Ouvrez une issue** sur GitHub avec :
   - La version de Xcode que vous utilisez
   - L'erreur exacte que vous voyez
   - À quelle étape vous êtes bloqué

## 🚀 Prochaines Étapes

Une fois l'application fonctionnelle :

- ✅ Testez le nettoyage de photos
- ✅ Configurez les paramètres
- ✅ Essayez le traitement par lot
- ✅ Installez sur votre iPhone (connectez votre appareil)

---

**Bon développement !** 🎊
