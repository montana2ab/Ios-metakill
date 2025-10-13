# 🚀 COMMENCER ICI - Guide Rapide

> **Vous n'arrivez pas à installer l'application ?** Ce guide simplifié est fait pour vous !

## ⚠️ Important à Savoir

MetadataKill est un **projet Xcode** incluant du code source (Swift Package). Vous devez :
1. Avoir un Mac avec Xcode installé
2. Ouvrir le projet Xcode (déjà pré-configuré !)
3. Compiler et exécuter

**🎉 Nouveau !** Le projet inclut maintenant un fichier Xcode pré-configuré (`MetadataKill.xcodeproj`) - plus besoin de configuration manuelle !

## ✅ Ce dont Vous Avez Besoin

- [ ] Un Mac (macOS 12.0 ou plus récent)
- [ ] Xcode 14.0 ou plus récent (télécharger depuis l'App Store)
- [ ] Un compte développeur Apple (gratuit pour tester)
- [ ] 10-15 minutes

## 📋 Guide en 3 Étapes Simples

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

### Étape 2 : Ouvrir le Projet Xcode

```bash
# Dans Terminal
open MetadataKill.xcodeproj
```

Xcode va s'ouvrir avec le projet pré-configuré.

### Étape 3 : Compiler et Exécuter

1. **Sélectionnez un Simulateur** : En haut à gauche, cliquez sur "iPhone 15" (ou autre simulateur disponible)

2. **Configurez votre Équipe** (première fois seulement) :
   - Sélectionnez le projet "MetadataKill" dans la barre latérale
   - Cliquez sur l'onglet "Signing & Capabilities"
   - Sélectionnez votre **Équipe** (compte Apple)

4. **Enregistrez** le projet dans un dossier **différent** (pas dans `Ios-metakill`)

3. **Lancez l'Application** :
   - Cliquez sur le bouton ▶️ (Play) en haut à gauche
   - Ou appuyez sur ⌘R
   - L'application va compiler (peut prendre 1-2 minutes la première fois)
   - L'application s'ouvre dans le simulateur !

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
