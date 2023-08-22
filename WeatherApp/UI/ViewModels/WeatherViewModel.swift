//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

struct ViewItem{
    var title: String
    var value: String
    var systemImage: String
}

struct WeatherViewModel: Codable{
    var aqi :String
    var temp :String
    var weatherDescription :String
    var windSpeed :String
    var weatherStatus: WeatherStatus
    
}
