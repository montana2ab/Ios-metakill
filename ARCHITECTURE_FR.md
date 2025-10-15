# Architecture de MetadataKill

## Vue d'ensemble

MetadataKill suit les principes de l'**Architecture Propre** (Clean Architecture), créant une application iOS maintenable, testable et évolutive pour la suppression de métadonnées.

## Couches architecturales

### 1. Couche Domaine (`Sources/Domain`)

**Objectif** : Logique métier pure sans aucune dépendance

**Contenu** :
- **Modèles** : Structures de données de base
  - `MediaType.swift` : Définitions des types de médias (image, vidéo, live photo)
  - `MetadataType.swift` : Classifications des métadonnées
  - `MediaItem.swift` : Représente un fichier à traiter
  - `CleaningSettings.swift` : Configuration pour les opérations de nettoyage
  
- **Cas d'usage** : Protocoles des opérations métier
  - `CleanMediaUseCase.swift` : Opérations principales de nettoyage
  - Définit les interfaces, pas les implémentations
  
- **Référentiels** : Protocoles d'accès aux données
  - `MediaRepository.swift` : Accès aux fichiers média
  - Interfaces abstraites pour l'inversion de dépendances

**Principes** :
- ✅ Aucune dépendance aux frameworks iOS
- ✅ Types Swift purs
- ✅ Conception orientée protocoles
- ✅ Sémantique de valeur (structs)

### 2. Couche Données (`Sources/Data`)

**Objectif** : Implémenter les protocoles du domaine avec la logique de traitement réelle

**Contenu** :
- **Traitement d'images** :
  - `ImageMetadataCleaner.swift` : Suppression de métadonnées d'images
    - Utilise `CoreGraphics`, `ImageIO` pour le traitement bas niveau
    - Gère JPEG, HEIC, PNG, WebP, RAW
    - Implémente la correction d'orientation
    - Conversion d'espace colorimétrique
    - Suppression de chunks PNG
  
- **Traitement de vidéos** :
  - `VideoMetadataCleaner.swift` : Suppression de métadonnées vidéo
    - Utilise `AVFoundation` pour le traitement vidéo
    - Re-muxage sans réencodage (rapide)
    - Réencodage de secours pour les métadonnées persistantes
    - Suppression d'atomes QuickTime
  
- **Stockage** :
  - `LocalStorageRepository.swift` : Opérations du système de fichiers
    - Génération de fichiers de sortie
    - Vérification de l'espace disponible
    - Nettoyage des fichiers temporaires
  
- **Cas d'usage** :
  - `CleanImageUseCaseImpl.swift` : Implémentation du nettoyage d'images
  - `CleanVideoUseCaseImpl.swift` : Implémentation du nettoyage de vidéos

**Principes** :
- ✅ Implémente les protocoles du domaine
- ✅ Dépend uniquement de la couche Domaine
- ✅ Traitement pur de données, pas d'interface utilisateur

### 3. Couche Plateforme (`Sources/Platform`)

**Objectif** : Intégrations spécifiques à iOS et interactions système

**Contenu** (à implémenter) :
- **PhotoKit** : Intégration avec la bibliothèque de photos
  - Wrapper pour PHPickerViewController
  - Gestion des PHAsset
  - Détection des Live Photos
  - Gestion du téléchargement iCloud
  
- **Système de fichiers** : Intégration du sélecteur de fichiers
  - Wrapper pour UIDocumentPickerViewController
  - Support du glisser-déposer
  - Coordination de fichiers
  
- **Arrière-plan** : Traitement en arrière-plan
  - Configuration de BGTaskScheduler
  - File persistante
  - Restauration d'état

**Principes** :
- ✅ Encapsule les frameworks iOS
- ✅ Fournit des interfaces conformes au Domaine
- ✅ Gère les préoccupations spécifiques à la plateforme

### 4. Couche Application (`Sources/App`)

**Objectif** : Interface utilisateur et injection de dépendances

**Contenu** :
- **Vues** (SwiftUI) :
  - `ContentView.swift` : Écran d'accueil avec navigation
  - `ImageCleanerView.swift` : Interface de nettoyage d'images
  - `VideoCleanerView.swift` : Interface de nettoyage de vidéos
  - `BatchProcessorView.swift` : Traitement par lot
  - `SettingsView.swift` : Interface de configuration
  
