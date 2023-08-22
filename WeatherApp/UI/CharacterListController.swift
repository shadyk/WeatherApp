//
//  Created by Shady
//  All rights reserved.
//  

import Foundation
import UIKit

protocol WeatherListController {
    var weatherLoader: WeatherLoader { get set }
    func loadWeather(lat:String, lon:String, unit: Unit, success: @escaping ([ListCellController]) -> Void,  fail: @escaping ErrorHandler)
}


class DefaultWeatherListController: WeatherListController{
    var weatherLoader: WeatherLoader
    init(weatherLoader: WeatherLoader) {
        self.weatherLoader = weatherLoader
    }
    
    func loadWeather(lat:String, lon:String, unit: Unit, success: @escaping ([ListCellController]) -> Void,  fail: @escaping ErrorHandler) {
        self.loadWeathersFromLoader(lat: lat, lon: lon, unit: unit.weatherBitUnit()) {
            let cellControllers = $0.map {
                ListCellController(viewModel: $0)
            }
            success(cellControllers)
        } fail: { fail($0) }
    }
    
    private func loadWeathersFromLoader(lat:String, lon:String, unit: String, success: @escaping CurrentWeatherCompletion,  fail: @escaping ErrorHandler) {
        weatherLoader.getWeather(lat: lat, lon: lon, unit: unit,
            success: { success($0) },
            fail: {  fail($0)})
    }
}
