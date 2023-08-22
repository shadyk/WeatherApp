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
        self.loadWeathersFromLoader(lat: lat, lon: lon, unit: unit.weatherBitUnit()) { viewModel in
            
            let cellControllers = [
                ListCellController(viewModel: ViewItem(title: "Weather", value: viewModel.weatherDescription)),
                ListCellController(viewModel: ViewItem(title: "Temp in \(unit.name)", value: viewModel.temp)),
                ListCellController(viewModel: ViewItem(title: "AQI", value: viewModel.aqi)),
                ListCellController(viewModel: ViewItem(title: "Wind speed", value: viewModel.windSpeed)),
            ]
            success(cellControllers)
        } fail: { fail($0) }
    }
    
    private func loadWeathersFromLoader(lat:String, lon:String, unit: String, success: @escaping LoadWeatherCompletion,  fail: @escaping ErrorHandler) {
        weatherLoader.getWeather(lat: lat, lon: lon, unit: unit,
                                 success: { success($0) },
                                 fail: {  fail($0)})
    }
}
