import Foundation

extension String {
    /// Returns the localized string for the current key
    var localized: String {
        // Check if a custom language is set
        if let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let languageCode = languageCodes.first,
           let path = Bundle.module.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        
        // Fall back to system default
        return NSLocalizedString(self, bundle: .module, comment: "")
    }
    
    /// Returns a localized string with formatted arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
