//
//  PinMarker.swift
//  Yelp
//
//  Created by Monica Sun on 5/17/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class PinMarker: GMSMarker {
    var imageUrl = NSURL()
    
    init(coordinate: CLLocationCoordinate2D, image: UIImage, snippetText: String, imageUrl: NSURL) {
        super.init()
        position = coordinate
        icon = image
        snippet = snippetText
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
        infoWindowAnchor = CGPointMake(1, 0)
        
        self.imageUrl = imageUrl
    }
}
