//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by  Monica Sun on 5/15/15.
//  Copyright (c) 2015  Monica Sun. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {

    var businesses: [Business]!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        

        Business.searchWithTerm("Restaurant", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
            for business in businesses {
                println(business.name!)
                println(business.address!)
            }
        })
        
//        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["food"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            self.tableView.reloadData()
//            
//            for business in businesses {
//                println(business.name!)
//                println(business.address!)
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        var searchTerm = "restaurant"   // default
        
        // deals
        var dealsFilter = false
        if let deals = filters["deals"] as! Bool? {
            dealsFilter = deals
        }
        
        // distance
        var distance: Double!
        if let d = filters["distance"] as! Double? {
            distance = d
        } else {
            distance = nil
        }
        
        // sort by
        var sort: YelpSortMode!
        if let sortMode = filters["sort"] as! YelpSortMode.RawValue? {
            switch sortMode {
            case 0:
                sort = YelpSortMode.BestMatched
            case 1:
                sort = YelpSortMode.Distance
            default:
                // 2
                sort = YelpSortMode.HighestRated
            }
        } else {
            sort = nil
        }
        
        // categories
        var categories = filters["categories"] as? [String]

        Business.searchWithTerm(searchTerm, sort: sort, categories: categories, deals: dealsFilter, distance: distance) {
            (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }


}
