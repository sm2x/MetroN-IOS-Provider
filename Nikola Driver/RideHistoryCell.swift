//
//  RideHistoryCell.swift
//  Nikola
//
//  Created by Sutharshan Ram on 15/07/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation

class RideHistoryCell: UITableViewCell {
    
    @IBOutlet weak var carImg: UIImageView!    
    @IBOutlet weak var ridetime: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var pickUpAddress: UILabel!
    @IBOutlet weak var dropAddress: UILabel!
    @IBOutlet weak var drivername: UILabel!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
