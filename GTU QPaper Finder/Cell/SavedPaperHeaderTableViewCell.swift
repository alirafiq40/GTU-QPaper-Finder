//
//  SavedPaperHeaderTableViewCell.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 21/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit

class SavedPaperHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPaperCode: UILabel!
    @IBOutlet weak var imageViewArrow: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var lblPaperCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        containerView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
