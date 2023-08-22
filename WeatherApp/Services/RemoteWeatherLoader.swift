//
//  Created by Shady
//  All rights reserved.
//  

import UIKit

class RemoteWeatherLoader: WeatherLoader {
    let api  = "03304d22b3f340ae8e6771599cc030bd"
 
    func getWeather(lat:String, lon:String, unit:String, success: @escaping LoadWeatherCompletion, fail: @escaping ErrorHandler) {
        
        let endpoint = "current"
        let params = [
            URLQueryItem(name: "key", value: api ),
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
            URLQueryItem(name: "units", value: unit),
        ]
        
        HttpRequester().get(endPoint: endpoint, queryItems: params, remoteObject: RemoteWeather.self) { [weak self] response in
            guard let self = self else {return}
            let mainData = response.data.first!
            let viewModel = WeatherViewModel(
                aqi: "\(mainData.aqi)",
                temp: "\(mainData.temp)",
                weatherDescription: mainData.weather.description,
                windSpeed: "\(mainData.windSpd)",
                weatherStatus: self.weatherStatus(from: mainData.weather.code))
            success(viewModel)
        } fail: { fail($0) }
    }
    
    private func weatherStatus(from code:Int) -> WeatherStatus{
        if (200..<700).contains(code){
            return .rainy
        }else if (700..<800).contains(code){
            return .cloudy
        }
        else {
            return .sunny
        }
    }
}

enum WeatherStatus: String, Codable{
    case sunny, rainy, cloudy
    
    var color: UIColor{
        switch self{
        case .sunny:
            return .yellow
        case .rainy:
            return .blue
        case .cloudy:
            return .lightGray
        }
    }
    
    var image: String{
        switch self{
        case .sunny:
            return "sun.max"
        case .rainy:
            return "cloud.rain"
        case .cloudy:
            return "cloud"
        }
    }
}
