//
//  FilterTitleCell.swift
//  Yelp
//
//  Created by Monica Sun on 5/16/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

@objc protocol FilterTitleCellDelegate {
    optional func filterTitleCell(filterTitleCell: FilterTitleCell, didChangeValue value: Int)
}

class FilterTitleCell: UITableViewCell {
    
    @IBOutlet weak var filterTitleLabel: UILabel!
    
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    weak var delegate: FilterTitleCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // default to food
        categorySegment.selectedSegmentIndex = 0
    
        categorySegment.addTarget(self, action: "segmentValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func segmentValueChanged() {
        println("segment value changed")
        
        delegate?.filterTitleCell?(self, didChangeValue: categorySegment.selectedSegmentIndex)
    }

}
