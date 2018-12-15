//
//  HomeCell.swift
//  Nikola Driver
//
//  Created by sudharsan s on 04/12/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import Localize_Swift
class HomeCell: UITableViewCell {

    @IBOutlet weak var lbltittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        lbltittle.text = "Home".localized()
        
        // Configure the view for the selected state
    }

}
