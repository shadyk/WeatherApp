//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

class Composer{
    static func mainViewController(controller: WeatherListController) -> MainViewController {
        let vc = MainViewController(controller: controller)
        return vc
    }
}
