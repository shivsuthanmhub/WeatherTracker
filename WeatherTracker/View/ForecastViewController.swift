//
//  ForecastViewController.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 14/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit
import Foundation

class ForecastViewController: UIViewController {
    
    // UI Properties of Controller
    
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var weatherLocation: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var weatherRate: UILabel!
    @IBOutlet weak var weatherDate: UILabel!
    @IBOutlet weak var tapToChangeLocation: UIButton!
    @IBOutlet weak var tapToGetMoreForecastData: UIButton!
    @IBOutlet weak var forecastTbl: UITableView!
    
    // Instances of Models
    
    public var forecastViewModel = ForecastViewModel()
    public var forecastViewModelList = [ForecastModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.initialSetup()
    }
    
    private func initialSetup() {
        // Hide Five days Forecast table initially
        self.forecastTbl?.isHidden = true
        // Set Datasource
        self.forecastTbl?.dataSource = forecastViewModel
        
        // Trigger Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI(_notification:)), name: NSNotification.Name(rawValue: "weatherDataNotified"), object: nil)
    }
}

extension ForecastViewController {
    
    @IBAction func tapToChangeLocation(_ sender: Any) {
        
        // Hide Five days Forecast table while location change
        self.forecastTbl?.isHidden = true
        
        // Show alert popup for enter location name to process
        let alertController = UIAlertController(title: "Change Location", message: "Please input your city:", preferredStyle: .alert)
        
        // Popup confirmation
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                
                // Show ProgressIndicator while processing
                ProgressHelper.sharedInstance.showFetchLocationLoadingHUD()
                
                // Call API
                self.forecastViewModel.getWeather(city: field.text!).then
                    { model -> Void in
                        // Trigger Notification
                        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI(_notification:)), name: NSNotification.Name(rawValue: "weatherDataNotified"), object: nil)
                    }.always
                    {
                        // Hide ProgressIndicator after processed
                        ProgressHelper.sharedInstance.hideFetchLocationLoadingHUD()
                    }.catch
                    {
                        // Catch the error log
                        (error) in
                        print(error.localizedDescription)
                }
            }
        }
        
        // Popup calcelation
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        // Add Textbox to the controller
        alertController.addTextField { (textField) in
            textField.placeholder = "City"
        }
        
        // Append the actions
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func tapToGetMoreForecastData(_ sender: Any) {
        
        // Show alert popup to proceed fetch five days forecast data
        let alert = UIAlertController(title: "Alert", message: "Do you want to fetch five days weather data?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            // Show ProgressIndicator while processing
            ProgressHelper.sharedInstance.showFetchLocationLoadingHUD()
            
            // Call API
            self.forecastViewModel.getFiveDaysForecastData(city: self.forecastViewModel.WeatherDetails.location).then
                { model -> Void in
                    DispatchQueue.main.async {
                        self.forecastTbl?.isHidden = false
                        self.forecastViewModelList = model
                        UIView.transition(with: self.forecastTbl, duration: 1.0, options: .transitionCrossDissolve, animations: {self.forecastTbl.reloadData()}, completion: nil)
                    }
                }.always
                {
                    // Hide ProgressIndicator after processed
                    ProgressHelper.sharedInstance.hideFetchLocationLoadingHUD()
                }.catch
                {
                    // Catch the error log
                    (error) in
                    print(error.localizedDescription)
            }
        }))
        
        // Append the actions
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}

extension ForecastViewController {
    
    @objc func updateUI(_notification: NSNotification) {
        DispatchQueue.main.async {
            
            self.weatherLocation.text = self.forecastViewModel.WeatherDetails.location
            self.weatherRate.text = self.forecastViewModel.WeatherDetails.temp
            self.weatherDesc.text = self.forecastViewModel.WeatherDetails.weather
            self.weatherDate.text = self.forecastViewModel.WeatherDetails.date
            self.weatherImg.image = UIImage(named: self.forecastViewModel.WeatherDetails.weatherIcon)
        }
    }
    
}
