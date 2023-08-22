//
//  Created by Shady
//  All rights reserved.
//
import Network

class WeatherLoaderWithFallbackComposite: WeatherLoader {
	private let primary: WeatherLoader
	private let fallback: WeatherLoader
    let monitor = NWPathMonitor()

	init(primary: WeatherLoader, fallback: WeatherLoader) {
		self.primary = primary
		self.fallback = fallback

	}
    
    func getWeather(lat: String, lon: String, unit: String, success: @escaping LoadWeatherCompletion, fail: @escaping ErrorHandler) {
         monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {return}
            if path.status == .satisfied {
                self.primary.getWeather(lat: lat, lon: lon, unit: unit, success: success, fail: fail)
            }
            else {
                self.fallback.getWeather(lat: lat, lon: lon, unit: unit, success: success, fail: fail)
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
	
}
