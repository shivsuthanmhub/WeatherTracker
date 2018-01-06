//
//  ForecastViewModel.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 15/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit
import PromiseKit

class ForecastViewModel:NSObject  {
    
    // Instances of Models
    
    var _forecastModel: ForecastModel?
    var _forecastModelList = [ForecastModel]()
    
    var WeatherDetails: ForecastModel {
        
        get{
            return self._forecastModel!
        }
        set{
            self._forecastModel = newValue
        }
    }
    
    var WeatherDetailsFiveDaysList: [ForecastModel] {
        
        get{
            return _forecastModelList
        }
        set{
            self._forecastModelList = newValue
        }
    }
    
    // Override Init
    
    override init() {
    super.init()
        
        // Show ProgressIndicator while processing
        ProgressHelper.sharedInstance.showFetchLocationLoadingHUD()
        
        // Get Current location from location helper class
        LocationHelper.sharedInstance.getCurrentLocation().then{ coord -> Void in
            
            // Get Weather Data using Co-ordinates
            self.getWeatherWithCoordinates(lat: coord.latitude, lon: coord.longitude).then
                { model -> Void in
                    // set the response
                    self._forecastModel = model
                }
                .always
                {
                    // send notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "weatherDataNotified"), object: nil, userInfo: nil)
            }
            }.always
            {
                // Hide ProgressIndicator after processed
                ProgressHelper.sharedInstance.hideFetchLocationLoadingHUD()
            }
            // Catch the error log
            .catch { (error) in
                print(error.localizedDescription)
        }
    }
}

extension ForecastViewModel: UITableViewDataSource {
    
    // Forecast Table Process
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._forecastModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.reuseIdentifier, for: indexPath) as? ForecastCell else { fatalError("Unexpected Table View Cell") }
        
        let weatherForecastData = self._forecastModelList[indexPath.row]
        
        //Did set cell
        cell.cellModel = weatherForecastData
        
        return cell
    }
    
}

extension ForecastViewModel {
    
    //Get Five days forecast data
    
    func getFiveDaysForecastData(city: String) -> Promise <[ForecastModel]>
    {
        let cityNames = city.components(separatedBy: ",")
        let cityName = cityNames[0]
        
        return Promise { success, failure in
            
            let urlString = "\(BaseURL.openFiveDayMapBaseURL)?APPID=\(BaseURL.openWeatherMapAPIKey)&q=\(cityName)"
            
            var request: URLRequest?
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
            
            let session = URLSession.shared
            //Force upwrapping request since it's never be nil
            let dataTask = session.dataTask(with: request!) { data, response, error in
                if let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Dictionary<String, Any>,
                    let result = self.parseWeatherData(jsonDictionary: json) {
                    success(result as! [ForecastModel])
                    // post a notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "weatherForecastDataNotified"), object: nil, userInfo: nil)
                } else if let error = error {
                    failure(error)
                } else {
                    let error = NSError(domain: "WeatherTracker", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                    failure(error)
                }
            }
            dataTask.resume()
        }
    }
}

extension ForecastViewModel {
    
    // Get weather data using city
    
    func getWeather(city: String) -> Promise <ForecastModel>
    {
        return Promise { success, failure in
            
            let urlString = "\(BaseURL.openWeatherMapBaseURL)?APPID=\(BaseURL.openWeatherMapAPIKey)&q=\(city)"
            
            var request: URLRequest?
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
            
            let session = URLSession.shared
            //Force upwrapping request since it's never be nil
            let dataTask = session.dataTask(with: request!) { data, response, error in
                if let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Dictionary<String, Any>,
                    let result = self.parseWeatherData(jsonDictionary: json) {
                    success(result as! ForecastModel)
                } else if let error = error {
                    failure(error)
                } else {
                    let error = NSError(domain: "WeatherTracker", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                    failure(error)
                }
            }
            dataTask.resume()
        }
    }
}

extension ForecastViewModel {
    
    // Get weather data using coordinates
    
    func getWeatherWithCoordinates(lat: Double, lon:Double) -> Promise <ForecastModel> {
        
        return Promise { success, failure in
            
            let urlString = "\(BaseURL.openWeatherMapBaseURL)?lat=\(lat)&lon=\(lon)&APPID=\(BaseURL.openWeatherMapAPIKey)"
            
            var request: URLRequest?
            if let url = URL(string: urlString) {
                request = URLRequest(url: url)
            }
            
            let session = URLSession.shared
            //Force upwrapping request since it's never be nil
            let dataTask = session.dataTask(with: request!) { data, response, error in
                if let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Dictionary<String, Any>,
                    let result = self.parseWeatherData(jsonDictionary: json) {
                    success(result as! ForecastModel)
                }
                else if let error = error {
                    failure(error)
                } else {
                    let error = NSError(domain: "WeatherTracker", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                    failure(error)
                }
            }
            dataTask.resume()
        }
    }
}

extension ForecastViewModel {
    
    // Parse the weather response
    
    func parseWeatherData(jsonDictionary: Dictionary<String, Any>) -> Any?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        if let listweather = jsonDictionary["list"] as? [[String: Any]] {
            
            self._forecastModelList = [ForecastModel]()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            
            for i in (0..<listweather.count)
            {
                if let main = listweather[i]["main"] as? Dictionary<String, AnyObject>, let temp = main["temp"] as? Double,
                    let weatherArray = listweather[i]["weather"] as? [[String: Any]],let weather = weatherArray[0]["main"] as? String,
                    let weatherIcon = weatherArray[0]["icon"] as? String,
                    let countryObj = jsonDictionary["city"] as? Dictionary<String, AnyObject>,
                    let cityName = countryObj["name"] as? String,
                    let countryName = countryObj["country"] as? String,
                    let date = listweather[i]["dt"] as? Double,
                    let time = listweather[i]["dt_txt"] as? String
                    
                {
                    let forecastModel = ForecastModel()
                    forecastModel.location = "\(cityName), \(countryName)"
                    forecastModel.temp = String(format: "%.0f °C", temp - 273.15)
                    forecastModel.weather = weather
                    forecastModel.date = (dateFormatter.string(from: Date(timeIntervalSince1970: date)))
                    forecastModel.weatherIcon = weatherIcon
                    
                    let timeDatas = time.components(separatedBy: " ")
                    let timeData = timeDatas[1]
                    forecastModel.time = timeData
                    
                    self._forecastModelList.append(forecastModel)
                }
            }
            return self._forecastModelList as Any
        }
        else{
            if let main = jsonDictionary["main"] as? Dictionary<String, AnyObject>, let temp = main["temp"] as? Double,
                let weatherArray = jsonDictionary["weather"] as? [[String: Any]], let weather = weatherArray[0]["main"] as? String,
                let weatherIcon = weatherArray[0]["icon"] as? String,
                let cityName = jsonDictionary["name"] as? String, let countryObj = jsonDictionary["sys"] as? Dictionary<String, AnyObject>,
                let countryName = countryObj["country"] as? String, let date = jsonDictionary["dt"] as? Double
            {
                self._forecastModel = ForecastModel()
                self._forecastModel?.temp = String(format: "%.0f °C", temp - 273.15)
                self._forecastModel?.location = "\(cityName), \(countryName)"
                self._forecastModel?.weather = weather
                let date = Date(timeIntervalSince1970: date)
                self._forecastModel?.date = dateFormatter.string(from: date)
                self._forecastModel?.weatherIcon = weatherIcon
                
                // post a notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "weatherDataNotified"), object: nil, userInfo: nil)
            }
            return self._forecastModel as Any
        }
    }
}
