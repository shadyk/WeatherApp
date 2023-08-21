//
//  Created by Shady
//  All rights reserved.
//  

import Foundation
typealias CurrentWeatherCompletion = (WeatherViewmodel) -> Void

protocol WeatherLoader{
    func getWeather(lat:String, lon:String, unit:String, success: @escaping CurrentWeatherCompletion, fail: @escaping ErrorHandler)
}
