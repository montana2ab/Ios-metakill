import Foundation

extension String {
    /// Returns the localized string for the current key
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
    
    /// Returns a localized string with formatted arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, bundle: .module, comment: ""), arguments: arguments)
    }
}
