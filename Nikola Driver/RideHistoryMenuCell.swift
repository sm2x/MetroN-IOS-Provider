//
//  RideHistoryMenuCell.swift
//  Nikola Driver
//
//  Created by sudharsan s on 05/12/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import Localize_Swift

class RideHistoryMenuCell: UITableViewCell {

    @IBOutlet weak var lbltittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         lbltittle.text = "Ride History".localized()
        // Configure the view for the selected state
    }

}
