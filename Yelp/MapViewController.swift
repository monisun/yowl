//
//  MapViewController.swift
//  Yelp
//
//  Created by Monica Sun on 5/17/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    
    var businesses = [Business]()
    var pins = [[String: AnyObject]]()     // {"name", "coordinate", "image"}
    var placesTask = NSURLSessionDataTask()
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var defaults = NSUserDefaults.standardUserDefaults()
    var lastKnownCameraPosition = CLLocationCoordinate2D()
    
    // indicates whether location is for start or end location
    var willSetStartLocation = true
    
    var mapRadius: Double {
        get {
            let region = mapView.projection.visibleRegion()
            let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
            let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
            return max(horizontalDistance, verticalDistance) * 0.5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        if businesses.count > 0 {
            self.loadMarkers("marker", completion: { (results) -> Void in
                if let results = results as [PinMarker]! {
                    println("results:")
                    println(results)
                    
                    for pin in results {
                        pin.map = self.mapView
                    }
                }
            })
        }
    }
    
    
    func loadMarkers(markerImageName: String, completion: ([PinMarker]) -> Void) {
        var pinList = [PinMarker]()
        
        var shortened = businesses[0..<4]
        
        for business in shortened {
            var markerImage = UIImage(named: markerImageName)
            var coordinate = CLLocationCoordinate2D()
            var name = String()
            if let address = business.address as String? {
                println(address)
                geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                    if let placemark = placemarks?[0] as? CLPlacemark {
                        coordinate = placemark.location.coordinate as CLLocationCoordinate2D
                        println(coordinate.latitude)
                        println(coordinate.longitude)
                        name = business.name!
                        println(name)
                        
                        var pin = PinMarker(coordinate: coordinate, image: markerImage!, snippetText: name, imageUrl: business.imageURL!)
                        pin.map = self.mapView
                        pinList.append(pin)
                        self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
                    }
                })
                
            }
        }
       
        dispatch_async(dispatch_get_main_queue()) {
            completion(pinList)
        }
    }
    
    
    @IBAction func mapTypeSegmentPressed(sender: AnyObject) {
        let segmentedControl = sender as! UISegmentedControl
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = kGMSTypeNormal
        case 1:
            mapView.mapType = kGMSTypeSatellite
        case 2:
            mapView.mapType = kGMSTypeHybrid
        default:
            mapView.mapType = kGMSTypeNormal
        }

    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            //debug
            println("current location: \(location.coordinate)")
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        self.lastKnownCameraPosition = position.target
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
 
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let placeMarker = marker as! PinMarker
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            
            infoView.layer.cornerRadius = 5
            infoView.clipsToBounds = true
            infoView.layer.borderWidth = 0.5
            infoView.layer.borderColor = UIColor.purpleColor().CGColor
            
            return infoView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
    
    var randomLineColor: UIColor {
        get {
            let randomRed = CGFloat(drand48())
            let randomGreen = CGFloat(drand48())
            let randomBlue = CGFloat(drand48())
            return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        }
    }
    

    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let googleMarker = mapView.selectedMarker as! PinMarker
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}



