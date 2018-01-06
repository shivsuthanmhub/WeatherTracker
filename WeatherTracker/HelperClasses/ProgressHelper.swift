//
//  ProgressHelper.swift
//  WeatherTracker
//
//  Created by Wipro on 05/01/18.
//  Copyright © 2018 wipro. All rights reserved.
//

import Foundation
import MBProgressHUD

// Progress Helper Class

class ProgressHelper: NSObject {
    
    static let sharedInstance = ProgressHelper()
    private var progressHUD = MBProgressHUD()

    func showFetchLocationLoadingHUD() {
        
        DispatchQueue.main.async {

            self.progressHUD = MBProgressHUD.showAdded(to: (UIApplication.shared.keyWindow?.rootViewController?.view)!, animated: true);
            self.progressHUD.label.text = "Loading";
            self.progressHUD.isUserInteractionEnabled = false;
        }
    }
    
    func hideFetchLocationLoadingHUD() {
        let when = DispatchTime.now() + 1 
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            MBProgressHUD.hide(for: (UIApplication.shared.keyWindow?.rootViewController?.view)!, animated: true)
        }
    }

}
