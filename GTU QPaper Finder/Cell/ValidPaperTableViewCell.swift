//
//  ValidPaperTableViewCell.swift
//  GTU QPaper Finder
//
//  Created by Ravi on 20/11/17.
//  Copyright © 2017 mammoth. All rights reserved.
//

import UIKit

class ValidPaperTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblPaperName: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnOpen: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
