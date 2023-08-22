//
//  Created by Shady
//  All rights reserved.
//  

import UIKit

enum Theme {
    case light
    case dark

    var backgroundColor: UIColor {
        switch self {
        case .light:
            return UIColor(named: "LightBackgroundColor")!
        case .dark:
            return UIColor(named: "DarkBackgroundColor")!
        }
    }

    var textColor: UIColor {
        switch self {
        case .light:
            return UIColor(named: "LightTextColor")!
        case .dark:
            return UIColor(named: "DarkTextColor")!
        }
    }
}

class ThemeManager {
    static var currentTheme: Theme = .light {
        didSet {
            applyTheme()
        }
    }

    static func applyTheme() {
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = currentTheme.backgroundColor
    }
}
