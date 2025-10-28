# Contribuer à MetadataKill

Merci de votre intérêt pour contribuer à MetadataKill ! Ce document fournit des directives et des informations pour les contributeurs.

**Auteur du projet :** Anthony Jodar

## Table des matières

- [Code de conduite](#code-de-conduite)
- [Premiers pas](#premiers-pas)
- [Configuration de développement](#configuration-de-développement)
- [Structure du projet](#structure-du-projet)
- [Normes de codage](#normes-de-codage)
- [Directives de test](#directives-de-test)
- [Processus de Pull Request](#processus-de-pull-request)
- [Considérations de confidentialité](#considérations-de-confidentialité)

## Code de conduite

### Nos standards

- **Soyez respectueux** : Traitez tous les contributeurs avec respect
- **Soyez constructif** : Fournissez des retours utiles
- **Soyez collaboratif** : Travaillez ensemble vers des objectifs communs
- **Respectez la confidentialité** : Tenez toujours compte de la confidentialité des utilisateurs dans vos contributions

## Premiers pas

### Prérequis

- macOS 12.0+ (pour le développement iOS)
- Xcode 14.0+ (15.0+ recommandé)
- Swift 5.9+
- Git
- Compte GitHub

### Première contribution

1. **Forkez le dépôt**
2. **Clonez votre fork** :
   ```bash
   git clone https://github.com/VOTRE_UTILISATEUR/Ios-metakill.git
   cd Ios-metakill
   ```
3. **Créez une branche** :
   ```bash
   git checkout -b feature/nom-de-votre-fonctionnalité
   ```
4. **Faites vos modifications et commitez** :
   ```bash
   git add .
   git commit -m "Ajout : brève description des changements"
   ```
5. **Poussez vers votre fork** :
   ```bash
   git push origin feature/nom-de-votre-fonctionnalité
   ```
6. **Ouvrez une Pull Request**

## Configuration de développement

### Compiler le projet

```bash
# Ouvrir dans Xcode
open MetadataKill.xcodeproj

# Ou compiler avec Swift Package Manager (limité sur Linux)
swift build

# Exécuter les tests
swift test
```

### Exécuter l'application

1. Sélectionnez un simulateur ou un appareil dans Xcode
2. Appuyez sur ⌘R pour compiler et exécuter
3. Testez vos modifications minutieusement

## Structure du projet

```
Ios-metakill/
├── Sources/
│   ├── Domain/          # Logique métier (Swift pur)
│   ├── Data/            # Implémentations de traitement de données
│   ├── Platform/        # Intégrations spécifiques à iOS
│   └── App/             # Interface utilisateur SwiftUI
├── Tests/
│   ├── DomainTests/     # Tests de la couche domaine
│   ├── DataTests/       # Tests de traitement de données
│   ├── PlatformTests/   # Tests d'intégration plateforme
│   └── AppTests/        # Tests d'interface
└── Package.swift        # Configuration SPM
```

### Responsabilités des modules

- **Domain** : Logique métier pure, aucune dépendance iOS
- **Data** : Implémentations concrètes des interfaces du domaine
- **Platform** : Code spécifique iOS (PhotoKit, FileSystem, etc.)
- **App** : Vues SwiftUI et view models

## Normes de codage

### Guide de style Swift

Suivez les [Directives de conception d'API Swift d'Apple](https://swift.org/documentation/api-design-guidelines/) :

```swift
// Bon
func cleanImage(from url: URL, settings: CleaningSettings) async throws -> CleaningResult

// Mauvais
func clean_image(url: URL, set: CleaningSettings) throws -> CleaningResult
```

### Principes clés

1. **Orienté protocole** : Utilisez les protocoles pour l'abstraction
2. **Types valeur** : Préférez les structs aux classes quand c'est possible
3. **Concurrence** : Utilisez async/await, évitez les callbacks
4. **Sécurité** : Gérez les erreurs explicitement, pas de force unwrap en production
5. **SwiftUI** : Utilisez SwiftUI pour toute l'interface (pas de vues UIKit)

### Organisation du code

```swift
// MARK: - Définition du type
public struct MediaItem {
    // MARK: - Propriétés
    public let id: UUID
    public let name: String
    
    // MARK: - Initialisation
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    // MARK: - Méthodes
    public func validate() -> Bool {
        // Implémentation
    }
}

// MARK: - Extensions
extension MediaItem: Identifiable {
    // Conformité au protocole
}
```

### Conventions de nommage

- **Types** : PascalCase (`MediaItem`, `CleaningSettings`)
- **Fonctions/Variables** : camelCase (`cleanImage`, `isProcessing`)
- **Constantes** : camelCase (`defaultQuality`, `maxFileSize`)
- **Protocoles** : Nom descriptif ou -able/-ing (`CleanableMedia`, `Processing`)

## Directives de test

### Structure des tests

```swift
import XCTest
@testable import Domain

final class MediaItemTests: XCTestCase {
    
    // MARK: - Propriétés
    var sut: MediaItem!
    
    // MARK: - Configuration/Nettoyage
    override func setUp() {
        super.setUp()
        // Code de configuration
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testMediaItemCreation() {
        // Étant donné
        let url = URL(fileURLWithPath: "/tmp/test.jpg")
        
        // Quand
        sut = MediaItem(name: "test.jpg", type: .image, sourceURL: url, fileSize: 1024)
        
        // Alors
        XCTAssertEqual(sut.name, "test.jpg")
        XCTAssertEqual(sut.type, .image)
    }
}
```

### Couverture de tests

Objectifs :
- **Domain** : Couverture de 90%+
- **Data** : Couverture de 80%+
- **Platform** : Couverture de 70%+
- **App** : Tests d'interface pour les flux critiques

### Types de tests

1. **Tests unitaires** : Tester les composants individuels isolément
2. **Tests d'intégration** : Tester les interactions entre composants
3. **Tests d'interface** : Tester les workflows utilisateur (XCUITest)
4. **Tests de performance** : Mesurer et suivre les performances

## Processus de Pull Request

### Avant de soumettre

1. ✅ **Tous les tests passent** : Exécutez `swift test` ou ⌘U
2. ✅ **Le code compile** : Aucun avertissement du compilateur
3. ✅ **Code formaté** : Suivez le guide de style Swift
4. ✅ **Documentation mise à jour** : Mettez à jour le README si nécessaire
5. ✅ **Confidentialité préservée** : Aucune collecte de données ajoutée

### Modèle de PR

```markdown
## Description
Brève description des modifications

## Type de changement
- [ ] Correction de bug
- [ ] Nouvelle fonctionnalité
- [ ] Changement cassant
- [ ] Mise à jour de documentation

## Tests
- [ ] Tests unitaires ajoutés/mis à jour
- [ ] Tests d'intégration réussis
- [ ] Tests manuels terminés

## Impact sur la confidentialité
- [ ] Aucun impact sur la confidentialité
- [ ] Politique de confidentialité mise à jour (si nécessaire)

## Liste de vérification
- [ ] Le code suit le style du projet
- [ ] Tests ajoutés pour les nouvelles fonctionnalités
- [ ] Documentation mise à jour
- [ ] Aucun nouvel avertissement
```

### Processus de révision

1. **Vérifications automatiques** : CI/CD exécute les tests
2. **Révision de code** : Les mainteneurs examinent les modifications
3. **Retours** : Répondez aux commentaires de révision
4. **Approbation** : Fusion une fois approuvée

### Messages de commit

Suivez les commits conventionnels :

```
feat: ajouter l'option de conversion HEIC vers JPEG
fix: corriger la correction d'orientation pour les images en paysage
docs: mettre à jour les instructions d'installation
test: ajouter des tests pour la suppression de métadonnées vidéo
refactor: simplifier le pipeline de traitement d'images
```

## Considérations de confidentialité

### Règles critiques

❌ **JAMAIS** :
- Ajouter des analyses ou du suivi
- Faire des appels réseau
- Stocker des données utilisateur en externe
- Journaliser des informations sensibles (chemins de fichiers, contenu de métadonnées)
- Ajouter des SDK tiers sans approbation

✅ **TOUJOURS** :
- Traiter les données localement
- Gérer les données sensibles en mémoire uniquement
- Nettoyer les fichiers temporaires
- Documenter l'impact sur la confidentialité
- Demander avant d'ajouter des permissions

### Liste de vérification de confidentialité

Avant de soumettre :
- [ ] Aucun nouvel appel réseau
- [ ] Aucune nouvelle collecte de données
- [ ] Aucune nouvelle permission (sauf justification)
- [ ] Politique de confidentialité mise à jour (si nécessaire)
- [ ] Données sensibles non journalisées

## Demandes de fonctionnalités

### Proposer de nouvelles fonctionnalités

1. **Vérifiez les issues existantes** : Recherchez les doublons
2. **Ouvrez une discussion** : Créez une Discussion GitHub
3. **Fournissez des détails** :
   - Cas d'usage
   - Comportement attendu
   - Impact sur la confidentialité
   - Idées d'implémentation

### Développement de fonctionnalités

1. **Obtenez l'approbation** : Discutez avant d'implémenter
2. **Concevez d'abord** : Planifiez l'architecture
3. **Implémentez progressivement** : PR petites et ciblées
4. **Testez minutieusement** : Tous les cas limites
5. **Documentez** : Mettez à jour README et commentaires de code

## Rapports de bugs

### Bon rapport de bug

```markdown
**Description** : Description claire du bug

**Étapes pour reproduire** :
1. Ouvrir l'application
2. Sélectionner 10 images
3. Appuyer sur Nettoyer
4. [Décrire le problème]

**Attendu** : Ce qui devrait se passer
**Réel** : Ce qui se passe réellement

**Environnement** :
- Appareil : iPhone 14 Pro
- Version iOS : 17.2
- Version de l'application : 1.0.0

**Contexte additionnel** : Captures d'écran, journaux (anonymisés)
```

## Documentation

### Commentaires de code

```swift
/// Nettoie les métadonnées d'un fichier image.
///
/// Cette fonction supprime toutes les métadonnées EXIF, GPS, IPTC et XMP
/// tout en préservant la qualité de l'image et en corrigeant l'orientation.
///
/// - Parameters:
///   - sourceURL: URL du fichier image source
///   - settings: Configuration pour l'opération de nettoyage
/// - Returns: Résultat contenant l'URL du fichier nettoyé et les statistiques
/// - Throws: `CleaningError` si le traitement échoue
public func cleanImage(from sourceURL: URL, settings: CleaningSettings) async throws -> CleaningResult
```

### Mises à jour du README

Mettez à jour le README lors :
- D'ajout de nouvelles fonctionnalités
- De modification de l'architecture
- De mise à jour des dépendances
- De modification des paramètres

## Questions ?

- **Issues GitHub** : Rapports de bugs et demandes de fonctionnalités
- **Discussions GitHub** : Questions et idées
- **Révision de code** : Posez des questions dans les commentaires de PR

## Reconnaissance

Les contributeurs seront :
- Listés dans les notes de version
- Reconnus dans [AUTHORS.md](AUTHORS.md)
- Crédités pour les contributions significatives

Toutes les contributions sont appréciées et aident à améliorer MetadataKill pour tout le monde.

**Projet créé et maintenu par Anthony Jodar.**

Merci de contribuer à MetadataKill ! 🙏
