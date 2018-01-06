//
//  ForecastCell.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 16/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {
    
    // UI Properties of Forecast Cell
    @IBOutlet weak var weatherLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var weatherImgView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    
    // Did set cell model
    var cellModel: ForecastModel? {
        didSet {
            self.weatherLbl.text = cellModel?.weather
            self.tempLbl.text = cellModel?.temp
            self.dateLbl.text = cellModel?.date
            self.locationLbl.text = cellModel?.location
            self.weatherImgView.image = UIImage(named: (cellModel?.weatherIcon)!)
            self.timeLbl.text = cellModel?.time
        }
    }
    
    static let reuseIdentifier = "ForecastCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Configure Cell
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
