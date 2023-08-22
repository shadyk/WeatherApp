//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

class LocalWeatherCache: WeatherCache ,WeatherLoader{
    let key = "weather_key"
    func insert(_ weather: WeatherViewModel, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(weather)
            UserDefaults.standard.set(data, forKey: key)

        } catch {
            print("Unable to Encode Note (\(error))")
        }
        UserDefaults.standard.synchronize()
    }
    
    func getWeather(lat: String, lon: String, unit: String, success: @escaping LoadWeatherCompletion, fail: @escaping ErrorHandler) {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                 let decoder = JSONDecoder()
                 let item = try decoder.decode(WeatherViewModel.self, from: data)
                success(item)

             } catch {
                 fail("error getting cache")
                 print("Unable to Decode (\(error))")
             }
        }
        else{
            fail("error getting cache")
        }
    }
}
