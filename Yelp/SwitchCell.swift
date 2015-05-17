//
//  SwitchCell.swift
//  Yelp
//
//  Created by Monica Sun on 5/16/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    
    
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var filterSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.cornerRadius = 3
        
        filterSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        // switch styling
        filterSwitch.thumbTintColor = UIColor(red: 0.39, green:0.13, blue:0.33, alpha:1.00)
        filterSwitch.onTintColor = UIColor(red: 0.65, green:0.18, blue:0.47, alpha:1.00)
        filterSwitch.layer.borderColor = UIColor.clearColor().CGColor
        filterSwitch.layer.shadowColor = UIColor.blackColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        println("switch value changed")
        
        delegate?.switchCell?(self, didChangeValue: filterSwitch.on)
    }

}
