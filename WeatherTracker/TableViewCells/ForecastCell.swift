//
//  ForecastCell.swift
//  WeatherTracker
//
//  Created by Wipro Suthan M on 16/12/17.
//  Copyright © 2017 wipro. All rights reserved.
//

import UIKit

class ForecastCell: UITableViewCell {
    
    @IBOutlet weak var weatherLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var weatherImgView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    // MARK: - Type Properties
    
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
