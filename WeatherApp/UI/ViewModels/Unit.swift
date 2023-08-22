//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

enum Unit: String, CaseIterable{
    case celsius
    case kelvin
    case fahrenheit
    
    var name: String{
        self.rawValue.capitalized
    }
}

extension Unit{
    func weatherBitUnit() -> String{
        switch self{
        case .celsius:
            return "M"
        case .kelvin:
            return "S"
        case .fahrenheit:
            return "I"
        }
    }
}
