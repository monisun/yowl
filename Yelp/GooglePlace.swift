//
//  GooglePlace.swift
//  Yelp
//
//  Created by Monica Sun on 5/17/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GooglePlace {
    //    let supportedTypes = [
    //        "bakery", "bar", "cafe",
    //        "grocery_or_supermarket",
    //        "restaurant", "convenience_store",
    //        "airport", "beauty_salon", "atm",
    //        "bank", "park", "movie_theatre",
    //        "pharmacy", "gym", "hospital",
    //        "book_store", "health", "lawyer",
    //        "school", "night_club", "spa",
    //        "dentist", "university", "zoo",
    //        "church", "florist", "museum",
    //        "food", "post_office", "police",
    //        "bus_station", "car_rental", "car_repair"
    //    ]
    
    let place_id: String
    let name: String
    //    let address: String
    let coordinate: CLLocationCoordinate2D
    //    let photoReference: String?
    //    var placeType: String?
    //    var photo: UIImage?
    //
    //    // Place Detail and "premium" attributes
    //    var formatted_phone_number: String?
    //    var icon: String?
    //    var opening_hours: NSDictionary?
    //    var open_now: Bool?
    //    var open: (Int, Int)?
    //    var close: (Int, Int)?
    //    var photos: NSArray?
    //    var price_level: Int?
    //    var rating: String?
    //    var reviews: NSArray?
    //    var url: String?
    //    var website: String?
    //    var review_summary: String?
    //    var zagat_selected: Bool?
    
    
    /* 12 key-value entries in dictionary from query search response:
    id, rating, types, formatted_address, geometry, icon, place_id, opening_hours, photos, price_level, name, reference
    */
    
    init(dictionary:NSDictionary, acceptedTypes: [String])
    {
        //debug
        //println("dictionary: \(dictionary)")
        //
        place_id = dictionary["place_id"] as! String
        name = dictionary["name"] as! String
        //        if (dictionary["vicinity"]? != nil) {
        //            address = dictionary["vicinity"]? as String
        //        } else {
        //            //try "formatted_address"
        //            address = dictionary["formatted_address"]? as String
        //        }
        //
        //        //let rating = dictionary["rating"]? as Double
        //        //let priceLevel = dictionary["price_level"]? as CLong
        //
        let location = dictionary["geometry"]?["location"] as! NSDictionary
        let lat = location["lat"] as! CLLocationDegrees
        let lng = location["lng"] as! CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        //
        //        if let photos = dictionary["photos"] as? NSArray {
        //            let photo = photos.firstObject as NSDictionary
        //            photoReference = photo["photo_reference"] as? NSString
        //        }
        //
        //        if (dictionary["types"] != nil) {
        //            let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : supportedTypes
        //            for type in dictionary["types"] as [String] {
        //                if contains(possibleTypes, type) {
        //                    placeType = type
        //                    break
        //                }
        //            }
        //        } else {
        //            // TODO: one/more search results for "star" did not contain dictionary["types"], so this is a workaround for bad GooglePlaces API results data
        //            placeType = "food"
        //        }
        
        
        /* relevant entries for PlaceDetail:
        formatted_address, formatted_phone_number, icon, opening_hours (-> open_now),
        photos[] -> photo, place_id, price_level, rating, reviews[], types[], url, website
        Premium data:
        review_summary
        zagat_selected
        */
        
        //        let formatted_phone_number = dictionary["formatted_phone_number"] as? String
        //        let icon = dictionary["icon"] as? String
        //        if let opening_hours = dictionary["opening_hours"] as? NSDictionary {
        //            let open_now = opening_hours["open_now"] as? Bool
        //            let open: AnyObject? = opening_hours["open"]
        //            let close: AnyObject? = opening_hours["close"]
        //        }
        //
        //        let photos = dictionary["photos"] as? NSArray
        //        let price_level = dictionary["price_level"] as? Int
        //        let rating = dictionary["rating"] as? String
        //        let reviews = dictionary["reviews"] as? NSArray
        //        let url = dictionary["url"] as? String
        //        let website = dictionary["website"] as? String
        //        
        //        //premium
        //        let review_summary = dictionary["review_summary"] as? String
        //        let zagat_selected = dictionary["zagat_selected"] as? Bool
    }
}
