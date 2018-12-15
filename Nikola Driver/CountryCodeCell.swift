//
//  CountryCodeCell.swift
//  Nikola
//
//  Created by Shantha Kumar on 10/7/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit

class CountryCodeCell: UITableViewCell {

    @IBOutlet weak var mapImg: UIImageView!
    
    @IBOutlet weak var lblCountryName: UILabel!
    
    
    @IBOutlet weak var lblCountryCode: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
