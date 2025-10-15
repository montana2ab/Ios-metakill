# Politique de confidentialité - MetadataKill

**Dernière mise à jour** : 12 janvier 2025

## Notre engagement

MetadataKill est conçu avec la confidentialité comme fondation. Nous croyons que vos photos, vidéos et métadonnées doivent rester privées et sous votre contrôle.

## Ce que nous FAISONS

✅ **Traitement 100% sur l'appareil** : Toutes les opérations se déroulent localement sur votre appareil  
✅ **Fonctionne hors ligne** : L'application fonctionne complètement sans connexion Internet  
✅ **Préserve vos fichiers** : Les fichiers originaux restent intacts (sauf si vous choisissez de les remplacer)  
✅ **Transparence** : Code open-source pour une capacité d'audit complète  

## Ce que nous ne faisons PAS

❌ **AUCUNE collecte de données** : Nous ne collectons, ne stockons ni ne transmettons aucune de vos données  
❌ **AUCUNE analyse** : Aucun suivi d'utilisation, rapports de crash ou télémétrie  
❌ **AUCUN service cloud** : Pas de synchronisation iCloud, pas de serveurs externes  
❌ **AUCUNE publicité** : Pas de réseaux publicitaires ni de SDK tiers  
❌ **AUCUN compte requis** : Pas d'inscription, de connexion ou de profil utilisateur  

## Permissions demandées

### Accès à la bibliothèque de photos

- **Objectif** : Accéder aux photos/vidéos que vous souhaitez nettoyer
- **Portée** : Accès limité (uniquement les éléments que vous sélectionnez explicitement)
- **Utilisation** : Les fichiers sont lus, traités et sauvegardés localement
- **Stockage** : Les fichiers nettoyés sont sauvegardés dans le dossier Documents de votre appareil

### Accès au système de fichiers (optionnel)

- **Objectif** : Importer des fichiers depuis l'application Fichiers
- **Portée** : Uniquement les fichiers que vous sélectionnez explicitement
- **Utilisation** : Accès temporaire pour le traitement uniquement

## Traitement des données

### Ce qui arrive à vos fichiers

1. **Sélection** : Vous choisissez les fichiers à traiter
2. **Lecture** : Les données du fichier sont lues en mémoire sur votre appareil
3. **Traitement** : Les métadonnées sont supprimées en utilisant les frameworks iOS
4. **Écriture** : Le fichier nettoyé est sauvegardé sur votre appareil
5. **Nettoyage** : Les données temporaires sont supprimées

### Aucune activité réseau

L'application :
- Ne fait aucune connexion réseau
- Ne communique pas avec des serveurs externes
- Ne télécharge ni ne téléverse aucune donnée
- Fonctionne de manière identique avec ou sans Internet

Vous pouvez le vérifier en :
- Activant le mode Avion
- Utilisant des outils de surveillance réseau
- Examinant le code source

## Journalisation optionnelle

L'application inclut une fonctionnalité de journalisation privée **opt-in** :

- **Par défaut** : Désactivée
- **Objectif** : Aider à diagnostiquer les problèmes techniques
- **Contenu** : Temps de traitement, types d'erreurs (pas de noms de fichiers ou de métadonnées)
- **Stockage** : Chiffré, stocké localement uniquement
- **Partage** : Uniquement si vous exportez et partagez manuellement les journaux
- **Suppression** : Les journaux peuvent être effacés à tout moment depuis les Réglages

Exemple d'entrée de journal (anonymisée) :
```
[2025-01-12 10:30:15] Traitement d'image terminé en 1,2s
[2025-01-12 10:30:16] 8 champs de métadonnées supprimés
[2025-01-12 10:30:16] Erreur : Espace insuffisant
```

## Code tiers

MetadataKill peut inclure :
- **Frameworks Apple** : Frameworks système iOS (ImageIO, AVFoundation, etc.)
- **Bibliothèques open source** : Listées dans Package.swift

Toutes les dépendances sont vérifiées pour la conformité à la confidentialité.

## Confidentialité des enfants

Cette application est sûre pour les utilisateurs de tous âges. Comme nous ne collectons aucune donnée, il n'y a pas de considérations spéciales pour les enfants de moins de 13 ans.

## Sécurité des données

La sécurité de vos données est assurée par :
- **Traitement local** : Les données ne quittent jamais votre appareil
- **Sécurité système** : Protégé par les fonctionnalités de sécurité iOS
- **Pas de stockage cloud** : Aucune donnée stockée sur des serveurs externes
- **Suppression sécurisée** : Les fichiers temporaires sont correctement nettoyés

## Vos droits

Vous avez un contrôle complet :
- **Accès** : Toutes vos données restent sur votre appareil
- **Suppression** : Supprimez les fichiers nettoyés à tout moment
- **Portabilité** : Les fichiers sont dans des formats standards
- **Transparence** : Consultez le code source sur GitHub

## Modifications de cette politique

Nous pouvons mettre à jour cette politique de confidentialité :
- Pour refléter les améliorations de l'application
- Pour clarifier les pratiques existantes
- En réponse aux retours des utilisateurs

Les mises à jour seront publiées sur :
- Le dépôt GitHub
- La liste App Store
- Le changelog dans l'application

## Conformité

MetadataKill est conforme avec :
- Directives de confidentialité de l'App Store d'Apple
- RGPD (Règlement général sur la protection des données de l'UE)
- CCPA (California Consumer Privacy Act)
- Autres réglementations sur la confidentialité (par conception)

### Étiquette nutritionnelle de confidentialité Apple

**Données non collectées**

Cette application ne collecte aucune donnée.

### Manifeste de confidentialité

L'application inclut un Manifeste de confidentialité (`PrivacyInfo.xcprivacy`) déclarant :
- Pas de suivi
- Pas de collecte de données
- Accès à la bibliothèque de photos avec le code de raison CA92.1

## Contact

Si vous avez des questions sur cette politique de confidentialité :
- **GitHub** : Ouvrez une issue sur https://github.com/montana2ab/Ios-metakill/issues
- **Sujet** : Question sur la politique de confidentialité

## Vérification

Vous pouvez vérifier nos affirmations de confidentialité :
1. Examinez le code source sur GitHub
2. Utilisez des outils de surveillance réseau
3. Vérifiez les paramètres de confidentialité iOS
4. Testez en mode Avion

## Résumé

**MetadataKill est véritablement axé sur la confidentialité** :
- Zéro collecte de données
- Zéro activité réseau
- Zéro suivi
- Traitement 100% local
- Contrôle 100% sous votre responsabilité

Vos photos, vidéos et confidentialité sont en sécurité avec MetadataKill.
