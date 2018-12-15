//
//  UploadyourdocumentsCell.swift
//  
//
//  Created by sudharsan s on 05/12/17.
//
//

import UIKit
import Localize_Swift

class UploadyourdocumentsCell: UITableViewCell {

    @IBOutlet weak var lbltittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         lbltittle.text = "Upload your documents".localized()
        // Configure the view for the selected state
    }

}