- **ViewModels** :
  - Intégrés dans les vues avec `@StateObject`
  - `@MainActor` pour la sécurité du thread d'interface
  - Observable pour les mises à jour réactives
  
- **ID** (Injection de dépendances) :
  - `AppState` : Configuration globale
  - Fonctions factory pour la création de cas d'usage
  
- **Point d'entrée de l'application** :
  - `MetadataKillApp.swift` : Point d'entrée SwiftUI `@main`

**Principes** :
- ✅ SwiftUI uniquement (pas d'UIKit)
- ✅ Pattern MVVM
- ✅ Flux de données unidirectionnel
- ✅ Pattern Observable

## Flux de données

### Flux de nettoyage d'images

```
Action utilisateur (Vue)
    ↓
ViewModel (async)
    ↓
CleanImageUseCaseImpl (Données)
    ↓
ImageMetadataCleaner (Données)
    ↓
CoreGraphics/ImageIO (Framework iOS)
    ↓
LocalStorageRepository (Données)
    ↓
Résultat (Modèle Domaine)
    ↓
ViewModel met à jour @Published
    ↓
Vue SwiftUI se redessine
```

### Flux de nettoyage de vidéos

```
Action utilisateur (Vue)
    ↓
ViewModel (async)
    ↓
CleanVideoUseCaseImpl (Données)
    ↓
VideoMetadataCleaner (Données)
    ↓
AVFoundation (Framework iOS)
    ↓
LocalStorageRepository (Données)
    ↓
Résultat (Modèle Domaine)
    ↓
ViewModel met à jour @Published
    ↓
Vue SwiftUI se redessine
```

## Modèle de concurrence

### Isolation d'acteurs

```swift
// Mises à jour de l'interface
@MainActor
class HomeViewModel: ObservableObject {
    @Published var results: [CleaningResult] = []
    
    func processImages() async {
        // Traitement asynchrone
    }
}

// Traitement en arrière-plan
actor ProcessingQueue {
    private var items: [MediaItem] = []
    
    func enqueue(_ item: MediaItem) {
        items.append(item)
    }
}
```

### Gestion des tâches

```swift
// Tâche annulable
private var processingTask: Task<Void, Never>?

func startProcessing() {
    processingTask = Task {
        for item in items {
            // Vérifier l'annulation
            try Task.checkCancellation()
            
            // Traiter l'élément
            await processItem(item)
        }
    }
}

func cancel() {
    processingTask?.cancel()
}
```

### Async/Await

```swift
// Pas de callbacks, code async propre
func cleanImage(from url: URL) async throws -> CleaningResult {
    let data = try await loadImage(url)
    let cleaned = try await cleanMetadata(data)
    let output = try await save(cleaned)
    return CleaningResult(outputURL: output)
}
```

## Injection de dépendances

### ID basée sur les protocoles

```swift
// Le domaine définit le protocole
protocol StorageRepository {
    func save(data: Data) async throws -> URL
}

// Les données implémentent
class LocalStorageRepository: StorageRepository {
    func save(data: Data) async throws -> URL {
        // Implémentation
    }
}

// Le cas d'usage dépend du protocole
class CleanImageUseCaseImpl {
    private let storage: StorageRepository
    
    init(storage: StorageRepository) {
        self.storage = storage
    }
}

// La couche App injecte l'implémentation concrète
let storage = LocalStorageRepository()
let useCase = CleanImageUseCaseImpl(storage: storage)
```

### Pattern Factory

```swift
struct UseCaseFactory {
    static func makeCleanImageUseCase() -> CleanImageUseCase {
        let cleaner = ImageMetadataCleaner()
        let storage = LocalStorageRepository()
        return CleanImageUseCaseImpl(
            cleaner: cleaner,
            storage: storage
        )
    }
}
```

## Gestion des erreurs

### Erreurs du domaine

```swift
public enum CleaningError: LocalizedError {
    case fileNotFound
    case unsupportedFormat
    case processingFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Fichier introuvable"
        case .processingFailed(let reason):
            return "Échec du traitement : \(reason)"
        }
    }
}
```

### Propagation des erreurs

```swift
// Cas d'usage
func execute() async throws -> CleaningResult {
    do {
        let data = try await cleanImage()
        return CleaningResult(state: .completed, data: data)
    } catch {
        return CleaningResult(
            state: .failed,
            error: error.localizedDescription
        )
    }
}

// ViewModel
func processImages() async {
    do {
        let result = try await useCase.execute()
        await MainActor.run {
            results.append(result)
        }
    } catch {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
```

## Stratégie de test

### Tests unitaires (Domaine)

```swift
final class MediaItemTests: XCTestCase {
    func testMediaItemCreation() {
        let item = MediaItem(
            name: "test.jpg",
            type: .image,
            sourceURL: testURL,
            fileSize: 1024
        )
        
        XCTAssertEqual(item.name, "test.jpg")
    }
}
```

### Tests d'intégration (Données)

```swift
final class ImageCleanerTests: XCTestCase {
    var sut: ImageMetadataCleaner!
    
    func testRemoveEXIF() async throws {
        let testImage = Bundle.module.url(
            forResource: "test_with_exif",
            withExtension: "jpg"
        )!
        
        let (data, metadata) = try await sut.cleanImage(
            from: testImage,
            settings: .default
        )
        
        XCTAssertTrue(metadata.contains { $0.type == .exif })
        // Vérifier que la sortie n'a pas d'EXIF
    }
}
```

### Tests d'interface (App)

```swift
final class ImageCleanerUITests: XCTestCase {
    func testSelectAndCleanImage() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Nettoyer les Photos"].tap()
        app.buttons["Sélectionner depuis Photos"].tap()
        // ... sélectionner une photo
        app.buttons["Nettoyer 1 Photo"].tap()
        
        XCTAssertTrue(app.staticTexts["Traitement"].exists)
    }
}
```

## Considérations de performance

### Traitement par flux

```swift
// Ne pas charger tout le fichier en mémoire
func processLargeVideo(url: URL) async throws {
    let reader = try AVAssetReader(asset: AVAsset(url: url))
    let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    
    // Traiter par morceaux
    while reader.status == .reading {
        if let buffer = output.copyNextSampleBuffer() {
            input.append(buffer)
        }
    }
}
```

### Traitement parallèle

```swift
// Traiter plusieurs éléments simultanément
await withTaskGroup(of: CleaningResult.self) { group in
    for item in items {
        group.addTask {
            try await cleanItem(item)
        }
    }
    
    for await result in group {
        results.append(result)
    }
}
```

### Gestion thermique

```swift
// Surveiller l'état thermique
NotificationCenter.default.addObserver(
    forName: ProcessInfo.thermalStateDidChangeNotification,
    object: nil,
    queue: .main
) { _ in
    if ProcessInfo.processInfo.thermalState == .critical {
        pauseProcessing()
    }
}
```

## Considérations de sécurité

### Pas de journalisation de données sensibles

```swift
// ❌ MAUVAIS
logger.info("Traitement du fichier : \(url.path)")
logger.info("Coordonnées GPS : \(gpsData)")

// ✅ BON
logger.info("Traitement d'un fichier image")
logger.info("Métadonnées GPS détectées et supprimées")
```

### Gestion sécurisée des fichiers

```swift
// Nettoyer les fichiers temporaires
defer {
    try? FileManager.default.removeItem(at: tempURL)
}

// Utiliser du hasard sécurisé pour les fichiers temporaires
let tempName = UUID().uuidString
let tempURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(tempName)
```

## Améliorations futures

### Améliorations architecturales prévues

1. **File basée sur acteur** : Remplacer la file @Published par un Actor pour une meilleure concurrence
2. **Intégration Combine** : Ajouter des publishers Combine pour les flux réactifs
3. **Core Data** : File persistante pour la récupération après crash
4. **WidgetKit** : Widget d'écran d'accueil avec statistiques rapides
5. **App Clips** : Version légère pour le partage

### Évolutivité

- La conception modulaire permet l'ajout facile de fonctionnalités
- L'ID basée sur les protocoles permet les tests et les mocks
- La séparation claire permet la parallélisation des équipes
- La structure SPM prend en charge la réutilisation du code

## Conclusion

L'architecture de MetadataKill donne la priorité à :
- **Testabilité** : Limites claires, conception basée sur les protocoles
- **Maintenabilité** : Séparation des préoccupations, responsabilité unique
- **Confidentialité** : Pas de collecte de données, traitement local uniquement
- **Performance** : Async/await, streaming, parallélisation
- **Qualité** : Sécurité des types, gestion des erreurs, tests complets

Cette architecture permet un développement confiant et une évolution facile de l'application.
