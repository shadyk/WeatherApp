//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
import SnapKit
import CoreLocation

class MainViewController: UIViewController {

    private var viewModel: WeatherViewmodel? {
        didSet{
            tableView.reloadData()
        }
    }
    private var weatherLoader: WeatherLoader? = nil
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
    
    private var currentUnit: Unit = .celsius {
        didSet{
            if let currentLocation {
                let lat = currentLocation.coordinate.latitude
                let lon = currentLocation.coordinate.longitude
                getWeatherData(lat: "\(lat)", lon: "\(lon)")
                txtField.text = "\(lat) , \(lon)"
                unitButton.setTitle(currentUnit.name, for: .normal)
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
        btn.setTitle("Current location", for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        return btn
    }()
    
    private lazy var unitButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 0.5)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(currentUnit.name, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
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
        let hStack = UIStackView(arrangedSubviews: [locationButton,unitButton])
        
        locationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        unitButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        hStack.spacing = 10
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        hStack.axis = .horizontal
        view.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
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
        txtField.resignFirstResponder()
        self.showLoader()
        weatherLoader?.getWeather(lat:lat, lon: lon, unit: currentUnit.weatherBitUnit()) { [weak self] viewmodel in
            self?.viewModel = viewmodel
        } fail: { [weak self] errorMsg in
            self?.hideLoader()
            self?.showAlert(message: errorMsg)
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.items.count ?? 0
    }
        
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

extension MainViewController{
    @objc func showActionSheet(){
        guard currentLocation != nil else {return}
        let actionSheet = UIAlertController(title: "Choose a unit", message: nil, preferredStyle: .actionSheet)
        Unit.allCases.forEach{ unit in
            let action = UIAlertAction(title: unit.name, style: .default) { [weak self] _ in
                self?.currentUnit = unit.self
            }
            actionSheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
}

extension MainViewController: CLLocationManagerDelegate{
    private func initalizeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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


enum Unit: String, CaseIterable{
    case celsius
    case kelvin
    case fahrenheit
    
    var name: String{
        self.rawValue.capitalized
    }
}

extension Unit{
    func weatherBitUnit() -> String{
        switch self{
        case .celsius:
            return "M"
        case .kelvin:
            return "S"
        case .fahrenheit:
            return "I"
        }
    }
}

/*
 Review the code you have written for Tasks 1-3 and identify any areas where improvements can be made in terms of code efficiency, modularity, or best practices. Provide a written explanation of your findings, along with any suggested improvements.
 
  - Seperate concerns of UI, app logic, and services
  - Modularize services for reusablity
  - Enhacne user experience
  - Follow SOLID principles
  - Follow the composer pattern
 x
 */
