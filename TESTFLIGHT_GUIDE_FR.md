# 🚀 MetadataKill - Guide de Test TestFlight

## Bienvenue aux testeurs bêta ! 🎉

Merci de nous aider à tester **MetadataKill** - l'application iOS de nettoyage de métadonnées axée sur la confidentialité !

---

## 📋 Qu'est-ce que MetadataKill ?

MetadataKill supprime toutes les métadonnées (EXIF, GPS, IPTC, XMP) de vos photos et vidéos, protégeant votre vie privée en :
- ✅ Supprimant les données de localisation GPS
- ✅ Nettoyant les informations de l'appareil photo/périphérique
- ✅ Effaçant les horodatages et autres données sensibles
- ✅ Traitant 100% sur l'appareil (pas de cloud, pas de tracking)

---

## 🎯 Instructions de Test

### Pour Commencer

1. **Installez l'application** depuis TestFlight
2. **Accordez les permissions nécessaires** lorsque demandé :
   - Accès à la bibliothèque de photos (pour sélectionner les photos à nettoyer)
   - Accès aux fichiers (pour sélectionner les fichiers à nettoyer)
3. **Choisissez votre langue** : Anglais ou Français (détection automatique)

### Quoi Tester

#### 🖼️ Nettoyage d'Images

**Test 1 : Image Unique**
1. Appuyez sur **"Nettoyer les Photos"** sur l'écran d'accueil
2. Sélectionnez **"Sélectionner depuis Photos"** ou **"Sélectionner depuis Fichiers"**
3. Choisissez **1 photo** (JPEG, HEIC ou PNG)
4. Appuyez sur **"Nettoyer 1 Photo"**
5. Attendez que le traitement soit terminé
6. Vérifiez que l'image nettoyée est sauvegardée

**Test 2 : Traitement par Lot - 10 Images**
1. Allez dans **"Nettoyer les Photos"**
2. Sélectionnez **10 images JPEG** depuis votre bibliothèque ou fichiers
3. Appuyez sur **"Nettoyer 10 Photos"**
4. Surveillez l'indicateur de progression
5. Vérifiez que les 10 images sont traitées avec succès
6. Consultez les résultats pour les statistiques de suppression de métadonnées

**Test 3 : Live Photo**
1. Allez dans **"Nettoyer les Photos"**
2. Sélectionnez une **Live Photo** depuis votre Bibliothèque de Photos
3. Nettoyez-la
4. Vérifiez que les composants photo et vidéo sont traités
5. Vérifiez que la fonctionnalité Live Photo est préservée (si applicable)

#### 🎬 Nettoyage de Vidéos

**Test 4 : Vidéo Unique**
1. Appuyez sur **"Nettoyer les Vidéos"** sur l'écran d'accueil
2. Sélectionnez un fichier vidéo
3. Choisissez le mode de traitement dans Paramètres si désiré (Copie Rapide, Réencodage Sûr, Auto Intelligent)
4. Appuyez sur **"Nettoyer 1 Vidéo"**
5. Attendez le traitement (peut prendre plus de temps pour les gros fichiers)
6. Vérifiez que la vidéo nettoyée est sauvegardée

**Test 5 : Vidéo 4K**
1. Allez dans **"Nettoyer les Vidéos"**
2. Sélectionnez une **vidéo 4K** (3840×2160 ou supérieur)
3. Nettoyez-la avec les paramètres par défaut
4. Vérifiez :
   - Le traitement se termine sans plantage
   - La vidéo de sortie maintient la qualité
   - La taille du fichier est raisonnable
   - La vidéo se lit correctement

#### ⚙️ Paramètres & Configuration

