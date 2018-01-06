//
//  LocationHelper.swift
//  WeatherTracker
//
//  Created by Wipro on 04/01/18.
//  Copyright © 2018 wipro. All rights reserved.
//

import Foundation
import PromiseKit

// Location Helper Class

class LocationHelper  {

    static let sharedInstance = LocationHelper()

    func getCurrentLocation() -> Promise <CLLocationCoordinate2D>  {
        return Promise {success, failure in
            firstly {
                CLLocationManager.promise()
                }.then {location in
                    success(location.coordinate)
                }.catch { (error) in
                    failure(error)
            }
        }
    }

}
