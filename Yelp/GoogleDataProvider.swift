//
//  GoogleDataProvider.swift
//  Yelp
//
//  Created by Monica Sun on 5/17/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GoogleDataProvider {
    
    let apiKey = "AIzaSyCUKOGbyRpou8Ll_Cs5Vlsu88LA9WkLRP8"
    var photoCache = [String:UIImage]()
    var placesTask = NSURLSessionDataTask()
    var textQueryTask = NSURLSessionDataTask()
    var placeDetailQueryTask = NSURLSessionDataTask()
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    // Updated implementations:
    
    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: (NSDictionary -> Void)) -> ()
    {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?key=\(apiKey)&origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=driving"
        var results: NSMutableDictionary = [:]
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        session.dataTaskWithURL(NSURL(string: urlString)!) { data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? [String:AnyObject] {
                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    if let route = routes.first as? [String : AnyObject] {
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                            }
                        }
                        results.setValue(encodedRoute, forKey: "encodedRoute")
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(results)
            }
            }.resume()
    }
    
    
    
    //nearby search
    //    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: (([GooglePlace]) -> Void)) -> ()
    //    {
    //        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
    //        let typesString = types.count > 0 ? join("|", types) : "food"
    //        urlString += "&types=\(typesString)"
    //        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    //
    //        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
    //            placesTask.cancel()
    //        }
    //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    //        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
    //            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    //            var placesArray = [GooglePlace]()
    //            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
    //                //print error message
    //
    //                if let results = json["results"] as? NSArray {
    //                    for rawPlace:AnyObject in results {
    //                        let place = GooglePlace(dictionary: rawPlace as NSDictionary, acceptedTypes: types)
    //                        placesArray.append(place)
    //                        if let reference = place.photoReference {
    //                            self.fetchPhotoFromReference(reference) { image in
    //                                place.photo = image
    //                                //debug
    //                                //println("current place name: ")
    //                                //println(place.name)
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //
    //            dispatch_async(dispatch_get_main_queue()) {
    //                completion(placesArray)
    //            }
    //        }
    //        placesTask.resume()
    //    }
    
    
    //this only supports mode=driving
    //    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: (NSDictionary -> Void)) -> ()
    //    {
    //        let urlString = "https://maps.googleapis.com/maps/api/directions/json?key=\(apiKey)&origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=driving"
    //        var results: NSMutableDictionary = [:]
    //        var directionsHTMLStringArray: [String] = []
    //        //        var distanceStringArray: [String] = []
    //        //        var durationStringArray: [String] = []
    //
    //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    //        session.dataTaskWithURL(NSURL(string: urlString)!) { data, response, error in
    //            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    //            var encodedRoute: String?
    //            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? [String:AnyObject] {
    //                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
    //                    if let route = routes.first as? [String : AnyObject] {
    //                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
    //                            if let points = polyline["points"] as AnyObject? as? String {
    //                                encodedRoute = points
    //                            }
    //                        }
    //                        results.setValue(encodedRoute, forKey: "encodedRoute")
    //
    //                        // fetch directions HTML strings
    //                        if let legs = route["legs"] as? [NSDictionary] {
    //                            for leg in legs {
    //                                if let steps = leg["steps"] as? [NSDictionary] {
    //                                    for step in steps {
    //                                        if let directionsHTMLString = step["html_instructions"] as? String {
    //                                            var cdistanceText: String = ""
    //                                            var cdurationText: String = ""
    //                                            if let distanceInfo = step["distance"] as? NSDictionary {
    //                                                if let distanceText = distanceInfo["text"] as? String {
    //                                                    //                                                    distanceStringArray.append("(\(distanceText))")
    //                                                    cdistanceText = distanceText
    //                                                }
    //                                            }
    //                                            if let durationInfo = step["duration"] as? NSDictionary {
    //                                                if let durationText = durationInfo["text"] as? String {
    //                                                    //                                                    durationStringArray.append(durationText)
    //                                                    cdurationText = durationText
    //                                                }
    //                                            }
    //                                            directionsHTMLStringArray.append("\(directionsHTMLString)&nbsp;&nbsp;\(cdurationText)&nbsp;(\(cdistanceText))")
    //                                        }
    //                                    }
    //                                }
    //                            }
    //                        }
    //                        results.setValue(directionsHTMLStringArray, forKey: "directionsHTMLStringArray")
    //                        //                        results.setValue(distanceStringArray, forKey: "distanceStringArray")
    //                        //                        results.setValue(durationStringArray, forKey: "durationStringArray")
    //                    }
    //                }
    //            }
    //            dispatch_async(dispatch_get_main_queue()) {
    //                completion(results)
    //            }
    //            }.resume()
    //    }
    
    
    func fetchPhotoFromReference(reference: String, completion: ((UIImage?) -> Void)) -> ()
    {
        if let photo = photoCache[reference] as UIImage! {
            completion(photo)
        } else {
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photoreference=\(reference)&key=\(apiKey)"
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            session.downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let valid_url = url {
                    let downloadedPhoto = UIImage(data: NSData(contentsOfURL: url)!)
                    self.photoCache[reference] = downloadedPhoto
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(downloadedPhoto)
                    }
                }
                }.resume()
        }
    }
    
    // text search query
    //    func queryPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, queryWordsArray:[String], scopeConditions: String, completion: (([GooglePlace]) -> Void)) -> ()
    //    {
    //        // ex: "https://maps.googleapis.com/maps/api/place/textsearch/xml?query=restaurants+in+Sydney&key;=AddYourOwnKeyHere"
    //        var urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence"
    //        let queryString = queryWordsArray.count > 0 ? join("+", queryWordsArray) : "venue"
    //        urlString += "&query=\(queryString)"
    //
    //        // add scopeConditions if there are any
    //        if !scopeConditions.isEmpty {
    //            urlString += scopeConditions
    //        }
    //
    //        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    //        println("DEBUG: urlstring: \(urlString)")
    //
    //        if self.textQueryTask.taskIdentifier > 0 && self.textQueryTask.state == .Running {
    //            self.textQueryTask.cancel()
    //        }
    //        var placeIdSet = NSMutableSet()
    //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    //        self.textQueryTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
    //            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    //
    //            var placesArray = [GooglePlace]()
    //            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
    //                //            print error message
    //                //                println(json["error_message"]!)
    //                //                println(json)
    //
    //                if let results = json["results"] as? NSArray {
    //                    for rawPlace:AnyObject in results {
    //                        let place = GooglePlace(dictionary: rawPlace as NSDictionary, acceptedTypes: [])
    //                        if let reference = place.photoReference {
    //                            self.fetchPhotoFromReference(reference) { image in
    //                                place.photo = image
    //                            }
    //                        }
    //
    //                        if (!placeIdSet.containsObject(place.place_id)) {
    //                            placesArray.append(place)
    //                            placeIdSet.addObject(place.place_id)
    //                        }
    //                    }
    //                }
    //            }
    //            dispatch_async(dispatch_get_main_queue()) {
    //                completion(placesArray)
    //            }
    //        }
    //        self.textQueryTask.resume()
    //    }
    
    
    // place detail query
    func queryPlaceDetailById(placeId: String, completion:(result: NSDictionary) -> ())
    {
        // ex: https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&key;=AddYourOwnKeyHere
        var urlString = "https://maps.googleapis.com/maps/api/place/details/json?key=\(apiKey)&placeid=\(placeId)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if self.placeDetailQueryTask.taskIdentifier > 0 && self.placeDetailQueryTask.state == .Running {
            self.placeDetailQueryTask.cancel()
        }
        //        var placeDetailArray: [GooglePlace
        //        var myDictionary = NSDictionary()
        //        var myAcceptedTypes = ["food"]
        //        var placeDetail = GooglePlace(dictionary: myDictionary, acceptedTypes: myAcceptedTypes)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.placeDetailQueryTask = session.dataTaskWithURL(NSURL(string: urlString)!) { data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var result = NSDictionary()
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                println("retrieved JSON data result")
                //                //print error message
                //                println(json["error_message"]!)
                //                println(json)]
                
                result = json["result"] as! NSDictionary!
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(result: result)
            }
            
        }
        self.placeDetailQueryTask.resume()
    }
    
    
}
