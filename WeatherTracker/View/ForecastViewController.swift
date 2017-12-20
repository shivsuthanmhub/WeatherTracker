//
//  ForecastViewController.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 14/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MBProgressHUD

class ForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    public var locationManager:CLLocationManager!
    public var hud:MBProgressHUD!
    
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var weatherLocation: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var weatherRate: UILabel!
    @IBOutlet weak var weatherDate: UILabel!
    @IBOutlet weak var tapToChangeLocation: UIButton!
    @IBOutlet weak var tapToGetMoreForecastData: UIButton!
    @IBOutlet weak var forecastTbl: UITableView!
    
    public var forecastViewModel = ForecastViewModel()
    public var forecastViewModelList = [ForecastModel]()
    
    @objc func showFetchLocationLoadingHUD() {
        self.hideUIControls()
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading"
    }
    
    @objc func hideFetchLocationLoadingHUD() {
        self.showUIControls()
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }
    
    func hideUIControls()  {
        self.weatherImg.isHidden = true
        self.weatherLocation.isHidden = true
        self.weatherDesc.isHidden = true
        self.weatherRate.isHidden = true
        self.weatherDate.isHidden = true
        self.tapToChangeLocation.isHidden = true
        self.tapToGetMoreForecastData.isHidden = true
        self.forecastTbl.isHidden = true
    }
    
    func showUIControls() {
        self.weatherImg.isHidden = false
        self.weatherLocation.isHidden = false
        self.weatherDesc.isHidden = false
        self.weatherRate.isHidden = false
        self.weatherDate.isHidden = false
        self.tapToChangeLocation.isHidden = false
        self.tapToGetMoreForecastData.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideUIControls()
        self.forecastTbl.dataSource = self
        self.forecastTbl.delegate = self
        
    }
    
    @IBAction func tapToChangeLocation(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Change Location", message: "Please input your city:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                
                self.showFetchLocationLoadingHUD()
                
                self.forecastViewModel.getWeather(city: field.text!)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI(_notification:)), name: NSNotification.Name(rawValue: "HideLoader"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI(_notification:)), name: NSNotification.Name(rawValue: "weatherDataNotified"), object: nil)
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "City"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func tapToGetMoreForecastData(_ sender: Any) {
        
        let alert = UIAlertController(title: "Alert", message: "Do you want to fetch five days weather data?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.showFetchLocationLoadingHUD()
            self.forecastViewModel.getFiveDaysForecastData(city: self.forecastViewModel.WeatherDetails.location)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateForecastUI(_notification:)), name: NSNotification.Name(rawValue: "weatherForecastDataNotified"), object: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func updateUI(_notification: NSNotification) {
        DispatchQueue.main.async {
            
            self.hideFetchLocationLoadingHUD()
            self.showUIControls()
            
            self.weatherLocation.text = self.forecastViewModel.WeatherDetails.location
            self.weatherRate.text = self.forecastViewModel.WeatherDetails.temp
            self.weatherDesc.text = self.forecastViewModel.WeatherDetails.weather
            self.weatherDate.text = self.forecastViewModel.WeatherDetails.date
            self.weatherImg.image = UIImage(named: self.forecastViewModel.WeatherDetails.weatherIcon)
        }
    }
    
    @objc func updateForecastUI(_notification: NSNotification) {
        DispatchQueue.main.async {
            
            self.hideFetchLocationLoadingHUD()
            self.forecastTbl.isHidden = false
            
            self.forecastViewModelList = self.forecastViewModel.WeatherDetailsFiveDaysList            
            UIView.transition(with: self.forecastTbl, duration: 1.0, options: .transitionCrossDissolve, animations: {self.forecastTbl.reloadData()}, completion: nil)

        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecastViewModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.reuseIdentifier, for: indexPath) as? ForecastCell else { fatalError("Unexpected Table View Cell") }
        
        let weatherForecastData = self.forecastViewModelList[indexPath.row]
        
        cell.weatherLbl?.text = weatherForecastData.weather
        cell.dateLbl?.text = weatherForecastData.date
        cell.tempLbl?.text = weatherForecastData.temp
        cell.locationLbl?.text = weatherForecastData.location
        cell.weatherImgView.image = UIImage(named: weatherForecastData.weatherIcon)
        cell.timeLbl?.text = weatherForecastData.time
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        showFetchLocationLoadingHUD()
        
        self.forecastViewModel.getWeatherWithCoordinates(lat:Double(userLocation.coordinate.latitude), lon: Double (userLocation.coordinate.longitude))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI(_notification:)), name: NSNotification.Name(rawValue: "weatherDataNotified"), object: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    
}

