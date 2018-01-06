//
//  ForecastModel.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 15/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit

class ForecastModel {
    
    // Model Properties of ForecastModel
    
    private var _date: String?
    private var _temp: String?
    private var _location: String?
    private var _weather: String?
    private var _weatherIcon: String?
    private var _time: String?

    var date: String {
        
        get{
            
            return _date ?? "00-00-0000"
        }
        set{
            self._date = newValue

        }
    }
    
    var temp: String
    {
        get
        {
            return _temp ?? "0 °C"
        }
        set
        {
            self._temp = newValue
        }
        
        
    }
    
    var location: String {
        set
        {
            self._location = newValue
            
        }
        get{
            return _location ?? "Location"
            
        }
        
    }
    
    var weather: String
    {
        get
        {
            return _weather ?? "Weather"
        }
        set
        {
            self._weather = newValue
        }
        
    }
    
    var weatherIcon: String
    {
        get
        {
            return _weatherIcon ?? "Icon"
        }
        set
        {
            self._weatherIcon = newValue
        }
        
    }

    var time: String
    {
        get
        {
            return _time ?? "Time"
        }
        set
        {
            self._time = newValue
        }
        
    }

}
