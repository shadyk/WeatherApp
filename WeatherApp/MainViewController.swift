//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
import SnapKit
class MainViewController: UIViewController {

    private var viewModel: WeatherViewmodel? = nil
    
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.backgroundColor = .white
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 1
        t.separatorStyle = .none
        t.showsVerticalScrollIndicator = false
        t.delegate = self
        t.dataSource = self
        t.refreshControl = refreshControl
        return t
    }()
    
    lazy var refreshControl: UIRefreshControl? = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handlePullToRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    private lazy var txtField: UITextField = {
        let tf = UITextField()
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.keyboardType = .numberPad
        tf.placeholder = "Enter lat, lon"
        return tf
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .brown
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.blue, for: .normal)
        btn.setTitle("Search", for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tableHeader: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.backgroundColor = .red
        view.addSubview(txtField)
        view.addSubview(searchButton)
        txtField.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.height.equalTo(50)
            make.left.equalTo(view).offset(12)
            make.right.equalTo(searchButton.snp.left).offset(-12)
        }
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.right.equalTo(view).offset(-12)
        }
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }
    
    private func setupInterface(){
        view.addSubview(tableView)
        tableView.register(ListTableCell.self, forCellReuseIdentifier: "ListTableCell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.tableHeaderView = tableHeader
    }
    
    @objc func handlePullToRefresh(_ refreshControl: UIRefreshControl) {
        searchAction()
    }
    
    
    @objc private func searchAction(){
        refreshControl?.beginRefreshing()
        let s = self.txtField.text?.components(separatedBy: ",")
        getWeatherData(lat: s?.first ?? "33.3", lon: s?.last ?? "33.3")
    }
    
    func getWeatherData(lat:String,lon:String){
        let params = [
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
            URLQueryItem(name: "key", value: "03304d22b3f340ae8e6771599cc030bd")
        ]
        HttpRequester().get(endPoint: "current", queryItems:params, remoteObject: CurrentWeatherResponse.self) { [weak self] response in
            let mainData = response.data.first!
            let items = [
                BaseItem(title: "Weather", value: mainData.weather.description),
                BaseItem(title: "Temp", value: "\(mainData.temp)"),
                BaseItem(title: "AQI", value: "\(mainData.aqi)"),
                BaseItem(title: "Wind speed", value: "\(mainData.windSpd)"),
            ]
            self?.viewModel = WeatherViewmodel(items: items)
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
            print(response)
        } fail: { errorMsg in
            print(errorMsg)
        }
    }
    
    struct WeatherViewmodel{
        let items: [BaseItem]
    }
    struct BaseItem{
        var title:String
        var value:String
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
        viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ListTableCell = tableView.dequeueReusableCell(withIdentifier: "ListTableCell") as! ListTableCell
        let item = viewModel?.items[indexPath.row]
        cell.lblSubtitle.text = item?.value
        cell.lblTitle.text = item?.title
        cell.thumbnail.image = UIImage(systemName: "cloud.sun.rain")

        return cell
    }
    
}
