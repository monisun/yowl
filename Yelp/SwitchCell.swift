//
//  SwitchCell.swift
//  Yelp
//
//  Created by Monica Sun on 5/16/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchSwitch: SwitchCell, didChangeValue value: Bool)
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
