//
//  Created by Shady
//  All rights reserved.
//  

import UIKit
import SnapKit
import CoreLocation

class MainViewController: UIViewController, LoadingViewController {
    
    private var controller: WeatherListController?
    private var weatherStatus: WeatherStatus?{
        didSet{
            guard let weatherStatus else { return }
            view.backgroundColor = weatherStatus.color
            tableView.backgroundColor = weatherStatus.color
        }
    }
    private var tableModel = [ListCellController]() {
        didSet {
            tableView.reloadData()
            unitButton.isEnabled = true
        }
    }
    
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
            if !tableModel.isEmpty {
                searchAction()
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
        tf.delegate = self
        let paddingView = UIView(frame: CGRectMake(0, 0, 12, tf.frame.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .disabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Search", for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.isEnabled = false
        return btn
    }()
    
    private lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .disabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitle("Current location", for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        return btn
    }()
    
    private lazy var unitButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .disabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(currentUnit.name, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.isEnabled = false
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
    
    var spinner = SpinnerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    convenience init(controller: WeatherListController){
        self.init()
        self.controller = controller
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
        guard let coord = getCoordinates(self.txtField.text)
        else {
            showAlert(message: "Please enter correct lat,lon");
            return;
        }
        showLoader()
        getWeatherData(lat: coord.0, lon: coord.1)
    }
    
    private func getCoordinates(_ coord: String?) -> (String,String)?{
        guard let coord else {return nil}
        let fields = coord.components(separatedBy: ",")
        guard fields.count == 2,
              let lat = Double(fields.first!.trimmingCharacters(in: .whitespacesAndNewlines)
),
              let lon = Double(fields.last!.trimmingCharacters(in: .whitespacesAndNewlines)
)
        else {return nil}
        if CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: lat, longitude: lon)){
            return (fields.first!, fields.last!)
        }
        return nil
    }
    
    @objc private func getCurrentLocation(){
        showLoader()
        initalizeLocationManager()
    }
    
    func getWeatherData(lat:String,lon:String){
        txtField.resignFirstResponder()
        self.showLoader()
        controller?.loadWeather(lat:lat, lon: lon, unit: currentUnit, success: { [weak self] response in
            self?.hideLoader()
            self?.tableModel = response.cellControllers
            self?.weatherStatus = response.weatherStatus
        }, fail: { [weak self] msg in
            self?.hideLoader()
            self?.showAlert(message: msg)
        })
    }
}

extension MainViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        searchButton.isEnabled = !string.isEmpty
        return true
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view(in: tableView)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ListCellController {
        return tableModel[indexPath.row]
    }
}

extension MainViewController{
    @objc func showActionSheet(){
        guard !tableModel.isEmpty else {return}
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

/*
 Review the code you have written for Tasks 1-3 and identify any areas where improvements can be made in terms of code efficiency, modularity, or best practices. Provide a written explanation of your findings, along with any suggested improvements.
 
 - Seperate concerns of UI, app logic, and services
 - Modularize services for reusablity
 - Enhacne user experience
 - Follow SOLID principles
 - Follow the composer pattern
 x
 */

protocol LoadingViewController: UIViewController{
    var spinner: SpinnerViewController { get }
    func showLoader()
    func hideLoader()
}

extension LoadingViewController{
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
