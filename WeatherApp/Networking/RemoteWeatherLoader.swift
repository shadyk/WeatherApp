//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

class RemoteWeatherLoader: WeatherLoader {
    let api  = "03304d22b3f340ae8e6771599cc030bd"
 
    func getWeather(lat:String, lon:String, unit:String, success: @escaping CurrentWeatherCompletion, fail: @escaping ErrorHandler) {
        
        let endpoint = "current"
        var params = [
            URLQueryItem(name: "key", value: api ),
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
            URLQueryItem(name: "units", value: unit),
        ]
        
        HttpRequester().get(endPoint: endpoint, remoteObject: CurrentWeatherResponse.self) { response in
            let mainData = response.data.first!
            let items = [
                BaseItem(title: "Weather", value: mainData.weather.description),
                BaseItem(title: "Temp", value: "\(mainData.temp)"),
                BaseItem(title: "AQI", value: "\(mainData.aqi)"),
                BaseItem(title: "Wind speed", value: "\(mainData.windSpd)"),
            ]
             let viewModel = WeatherViewmodel(items: items)
            success(viewModel)
        } fail: { fail($0) }
    }
}

