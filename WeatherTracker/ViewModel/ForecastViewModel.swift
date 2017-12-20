//
//  ForecastViewModel.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 15/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit

class ForecastViewModel {
    
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
    
    func getWeatherWithCoordinates(lat: Double, lon:Double)
    {
        
        let url = URL(string: "\(BaseURL.openWeatherMapBaseURL)?lat=\(lat)&lon=\(lon)&APPID=\(BaseURL.openWeatherMapAPIKey)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 404{
                    
                    let alert = UIAlertController(title: "Alert", message: "City not found!!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    return
                }else if(httpResponse.statusCode == 400){
                    
                    let alert = UIAlertController(title: "Alert", message: "Please provide valid inputs!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController?.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
            if error != nil {
                print("some error occured")
            }
            else
            {
                
                if let urlContent =  data {
                    
                    let dataStr = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    print(dataStr)
                    
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                        
                        // I would not recommend to use NSDictionary, try using Swift types instead
                        guard let newValue = jsonResult as? [String: Any] else {
                            print("invalid format")
                            return
                        }
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .long
                        dateFormatter.timeStyle = .none
                        
                        // Check for the weather parameter as an array of dictionaries and than excess the first array's description
                        if let main = newValue["main"] as? Dictionary<String, AnyObject>, let temp = main["temp"] as? Double,
                            let weatherArray = newValue["weather"] as? [[String: Any]], let weather = weatherArray[0]["main"] as? String,
                            let weatherIcon = weatherArray[0]["icon"] as? String,
                            let cityName = newValue["name"] as? String, let countryObj = newValue["sys"] as? Dictionary<String, AnyObject>,
                            let countryName = countryObj["country"] as? String, let date = newValue["dt"] as? Double
                            
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
                        
                    }catch {
                        print("JSON Preocessing failed")
                    }
                }
            }
        }
        task.resume()
        
    }
    
    
    func getWeather(city: String)
    {
        
        let url = URL(string: "\(BaseURL.openWeatherMapBaseURL)?APPID=\(BaseURL.openWeatherMapAPIKey)&q=\(city)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 404{
                    
                    let alert = UIAlertController(title: "Alert", message: "City not found!!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    // post a notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HideLoader"), object: nil, userInfo: nil)
                    
                    return
                }else if(httpResponse.statusCode == 400){
                    
                    let alert = UIAlertController(title: "Alert", message: "Please provide valid inputs!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    // post a notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HideLoader"), object: nil, userInfo: nil)
                    
                    return
                }
            }
            
            if error != nil {
                print("some error occured")
            }
            else
            {
                
                if let urlContent =  data {
                    
                    let dataStr = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    print(dataStr)
                    
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                        
                        // I would not recommend to use NSDictionary, try using Swift types instead
                        guard let newValue = jsonResult as? [String: Any] else {
                            print("invalid format")
                            return
                        }
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .long
                        dateFormatter.timeStyle = .none
                        
                        // Check for the weather parameter as an array of dictionaries and than excess the first array's description
                        if let main = newValue["main"] as? Dictionary<String, AnyObject>, let temp = main["temp"] as? Double,
                            let weatherArray = newValue["weather"] as? [[String: Any]], let weather = weatherArray[0]["main"] as? String,
                            let weatherIcon = weatherArray[0]["icon"] as? String,
                            let cityName = newValue["name"] as? String, let countryObj = newValue["sys"] as? Dictionary<String, AnyObject>,
                            let countryName = countryObj["country"] as? String, let date = newValue["dt"] as? Double
                            
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
                        
                    }catch {
                        print("JSON Preocessing failed")
                    }
                }
            }
        }
        task.resume()
        
    }
    
    func getFiveDaysForecastData(city: String) {
        
        let cityNames = city.components(separatedBy: ",")
        let cityName = cityNames[0]
        //        for cityName in cityNames{
        //            print (cityName)
        //        }
        
        let url = URL(string: "\(BaseURL.openFiveDayMapBaseURL)?APPID=\(BaseURL.openWeatherMapAPIKey)&q=\(cityName)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("some error occured")
            } else {
                
                if let urlContent =  data {
                    
                    let dataStr = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    print(dataStr)
                    
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                        
                        // I would not recommend to use NSDictionary, try using Swift types instead
                        guard let newValue = jsonResult as? [String: Any] else {
                            print("invalid format")
                            
                            return
                        }
                        
                        if let listweather = newValue["list"] as? [[String: Any]] {
                            
                            self._forecastModelList = [ForecastModel]()
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .long
                            dateFormatter.timeStyle = .none
                            
                            for i in (0..<listweather.count)
                            {
                                if let main = listweather[i]["main"] as? Dictionary<String, AnyObject>, let temp = main["temp"] as? Double,
                                    let weatherArray = listweather[i]["weather"] as? [[String: Any]],let weather = weatherArray[0]["main"] as? String,
                                    let weatherIcon = weatherArray[0]["icon"] as? String,
                                    let countryObj = newValue["city"] as? Dictionary<String, AnyObject>,
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
                            
                            // post a notification
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "weatherForecastDataNotified"), object: nil, userInfo: nil)
                            
                        }
                        
                    }catch {
                        print("JSON Preocessing failed")
                    }
                }
            }
        }
        task.resume()
        
    }
    
    
    
}
