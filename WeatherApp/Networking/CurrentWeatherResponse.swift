//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

struct CurrentWeatherResponse: Codable {
    let count: Int
    let data: [MainData]
}

// MARK: - Datum
struct MainData: Codable {
    let appTemp: Double
    let aqi: Double
    let cityName: String
    let clouds: Double
    let countryCode, datetime: String
    let dewpt, dhi, dni, elevAngle: Double
    let ghi, gust: Double
    let hAngle: Double
    let lat, lon: Double
    let obTime, pod: String
    let precip: Double
    let pres: Double
    let rh: Double
    let slp: Double
    let snow, solarRAD: Float
    let sources: [String]
    let stateCode, station, sunrise, sunset: String
    let temp: Double
    let timezone: String
    let ts: Double
    let uv: Double
    let vis: Double
    let weather: Weather
    let windCdir, windCdirFull: String
    let windDir: Double
    let windSpd: Double
    
    enum CodingKeys: String, CodingKey {
        case appTemp = "app_temp"
        case aqi
        case cityName = "city_name"
        case clouds
        case countryCode = "country_code"
        case datetime, dewpt, dhi, dni
        case elevAngle = "elev_angle"
        case ghi, gust
        case hAngle = "h_angle"
        case lat, lon
        case obTime = "ob_time"
        case pod, precip, pres, rh, slp, snow
        case solarRAD = "solar_rad"
        case sources
        case stateCode = "state_code"
        case station, sunrise, sunset, temp, timezone, ts, uv, vis, weather
        case windCdir = "wind_cdir"
        case windCdirFull = "wind_cdir_full"
        case windDir = "wind_dir"
        case windSpd = "wind_spd"
    }
}

// MARK: - Weather
struct Weather: Codable {
    let code: Int
    let icon, description: String
}
