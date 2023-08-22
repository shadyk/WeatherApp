//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

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
        
        HttpRequester().get(endPoint: endpoint, queryItems: params, remoteObject: RemoteWeather.self) { response in
            let mainData = response.data.first!
            
            let viewModel = WeatherViewModel(aqi: "\(mainData.aqi)", temp: "\(mainData.temp)", weatherDescription: mainData.weather.description, windSpeed: "\(mainData.windSpd)")
            success(viewModel)
        } fail: { fail($0) }
    }
}