**Test 6 : Paramètres**
1. Allez dans **Paramètres**
2. Essayez de modifier :
   - Langue (Anglais ↔ Français)
   - Options de suppression de métadonnées
   - Paramètres de qualité d'image
   - Mode de traitement vidéo
   - Mode de sortie (Remplacer l'Original, Nouvelle Copie, etc.)
3. Vérifiez que les paramètres sont sauvegardés et persistent après le redémarrage de l'app

#### 🔄 Traitement par Lot

**Test 7 : Lot de Médias Mixtes**
1. Appuyez sur **"Traitement par Lot"**
2. Sélectionnez un mélange de photos et vidéos
3. Traitez-les ensemble
4. Vérifiez que tous les fichiers sont gérés correctement

---

## ⚠️ Problèmes Connus

Les problèmes suivants sont déjà connus et en cours de résolution :

1. **Intégration des Tests UI** : Les tests UI sont basiques et nécessitent une intervention manuelle pour la sélection de fichiers
2. **Traitement de Gros Fichiers** : Les très grandes vidéos 4K (>1Go) peuvent prendre plusieurs minutes à traiter
3. **Utilisation de la Mémoire** : Le traitement simultané de nombreux fichiers volumineux peut causer des avertissements mémoire sur les appareils plus anciens
4. **Export de Live Photo** : Les Live Photos nettoyées peuvent perdre leur effet "live" lors de l'export (dépend du format de sortie)
5. **Localisation** : Certaines boîtes de dialogue système peuvent encore apparaître dans la langue de l'appareil plutôt que la langue de l'app
6. **Traitement en Arrière-Plan** : L'app peut ne pas traiter les fichiers si elle est en arrière-plan pendant de longues périodes

---

## 📸 Fichiers de Test Recherchés

Aidez-nous à tester avec des types de fichiers divers ! Nous recherchons :

### Images
- ✅ JPEG de diverses caméras (iPhone, DSLR, Android)
- ✅ Fichiers HEIC (format natif iOS)
- ✅ Fichiers PNG avec métadonnées
- ✅ Fichiers RAW (DNG, CR2, NEF, ARW)
- ✅ Images avec données GPS
- ✅ Images sans données GPS
- ✅ Images très haute résolution (>20MP)
- ✅ Live Photos

### Vidéos
- ✅ Vidéos 4K (3840×2160)
- ✅ Vidéos 1080p
- ✅ Vidéos 720p
- ✅ Vidéos d'iPhone
- ✅ Vidéos d'autres appareils
- ✅ Vidéos avec métadonnées GPS
- ✅ Clips courts (<10 secondes)
- ✅ Vidéos plus longues (>5 minutes)
- ✅ Vidéos avec chapitres
- ✅ Vidéos HDR

**Comment Partager des Fichiers de Test :**
Si vous avez des cas de test intéressants ou des fichiers qui causent des problèmes, veuillez les noter dans vos retours !

---

## 🐛 Comment Signaler des Problèmes

Lors du signalement de bugs ou problèmes, veuillez inclure :

1. **Informations de l'Appareil**
   - Modèle d'iPhone (ex : iPhone 14 Pro)
   - Version iOS (ex : iOS 17.1)

2. **Étapes pour Reproduire**
   - Ce que vous essayiez de faire
   - Ce qui s'est passé vs ce qui était attendu
   - Pouvez-vous le reproduire de manière constante ?

3. **Informations sur le Fichier** (si applicable)
   - Type de fichier (JPEG, HEIC, MP4, etc.)
   - Taille approximative du fichier
   - Résolution (pour images/vidéos)
   - Source (caméra iPhone, téléchargé, etc.)

4. **Captures d'Écran ou Enregistrements d'Écran**
   - Très utiles pour les problèmes d'interface !

5. **Journaux** (si l'app plante)
   - Vérifiez Réglages > Confidentialité > Analyses > Données d'Analyses
   - Recherchez les journaux de plantage "MetadataKill"

---

## 📊 Ce que Nous Mesurons

Nous collectons des métriques **anonymes** via MetricKit pour améliorer les performances :

- ✅ Temps de lancement de l'app
- ✅ Performance de traitement
- ✅ Utilisation de la mémoire
- ✅ Impact sur la batterie
- ✅ Rapports de plantage (le cas échéant)

**Note** : Tout le traitement est fait sur l'appareil. Aucune photo, vidéo ou donnée personnelle ne quitte jamais votre appareil !

---

## 💡 Conseils pour de Meilleurs Résultats

1. **Libérez de l'espace** : Assurez-vous d'avoir suffisamment d'espace libre (au moins 2 Go recommandé)
2. **Fermez les autres apps** : Pour de meilleures performances lors du traitement de gros fichiers
3. **Utilisez le Wi-Fi pour les mises à jour** : Les mises à jour bêta peuvent être fréquentes
4. **Vérifiez les Paramètres** : Explorez différents modes de traitement pour les vidéos
5. **Testez les cas limites** : Formats de fichiers inhabituels, fichiers très volumineux, etc.

---

## 🎯 Domaines de Focus

Nous avons particulièrement besoin de retours sur :

1. **Performance**
   - Quelle est la vitesse de traitement ?
   - Y a-t-il des ralentissements ou des blocages ?
   - Décharge de batterie lors d'une utilisation intensive ?

2. **Précision**
   - Les métadonnées sont-elles réellement supprimées ? (Vous pouvez vérifier avec des apps comme "ViewExif" ou "Metapho")
   - Des métadonnées restantes ?
   - Préservation de la qualité image/vidéo ?

3. **Expérience Utilisateur**
   - L'interface est-elle intuitive ?
   - Les instructions sont-elles claires ?
   - Des workflows déroutants ?

4. **Localisation** (pour les utilisateurs français)
   - Les traductions sont-elles précises et naturelles ?
   - Des traductions manquantes ?
   - Pertinence culturelle ?

5. **Stabilité**
   - Des plantages ?
   - Des pertes de données ?
   - L'app se bloque ou ne répond plus ?

---

## 📱 Contact & Retours

- **Retours TestFlight** : Utilisez le formulaire de retour intégré (secouez l'appareil ou capture d'écran)
- **GitHub Issues** : Signalez des bugs détaillés sur [github.com/montana2ab/Ios-metakill/issues]
- **Email** : [Votre email de contact]

---

## 🙏 Merci !

Vos tests et retours sont inestimables pour faire de MetadataKill le meilleur outil de confidentialité pour iOS. Nous apprécions votre temps et vos efforts !

**Bons Tests !** 🚀

---

## 📅 Historique des Versions

### Bêta Actuelle : v1.0.0 (Build 1)
- Version bêta initiale
- Fonctionnalité de nettoyage de métadonnées de base
- Localisation Anglais & Français
- Intégration OSLog
- Surveillance MetricKit
- Tests UI basiques
- Tests d'intégration pour vérification de métadonnées

### À Venir
- Support de plus de langues
- Paramètres avancés
- Améliorations du traitement par lot
- Options d'export
- Intégration des raccourcis Siri
