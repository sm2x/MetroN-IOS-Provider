//
//  SideMenuTopCell.swift
//  Nikola
//
//  Created by Sutharshan on 5/23/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import Foundation


import UIKit
import Toucan
import AlamofireImage

class SideMenuTopCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        imgView.cornerRadius = imgView.frame.size.width/2
//        imgView.image = imgView.image!
        
        let size = CGSize(width: 100.0, height: 100.0)
        let filter = AspectScaledToFillSizeCircleFilter(size: size)
        
        let defaults = UserDefaults.standard
        var pic: String = defaults.string(forKey: Const.Params.PICTURE)!
        
        if !pic.isEmpty{
            pic = pic.decodeUrl()
            
            let url = URL(string: pic)!
            let placeholderImage = UIImage(named: "ellipse_contacting")!
            
            imgView?.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: filter
            )
        }else{
            
            imgView.image = UIImage(named: "driver")!
            //imgView.image = Toucan(image: UIImage(named: "driver")!).maskWithEllipse().image
        }
        
        lblName.text = defaults.string(forKey: Const.Params.FIRSTNAME)!
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
