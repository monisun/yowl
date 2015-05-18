//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by  Monica Sun on 5/15/15.
//  Copyright (c) 2015  Monica Sun. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    var businesses: [Business]!
    var filtered = [Business]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar = UISearchBar()
    var searchActive = false
    
    let resultsPerRequest = 20
    var pageScrolled = 1
    var lastSearchedTerm = String()
    var lastUsedFilters = [String : AnyObject]()
    let maxResultsToKeepInMemory = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
//        searchBar.showsCancelButton = true
        searchBar.translucent = true
        
        // landing page query
        Business.searchWithTerm("food", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
            for business in businesses {
                println(business.name!)
                println(business.address!)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if businesses != nil && businesses.count > maxResultsToKeepInMemory {
            businesses.removeRange(Range(start: 0, end: maxResultsToKeepInMemory))
        }
        
        if filtered.count > maxResultsToKeepInMemory {
            filtered.removeRange(Range(start: 0, end: maxResultsToKeepInMemory))
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        filtered.removeAll(keepCapacity: false)
        let searchTerms = searchBar.text
        lastSearchedTerm = searchTerms

        Business.searchWithTerm(searchTerms, completion: {  (results: [Business]!, error: NSError!) -> Void in
            self.filtered = results
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        } else {
            if businesses != nil {
                return businesses!.count
            } else {
                return 0
            }
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        if searchActive && (filtered.count > indexPath.row) {
            cell.business = filtered[indexPath.row]
        } else {
            cell.business = businesses[indexPath.row]
        }
        
        if indexPath.row % resultsPerRequest == 0 {
            // fetch more results
            var filters = lastUsedFilters
            if !lastSearchedTerm.isEmpty {
                filters["searchTerm"] = lastSearchedTerm
            }
            filters["offset"] = pageScrolled * resultsPerRequest
            pageScrolled++
            performSearchWithTerm(filters)
        }
        
        return cell
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filtersSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        }
        
        if segue.identifier == "mapSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let mapViewController = navigationController.topViewController as!  MapViewController
            if searchActive {
                mapViewController.businesses = filtered
            } else {
                mapViewController.businesses = businesses
            }
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        lastUsedFilters = filters
        performSearchWithTerm(filters)
    }
    
    func performSearchWithTerm(filters: [String : AnyObject]) -> Void {
        var searchTerm = "restaurant"
        if let searchTermInFilters = filters["searchTerm"] as? String {
            searchTerm = searchTermInFilters
        }
        
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
        
        // offset
        var offset: Int!
        if let o = filters["offset"] as? Int {
            offset = o
        } else {
            offset = nil
        }
        
        Business.searchWithTerm(searchTerm, sort: sort, categories: categories, deals: dealsFilter, distance: distance, offset: offset) {
            (businesses: [Business]!, error: NSError!) -> Void in
            if businesses != nil {
                if offset == nil {
                    // new search
                    self.businesses = businesses
                } else {
                    // fetch for scroll
                    self.businesses.extend(businesses)
                }
                self.tableView.reloadData()
            } else {
                NSLog("WARNING: Yelp did not return any results! businesses is nil in callback.")
            }
        }
    }

}
