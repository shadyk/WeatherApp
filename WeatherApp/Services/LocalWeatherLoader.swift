//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

class LocalWeatherLoader: WeatherCache{
    let key = "weather_key"
    func insert(_ weather: WeatherViewModel, completion: @escaping InsertionCompletion) {
        UserDefaults.standard.set(weather, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        if let vm = UserDefaults.standard.object(forKey: key) as? WeatherViewModel{
            completion(.success(vm))
        }
        else{
            completion(.failure(LocalError.unknown))
        }
    }
}

enum LocalError: Error{
    case unknown
}
