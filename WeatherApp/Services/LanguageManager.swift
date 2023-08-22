//
//  Created by Shady
//  All rights reserved.
//

import UIKit

class LanguageManager: NSObject {
    private var cLanguage: Language!
    private var availableLanguages: [Language]!
    private var currentBundle: Bundle!

    static var shared = LanguageManager()

    static var phoneLanguage: String? {
        let langs = NSLocale.preferredLanguages
        if langs.count > 0 {
            return langs.first!
        }
        return nil
    }

    static var isPhoneLanguageRTL: Bool? {
        return phoneLanguage?.contains("ar")
    }

    static func initialize(languages: [Language], defaultLanguage: Language) {
        shared.availableLanguages = languages
        shared.cLanguage = try? Language.load() ?? defaultLanguage
        Language.save(shared.cLanguage)

        let bundlePath: String! = Bundle.main.path(forResource: shared.cLanguage.languageId, ofType: "lproj")
        let bundle = Bundle(path: bundlePath)
        shared.currentBundle = bundle
        if isPhoneLanguageRTL! {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [Any]
            if !(languages?.first as? String == Language.english.languageId) {
                UserDefaults.standard.set([Language.english.languageId], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
            }
        }
    }


    static func currentLanguageId() -> String {
        return shared.cLanguage.languageId
    }

    static func setCurrentLanguage(languageId: String) {
        for language: Language in shared.availableLanguages {
            if language.languageId == languageId {
                shared.cLanguage = language
            }
        }
        Language.save(shared.cLanguage)

        let bundlePath: String! = Bundle.main.path(forResource: shared.cLanguage.languageId, ofType: "lproj")
        let bundle = Bundle(path: bundlePath)
        shared.currentBundle = bundle
    }

    static func localizedString(key: String, comment: String) -> String {
        if shared.currentBundle == nil {
            return key
        }
        let localizedString = shared.currentBundle.localizedString(forKey: key, value: comment, table: nil)
        return localizedString
    }
    
    static func currentLanguageIsRTL() -> Bool {
        return shared.cLanguage.isRTL
    }

    static func currentLangauageIsArabic() -> Bool {
        return currentLanguageIsRTL()
    }

    static func language(for id: String) -> Language? {
        switch id {
        case "ar": return .arabic
        case "en": return .english
        default: return nil
        }
    }

    static func languageName(for id: String) -> String? {
        switch id {
        case "ar": return "Arabic"
        case "en": return "English"
        default: return nil
        }
    }

    private static func availableLanguagesIds() -> [String]! {
        let allLanguagesId = shared.availableLanguages.map { language -> String in
            language.languageId
        }
        return allLanguagesId
    }

    public static func unselectedLanguagesIds() -> [String]! {
        var allLanguages = availableLanguagesIds()
        if let index = allLanguages?.firstIndex(of: currentLanguageId()) {
            allLanguages?.remove(at: index)
        }
        return allLanguages
    }
}

extension String {
    var localized: String {
        return LanguageManager.localizedString(key: self, comment: "")
    }
}

class Language: Codable {
    var isRTL: Bool!
    var languageId: String!
    var name: String!
    static let arabic = Language(languageId: "ar", name: "العربية", isRTL: true)
    static let english = Language(languageId: "en", name: "English", isRTL: false)

    convenience init(languageId: String) {
        self.init(languageId: languageId, name: languageId, isRTL: false)
    }

    convenience init(languageId: String, isRTL: Bool) {
        self.init(languageId: languageId, name: languageId, isRTL: isRTL)
    }

    init(languageId: String, name: String, isRTL: Bool) {
        self.languageId = languageId
        self.name = name
        self.isRTL = isRTL
    }
}

extension Language {
    static var storageKeyForObject: String {
        return "Language.object"
    }

    static var defaultEncoder: JSONEncoder {
        return JSONEncoder()
    }

    static var defaultDecoder: JSONDecoder {
        return JSONDecoder()
    }

    static func save(_ item: Language) {
        do {
            let data = try defaultEncoder.encode(item)
            UserDefaults.standard.setValue(data, forKey: storageKeyForObject)
            UserDefaults.standard.synchronize()
        } catch {
            assertionFailure()
        }
    }

    static func load() throws -> Language? {
        if let saved = UserDefaults.standard.object(forKey: storageKeyForObject) as? Data {
            return try? defaultDecoder.decode(Language.self, from: saved)
        }
        return nil
    }
}
