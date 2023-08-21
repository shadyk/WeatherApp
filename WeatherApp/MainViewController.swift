//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
import SnapKit
class MainViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.backgroundColor = .white
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 1
        t.separatorStyle = .none
        t.showsVerticalScrollIndicator = false
        t.delegate = self
        t.dataSource = self
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
//        getWeatherData()
    }
    
    private func setupInterface(){
        view.addSubview(tableView)
        title = "Today's weather"
        tableView.register(ListTableCell.self, forCellReuseIdentifier: "ListTableCell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func getWeatherData(){
        let params = [
            URLQueryItem(name: "lat", value: "33.33"),
            URLQueryItem(name: "lon", value: "33.33"),
            URLQueryItem(name: "key", value: "03304d22b3f340ae8e6771599cc030bd")
        ]
        HttpRequester().get(endPoint: "current", queryItems:params, remoteObject: CurrentWeatherResponse.self) { response in
            print(response)
        } fail: { errorMsg in
            print(errorMsg)
        }
    }
}

struct CurrentWeatherResponse: Codable {
    let count: Int
    let data: [MainData]
}

// MARK: - Datum
struct MainData: Codable {
    let appTemp: Double
    let aqi: Int
    let cityName: String
    let clouds: Int
    let countryCode, datetime: String
    let dewpt, dhi, dni, elevAngle: Double
    let ghi, gust: Double
    let hAngle: Int
    let lat, lon: Double
    let obTime, pod: String
    let precip: Int
    let pres: Double
    let rh: Int
    let slp: Double
    let snow, solarRAD: Float
    let sources: [String]
    let stateCode, station, sunrise, sunset: String
    let temp: Double
    let timezone: String
    let ts: Int
    let uv: Double
    let vis: Int
    let weather: Weather
    let windCdir, windCdirFull: String
    let windDir: Int
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



extension MainViewController: UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ListTableCell = tableView.dequeueReusableCell(withIdentifier: "ListTableCell") as! ListTableCell
        cell.lblSubtitle.text = "epis"
        cell.lblTitle.text = "name"
        return cell
    }
    
}
