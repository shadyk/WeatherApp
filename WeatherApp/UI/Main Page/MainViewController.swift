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
            UIView.animate(withDuration: 1) {
                self.view.backgroundColor = weatherStatus.color
                self.tableView.backgroundColor = weatherStatus.color
            }
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
        t.backgroundColor = ThemeManager.currentTheme.backgroundColor
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
        tf.backgroundColor = ThemeManager.currentTheme.backgroundColor
        tf.layer.cornerRadius = 8
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .gray
        tf.textAlignment = .left
        tf.keyboardType =  .numbersAndPunctuation
        tf.placeholder = "placeholder".localized
        let paddingView = UIView(frame: CGRectMake(0, 0, 12, tf.frame.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .enabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle("search".localized, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        btn.setTitleColor(ThemeManager.currentTheme.textColor, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        return btn
    }()
    
    private lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .enabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(ThemeManager.currentTheme.textColor, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitle("current_location".localized, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        return btn
    }()
    
    private lazy var languageButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .enabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(ThemeManager.currentTheme.textColor, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitle(LanguageManager.theOtherLanguageName(), for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(languagePressed), for: .touchUpInside)
        return btn
    }()
    private lazy var themeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .enabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(ThemeManager.currentTheme.textColor, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitle("theme".localized, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(darkPressed), for: .touchUpInside)
        return btn
    }()
    
    private lazy var unitButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .enabledBlue
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle(currentUnit.name, for: .normal)
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        btn.setTitleColor(ThemeManager.currentTheme.textColor, for: .normal)
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
        let view = UIView()
        view.backgroundColor = .clear
        let firstHstack = footerFirstHstack()
        let secondHstack = footerSecondHstack()
        let stack = UIStackView(arrangedSubviews: [firstHstack, secondHstack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        firstHstack.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        secondHstack.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        return view
    }()
    private func footerFirstHstack() -> UIStackView{
        let hStack = UIStackView(arrangedSubviews: [locationButton,unitButton])
        
        locationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        unitButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        hStack.spacing = 12
        hStack.axis = .horizontal
        return hStack
    }
    
    private func footerSecondHstack()-> UIStackView{
        let hStack = UIStackView(arrangedSubviews: [languageButton,themeButton])
        
        languageButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        themeButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        hStack.distribution = .fillEqually
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.axis = .horizontal
        return hStack
    }
    
    var spinner = SpinnerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.currentTheme.backgroundColor
    }
    
    convenience init(controller: WeatherListController){
        self.init()
        self.controller = controller
        setupInterface()
    }
    
    private func setupInterface(){
        view.addSubview(tableView)
        view.addSubview(tableFooter)
        tableView.register(ListTableCell.self, forCellReuseIdentifier: "ListTableCell")
        tableView.tableHeaderView = tableHeader
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        tableFooter.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(24)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(200)
            make.top.equalTo(tableView.snp.bottom)
        }
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
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.tableModel = response.cellControllers
                self?.weatherStatus = response.weatherStatus
            }
           
        }, fail: { [weak self] msg in
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.showAlert(message: msg)
            }
        })
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
    
    @objc func languagePressed(){
        let actionSheet = UIAlertController(title: "Choose Language", message: nil, preferredStyle: .actionSheet)
        
        let arAction = UIAlertAction(title: "Arabic", style: .default) { [weak self] _ in
            guard !LanguageManager.currentLangauageIsArabic() else {return }
            self?.setupLanguageChanged()
        }
        let enAction = UIAlertAction(title: "English", style: .default) { [weak self] _ in
            guard LanguageManager.currentLangauageIsArabic() else {return }
            self?.setupLanguageChanged()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        actionSheet.addAction(arAction)
        actionSheet.addAction(enAction)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func setupLanguageChanged() {
        let language = LanguageManager.currentLanguageIsRTL() ? Language.english : Language.arabic
        LanguageManager.setCurrentLanguage(languageId: language.languageId)
        restartApp()
    }
    
    @objc func darkPressed(){
        let actionSheet = UIAlertController(title: "Choose Theme", message: nil, preferredStyle: .actionSheet)
        
        let dark = UIAlertAction(title: "Dark", style: .default) { _ in
            guard ThemeManager.currentTheme == .light else {return}
            ThemeManager.currentTheme = .dark
            self.restartApp()

            
        }
        let light = UIAlertAction(title: "Light", style: .default) { _ in
            guard ThemeManager.currentTheme == .dark else {return}

            ThemeManager.currentTheme = .light
            ThemeManager.applyTheme()
            self.restartApp()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        actionSheet.addAction(dark)
        actionSheet.addAction(light)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func restartApp(){
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sd.setupIntitalPage()
        }
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
        self.spinner.willMove(toParent: nil)
        self.spinner.view.removeFromSuperview()
        self.spinner.removeFromParent()
    }
}
