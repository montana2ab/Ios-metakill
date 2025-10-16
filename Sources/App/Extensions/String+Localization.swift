import Foundation

extension String {
    /// Returns the localized string for the current key
    var localized: String {
        // Determine the correct bundle to use
        let targetBundle: Bundle = {
            // Try to use the App module bundle first (SPM)
            if let moduleBundle = Bundle(identifier: "MetadataKill.App") {
                return moduleBundle
            }
            // Fall back to main bundle (Xcode target)
            return Bundle.main
        }()
        
        // Check if a custom language is set
        if let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let languageCode = languageCodes.first {
            // Try to find the localization in the target bundle
            if let path = targetBundle.path(forResource: languageCode, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                let localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
                // If the string is different from the key, we found a localization
                if localizedString != self {
                    return localizedString
                }
            }
        }
        
        // Fall back to system default localization
        let localizedString = NSLocalizedString(self, bundle: targetBundle, comment: "")
        // If no localization is found in the module bundle, try main bundle as last resort
        if localizedString == self && targetBundle != Bundle.main {
            return NSLocalizedString(self, bundle: .main, comment: "")
        }
        return localizedString
    }
    
    /// Returns a localized string with formatted arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
