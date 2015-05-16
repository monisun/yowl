//
//  BusinessCell.swift
//  Yelp
//
//  Created by Monica Sun on 5/16/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
    
    @IBOutlet weak var thumbView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var rating: UIImageView!

    @IBOutlet weak var addr: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var reviews: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            thumbView.setImageWithURL(business.imageURL)
            type.text = business.categories
            addr.text = business.address
            reviews.text = "\(business.reviewCount!) Reviews"
            rating.setImageWithURL(business.ratingImageURL)
            distance.text = business.distance
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbView.layer.cornerRadius = 5
        thumbView.clipsToBounds = true
        thumbView.contentMode = UIViewContentMode.ScaleAspectFill
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
