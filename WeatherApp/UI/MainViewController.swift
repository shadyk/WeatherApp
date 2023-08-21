//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
import SnapKit
import CoreLocation

class MainViewController: UIViewController {

    private var viewModel: WeatherViewmodel? = nil
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation? {
        didSet{
            if let currentLocation {
                let lat = currentLocation.coordinate.latitude
                let lon = currentLocation.coordinate.longitude
                getWeatherData(lat: "\(lat)", lon: "\(lon)")
                txtField.text = "\(lat) , \(lon)"
            }
        }
    }
    
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
    
    private lazy var txtField: UITextField = {
        let tf = UITextField()
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.gray.cgColor
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .gray
        tf.textAlignment = .left
        tf.keyboardType =  .numbersAndPunctuation
        tf.placeholder = "Enter lat, lon"

        let paddingView = UIView(frame: CGRectMake(0, 0, 12, tf.frame.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 0.5)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Search", for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 0.5)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Weather for current location", for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        return btn
    }()
    
    private lazy var tableHeader: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.backgroundColor = .clear
        view.addSubview(txtField)
        view.addSubview(searchButton)
        txtField.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.height.equalTo(50)
            make.leading.equalTo(view).offset(12)
            make.trailing.equalTo(searchButton.snp.leading).offset(-12)
        }
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.trailing.equalTo(view).offset(-12)
        }
        searchButton.contentCompressionResistancePriority(for: .horizontal)
        return view
    }()
    
    
    private lazy var tableFooter: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        view.backgroundColor = .clear
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.height.equalTo(50)
            make.width.equalTo(200)

        }
        return view
    }()
    private lazy var spinner = SpinnerViewController()
    
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
        tableView.tableFooterView = tableFooter
    }
    
    @objc private func searchAction(){
        showLoader()
        let s = self.txtField.text?.components(separatedBy: ",")
        getWeatherData(lat: s?.first ?? "33.3", lon: s?.last ?? "33.3")
    }
    
    @objc private func getCurrentLocation(){
        showLoader()
        initalizeLocationManager()
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
            self?.hideLoader()
            print(response)
        } fail: { [weak self] errorMsg in
            print(errorMsg)
            self?.hideLoader()
            self?.showAlert(message: errorMsg)
        }
    }
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
    func showLoader() {
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func hideLoader(){
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
}

extension MainViewController: CLLocationManagerDelegate{
    private func initalizeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
           print("denied")
        case .notDetermined:
            print("notDetermined")
        case .authorizedAlways, .authorizedWhenInUse:
            print("authorized")
        @unknown default:
            fatalError()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        hideLoader()
        showAlert(message: "Couldn't get location : \(error.localizedDescription)")
    }
}
