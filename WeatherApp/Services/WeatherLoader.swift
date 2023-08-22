//
//  Created by Shady
//  All rights reserved.
//  

import Foundation
typealias LoadWeatherCompletion = (WeatherViewModel) -> Void

protocol WeatherLoader{
    func getWeather(lat:String, lon:String, unit:String, success: @escaping LoadWeatherCompletion, fail: @escaping ErrorHandler)
}
