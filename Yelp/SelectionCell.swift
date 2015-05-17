//
//  SectionCell.swift
//  Yelp
//
//  Created by Monica Sun on 5/16/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var filterIsSelected = false

    override func awakeFromNib() {
        super.awakeFromNib()
                
        // clear nameLabel
        nameLabel.text = ""
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
         self.layer.cornerRadius = 3
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        filterIsSelected = true

        // Configure the view for the selected state
    }

}
