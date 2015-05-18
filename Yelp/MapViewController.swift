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
    var pinMarkerList = [PinMarker]()
    var placesTask = NSURLSessionDataTask()
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var lastKnownCameraPosition = CLLocationCoordinate2D()
    
    let manager = AFHTTPRequestOperationManager()
    
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
            })
        }
    }
    
    
    func loadMarkers(markerImageName: String, completion: ([PinMarker]) -> Void) {
        var pinList = [PinMarker]()
//        var shortened = businesses[0..<4]
        
        for business in businesses {
            var markerImage = UIImage(named: markerImageName)
            var coordinate = CLLocationCoordinate2D()
            var name = String()
            if let address = business.address as String? {
                println(address)
                var bounds = GMSCoordinateBounds()
                
                geocodeLocations(address, name: business.name!, imageUrl: business.imageURL!, completion: {
                    
                })
                
            }
        }
       
        dispatch_async(dispatch_get_main_queue()) {
            completion(pinList)
        }
    }
    
    func geocodeLocations(address: String, name: String, imageUrl: NSURL, completion: () -> Void) {
        // https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=API_KEY
        var url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&key=AIzaSyCUKOGbyRpou8Ll_Cs5Vlsu88LA9WkLRP8"
        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var bounds = GMSCoordinateBounds()
        
        manager.GET(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) in
                if let results = responseObj.objectForKey("results") as! [Dictionary<String, AnyObject>]? {
                    if let addressInfo = results.first as Dictionary<String, AnyObject>? {
                        if let geometry = addressInfo["geometry"] as! Dictionary<String, AnyObject>? {
                            if let location = geometry["location"] as! Dictionary<String, AnyObject>? {
                                if let lat = location["lat"] as! Double? {
                                    if let long = location["lng"] as! Double? {
                                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                        var pin = PinMarker(coordinate: coordinate, image: UIImage(named: "marker")!, snippetText: name, imageUrl: imageUrl)
                                        pin.map = self.mapView
                                        self.pinMarkerList.append(pin)
                                        
                                        if self.pinMarkerList.count > 0 {
                                            for marker in self.pinMarkerList {
                                                bounds = bounds.includingCoordinate(marker.position)
                                            }
                                            self.updateMapviewToShowAllMarkers(bounds)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                NSLog("Error in geocodeLocations: \(error)")
            }
        )
    }

    private func updateMapviewToShowAllMarkers(markerBounds: GMSCoordinateBounds) -> Void {
        var update = GMSCameraUpdate.fitBounds(markerBounds, withPadding: 100.0)
        mapView.moveCamera(update)
        var zoomUpdate = GMSCameraUpdate.zoomTo(13)
        mapView.moveCamera(zoomUpdate)
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
            infoView.frame.size.height = 50
            infoView.frame.size.width = 50
            println(placeMarker.imageUrl)
            infoView.nameLabel.frame.origin = infoView.center
            infoView.nameLabel.text = placeMarker.snippet
            infoView.placeImage.setImageWithURL(placeMarker.imageUrl)
            infoView.layer.cornerRadius = 5
            infoView.clipsToBounds = true
            infoView.layer.borderWidth = 0.5
            infoView.layer.borderColor = UIColor.greenColor().CGColor
            
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



