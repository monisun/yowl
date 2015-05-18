//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Monica Sun on 5/16/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, FilterTitleCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: FiltersViewControllerDelegate?
    
    var distanceFilterSectionIsExpanded = false
    
    // DEALS section
    var dealSwitchState = false
    
    // DISTANCE section
    var distanceFilterValues = [[String: AnyObject]]()
    var selectedDistanceValueIndex = 1  // default selection to Auto
    
    var collapsedDistanceFilterValues = [[String: AnyObject]]()
    
    // SORT BY section
    let sortByValues = ["Best match", "Distance", "Highest rated"]
    var selectedSortByIndex = 0  // default selection to Best Match
    
    // CATEGORIES section
    var categories = [[String: String]]()
    var switchStates = [Int: Bool]()
    
    // supported categories
    var food = [[String: String]]()
    
    var selectedCategorySegmentIndex = 0    // default to Food
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load Yelp categories
        food = yelpFoodCategories()
        
        updateCategories(selectedCategorySegmentIndex)

        tableView.dataSource = self
        tableView.delegate = self
        
        distanceFilterValues.append(["name": "", "code": 0])
        distanceFilterValues.append(["name": "Auto", "code": 0])
        distanceFilterValues.append(["name": "0.3 miles", "code": 0.3])
        distanceFilterValues.append(["name": "1 mile","code": 1])
        distanceFilterValues.append(["name": "5 miles","code": 5])
        distanceFilterValues.append(["name": "20 miles","code": 20])
        
        collapsedDistanceFilterValues.append(["name": "", "code": 0])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSearch(sender: AnyObject) {
        // keys: "deals", "distance", "sortby", "categories",
        var filters = [String: AnyObject]()
        
        // 1. deals
        filters["deals"] = dealSwitchState
        
        // 2. distance, per Yelp API: "Distance that business is from search location in meters, if a latitude/longitude is specified."
        // TODO use real location
        filters["distance"] = getDistanceInMetersByIndex(selectedDistanceValueIndex) as Double?
        
        // 3. sort by
        filters["sort"] = getSortByEnumValue(selectedSortByIndex)?.rawValue
        
        // 4. categories
        // e.g. ["categories": ["afghani", "african"]]
        
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        delegate?.filtersViewController(self, didUpdateFilters: filters)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        switch(indexPath.section) {
        case 3:
            // categories
            switchStates[indexPath.row] = value
        case 0:
            // offering a deal
            dealSwitchState = value
        default:
            NSLog("UNEXPECTED switchCell for section: \(indexPath.section)")
        }
        
        println("filters VC got this switch event")
    }
    
    func filterTitleCell(filterTitleCell: FilterTitleCell, didChangeValue value: Int) {
        selectedCategorySegmentIndex = value
        updateCategories(selectedCategorySegmentIndex)
        println("category segment value changed event!")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        case 1:
            println("distanceFilterSectionIsExpanded: \(distanceFilterSectionIsExpanded)")
            return distanceFilterSectionIsExpanded ? distanceFilterValues.count : collapsedDistanceFilterValues.count
        case 2:
            return 3
        default:
            // 3
            return categories.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.section) {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = "Offering a Deal"
            cell.delegate = self
            cell.filterSwitch.on = dealSwitchState
            return cell

        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell", forIndexPath: indexPath) as! SelectionCell
                if distanceFilterSectionIsExpanded {
                    cell.nameLabel.text = distanceFilterValues[indexPath.row]["name"] as? String
                } else {
                    cell.nameLabel.text = distanceFilterValues[selectedDistanceValueIndex]["name"] as? String
                }
                
                if indexPath.row == selectedDistanceValueIndex {
                    cell.accessoryType = .Checkmark
                    cell.filterIsSelected = true
                } else {
                    cell.accessoryType = .None
                    cell.filterIsSelected = false
                }
                // show expand button on "Auto" row
                if indexPath.row == 0 {
                    cell.expandButton.hidden = false
                }
            return cell
            
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("SelectionCell", forIndexPath: indexPath) as! SelectionCell
                cell.nameLabel.text = sortByValues[indexPath.row] as String
            
                if indexPath.row == selectedSortByIndex {
                    cell.accessoryType = .Checkmark
                    cell.filterIsSelected = true
                } else {
                    cell.accessoryType = .None
                    cell.filterIsSelected = false
                }
            return cell
            
        case 3:
            // 3
            var cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                if categories.count > indexPath.row {
                    cell.switchLabel.text = categories[indexPath.row]["name"]
                    cell.delegate = self
                    cell.filterSwitch.on = switchStates[indexPath.row] ?? false
                } else {
                    NSLog("UNEXPECTED: categories.count: \(categories.count) does not contain index: \(indexPath.row)")
                }
            return cell
        default:
            NSLog("ERROR: Unexpected indexPath.section: \(indexPath.section) in cellForRowAtIndexPath")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var indexSet = NSMutableIndexSet()
        switch (indexPath.section) {
        case 1:
            if indexPath.row == 0 {
                if distanceFilterSectionIsExpanded {
                    distanceFilterSectionIsExpanded = false
                } else {
                    distanceFilterSectionIsExpanded = true
                }
            } else {

                selectedDistanceValueIndex = indexPath.row
            }

            tableView.reloadData()
        case 2:
            // sort by
            selectedSortByIndex = indexPath.row
            indexSet.addIndex(indexPath.section)
            tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.None)
        default:
            NSLog("UNEXPECTED: didSelectRowAtIndexPath for section: \(indexPath.section)")
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return CGFloat(0)
        } else {
            return CGFloat(50)
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        switch (section) {
        case 0, 1, 2:
            let titleCell = tableView.dequeueReusableCellWithIdentifier("FilterTitleCell") as! FilterTitleCell
            titleCell.filterTitleLabel.text = getSectionTitle(section)
            titleCell.backgroundColor = UIColor.whiteColor()
            if section == 2 {
                titleCell.categorySegment.hidden = false
                titleCell.delegate = self
            }
            return titleCell
        default:
            // no header for Deals (section 0)
            return nil
        }
    }
    
    // private helper functions
    private func getSectionTitle(section: Int) -> String {
        switch section {
        case 0:
            return "Distance"
        case 1:
            return "Sort By"
        case 2:
            return "Category"
        default:
            NSLog("UNEXPECTED section to display Filter Title Cell: \(section)")
            return ""
        }
    }
    
    private func updateCategories(index: Int) -> Void {
        switch(selectedCategorySegmentIndex) {
        case 0:
            categories = food
        case 1:
            categories = loadYelpCategoriesByType("bars")
        case 2:
            categories = loadYelpCategoriesByType("shopping")
        case 3:
            categories = loadYelpCategoriesByType("active")
        case 4:
            categories = loadYelpCategoriesByType("localservices")
        default:
            NSLog("UNEXPECTED selectedCategorySegmentIndex: \(selectedCategorySegmentIndex)")
        }
        
        var indexSet = NSMutableIndexSet()
        indexSet.addIndex(3)
        tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.None)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func getDistanceInMetersByIndex(index: Int) -> Double? {
        let conversionFactor = 1609.34
        switch (index) {
        case 0, 1:
            return nil
        case 2, 3, 4, 5:
            return conversionFactor * (distanceFilterValues[index]["code"] as! Double)
        default:
            NSLog("UNEXPECTED: distanceFilterValues index: \(index)")
            return nil
        }
    }
    
    private func getSortByEnumValue(index: Int) -> YelpSortMode? {
        switch index {
        case 1:
            return YelpSortMode.BestMatched
        case 2:
            return YelpSortMode.Distance
        case 3:
            return YelpSortMode.HighestRated
        default:
            NSLog("UNEXPECTED: invalid index for YelpSortMode: \(index)")
            return nil
        }
    }
    
    func yelpFoodCategories() -> [[String: String]] {
        var categories = [["name" : "Afghan", "code": "afghani"]]
        categories.append(["name" : "African", "code": "african"])
        categories.append(["name" : "American, New", "code": "newamerican"])
        categories.append(["name" : "American, Traditional", "code": "tradamerican"])
        categories.append(["name" : "Arabian", "code": "arabian"])
        categories.append(["name" : "Argentine", "code": "argentine"])
        categories.append(["name" : "Armenian", "code": "armenian"])
        categories.append(["name" : "Asian Fusion", "code": "asianfusion"])
        categories.append(["name" : "Asturian", "code": "asturian"])
        categories.append(["name" : "Australian", "code": "australian"])
        categories.append(["name" : "Austrian", "code": "austrian"])
        categories.append(["name" : "Baguettes", "code": "baguettes"])
        categories.append(["name" : "Bangladeshi", "code": "bangladeshi"])
        categories.append(["name" : "Barbeque", "code": "bbq"])
        categories.append(["name" : "Basque", "code": "basque"])
        categories.append(["name" : "Bavarian", "code": "bavarian"])
        categories.append(["name" : "Beer Garden", "code": "beergarden"])
        categories.append(["name" : "Beer Hall", "code": "beerhall"])
        categories.append(["name" : "Beisl", "code": "beisl"])
        categories.append(["name" : "Belgian", "code": "belgian"])
        categories.append(["name" : "Bistros", "code": "bistros"])
        categories.append(["name" : "Black Sea", "code": "blacksea"])
        categories.append(["name" : "Brasseries", "code": "brasseries"])
        categories.append(["name" : "Brazilian", "code": "brazilian"])
        categories.append(["name" : "Breakfast & Brunch", "code": "breakfast_brunch"])
        categories.append(["name" : "British", "code": "british"])
        categories.append(["name" : "Buffets", "code": "buffets"])
        categories.append(["name" : "Bulgarian", "code": "bulgarian"])
        categories.append(["name" : "Burgers", "code": "burgers"])
        categories.append(["name" : "Burmese", "code": "burmese"])
        categories.append(["name" : "Cafes", "code": "cafes"])
        categories.append(["name" : "Cafeteria", "code": "cafeteria"])
        categories.append(["name" : "Cajun/Creole", "code": "cajun"])
        categories.append(["name" : "Cambodian", "code": "cambodian"])
        categories.append(["name" : "Canadian", "code": "New)"])
        categories.append(["name" : "Canteen", "code": "canteen"])
        categories.append(["name" : "Caribbean", "code": "caribbean"])
        categories.append(["name" : "Catalan", "code": "catalan"])
        categories.append(["name" : "Chech", "code": "chech"])
        categories.append(["name" : "Cheesesteaks", "code": "cheesesteaks"])
        categories.append(["name" : "Chicken Shop", "code": "chickenshop"])
        categories.append(["name" : "Chicken Wings", "code": "chicken_wings"])
        categories.append(["name" : "Chilean", "code": "chilean"])
        categories.append(["name" : "Chinese", "code": "chinese"])
        categories.append(["name" : "Comfort Food", "code": "comfortfood"])
        categories.append(["name" : "Corsican", "code": "corsican"])
        categories.append(["name" : "Creperies", "code": "creperies"])
        categories.append(["name" : "Cuban", "code": "cuban"])
        categories.append(["name" : "Curry Sausage", "code": "currysausage"])
        categories.append(["name" : "Cypriot", "code": "cypriot"])
        categories.append(["name" : "Czech", "code": "czech"])
        categories.append(["name" : "Czech/Slovakian", "code": "czechslovakian"])
        categories.append(["name" : "Danish", "code": "danish"])
        categories.append(["name" : "Delis", "code": "delis"])
        categories.append(["name" : "Diners", "code": "diners"])
        categories.append(["name" : "Dumplings", "code": "dumplings"])
        categories.append(["name" : "Eastern European", "code": "eastern_european"])
        categories.append(["name" : "Ethiopian", "code": "ethiopian"])
        categories.append(["name" : "Fast Food", "code": "hotdogs"])
        categories.append(["name" : "Filipino", "code": "filipino"])
        categories.append(["name" : "Fish & Chips", "code": "fishnchips"])
        categories.append(["name" : "Fondue", "code": "fondue"])
        categories.append(["name" : "Food Court", "code": "food_court"])
        categories.append(["name" : "Food Stands", "code": "foodstands"])
        categories.append(["name" : "French", "code": "french"])
        categories.append(["name" : "French Southwest", "code": "sud_ouest"])
        categories.append(["name" : "Galician", "code": "galician"])
        categories.append(["name" : "Gastropubs", "code": "gastropubs"])
        categories.append(["name" : "Georgian", "code": "georgian"])
        categories.append(["name" : "German", "code": "german"])
        categories.append(["name" : "Giblets", "code": "giblets"])
        categories.append(["name" : "Gluten-Free", "code": "gluten_free"])
        categories.append(["name" : "Greek", "code": "greek"])
        categories.append(["name" : "Halal", "code": "halal"])
        categories.append(["name" : "Hawaiian", "code": "hawaiian"])
        categories.append(["name" : "Heuriger", "code": "heuriger"])
        categories.append(["name" : "Himalayan/Nepalese", "code": "himalayan"])
        categories.append(["name" : "Hong Kong Style Cafe", "code": "hkcafe"])
        categories.append(["name" : "Hot Dogs", "code": "hotdog"])
        categories.append(["name" : "Hot Pot", "code": "hotpot"])
        categories.append(["name" : "Hungarian", "code": "hungarian"])
        categories.append(["name" : "Iberian", "code": "iberian"])
        categories.append(["name" : "Indian", "code": "indpak"])
        categories.append(["name" : "Indonesian", "code": "indonesian"])
        categories.append(["name" : "International", "code": "international"])
        categories.append(["name" : "Irish", "code": "irish"])
        categories.append(["name" : "Island Pub", "code": "island_pub"])
        categories.append(["name" : "Israeli", "code": "israeli"])
        categories.append(["name" : "Italian", "code": "italian"])
        categories.append(["name" : "Japanese", "code": "japanese"])
        categories.append(["name" : "Jewish", "code": "jewish"])
        categories.append(["name" : "Kebab", "code": "kebab"])
        categories.append(["name" : "Korean", "code": "korean"])
        categories.append(["name" : "Kosher", "code": "kosher"])
        categories.append(["name" : "Kurdish", "code": "kurdish"])
        categories.append(["name" : "Laos", "code": "laos"])
        categories.append(["name" : "Laotian", "code": "laotian"])
        categories.append(["name" : "Latin American", "code": "latin"])
        categories.append(["name" : "Live/Raw Food", "code": "raw_food"])
        categories.append(["name" : "Lyonnais", "code": "lyonnais"])
        categories.append(["name" : "Malaysian", "code": "malaysian"])
        categories.append(["name" : "Meatballs", "code": "meatballs"])
        categories.append(["name" : "Mediterranean", "code": "mediterranean"])
        categories.append(["name" : "Mexican", "code": "mexican"])
        categories.append(["name" : "Middle Eastern", "code": "mideastern"])
        categories.append(["name" : "Milk Bars", "code": "milkbars"])
        categories.append(["name" : "Modern Australian", "code": "modern_australian"])
        categories.append(["name" : "Modern European", "code": "modern_european"])
        categories.append(["name" : "Mongolian", "code": "mongolian"])
        categories.append(["name" : "Moroccan", "code": "moroccan"])
        categories.append(["name" : "New Zealand", "code": "newzealand"])
        categories.append(["name" : "Night Food", "code": "nightfood"])
        categories.append(["name" : "Norcinerie", "code": "norcinerie"])
        categories.append(["name" : "Open Sandwiches", "code": "opensandwiches"])
        categories.append(["name" : "Oriental", "code": "oriental"])
        categories.append(["name" : "Pakistani", "code": "pakistani"])
        categories.append(["name" : "Parent Cafes", "code": "eltern_cafes"])
        categories.append(["name" : "Parma", "code": "parma"])
        categories.append(["name" : "Persian/Iranian", "code": "persian"])
        categories.append(["name" : "Peruvian", "code": "peruvian"])
        categories.append(["name" : "Pita", "code": "pita"])
        categories.append(["name" : "Pizza", "code": "pizza"])
        categories.append(["name" : "Polish", "code": "polish"])
        categories.append(["name" : "Portuguese", "code": "portuguese"])
        categories.append(["name" : "Potatoes", "code": "potatoes"])
        categories.append(["name" : "Poutineries", "code": "poutineries"])
        categories.append(["name" : "Pub Food", "code": "pubfood"])
        categories.append(["name" : "Rice", "code": "riceshop"])
        categories.append(["name" : "Romanian", "code": "romanian"])
        categories.append(["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"])
        categories.append(["name" : "Rumanian", "code": "rumanian"])
        categories.append(["name" : "Russian", "code": "russian"])
        categories.append(["name" : "Salad", "code": "salad"])
        categories.append(["name" : "Sandwiches", "code": "sandwiches"])
        categories.append(["name" : "Scandinavian", "code": "scandinavian"])
        categories.append(["name" : "Scottish", "code": "scottish"])
        categories.append(["name" : "Seafood", "code": "seafood"])
        categories.append(["name" : "Serbo Croatian", "code": "serbocroatian"])
        categories.append(["name" : "Signature Cuisine", "code": "signature_cuisine"])
        categories.append(["name" : "Singaporean", "code": "singaporean"])
        categories.append(["name" : "Slovakian", "code": "slovakian"])
        categories.append(["name" : "Soul Food", "code": "soulfood"])
        categories.append(["name" : "Soup", "code": "soup"])
        categories.append(["name" : "Southern", "code": "southern"])
        categories.append(["name" : "Spanish", "code": "spanish"])
        categories.append(["name" : "Steakhouses", "code": "steak"])
        categories.append(["name" : "Sushi Bars", "code": "sushi"])
        categories.append(["name" : "Swabian", "code": "swabian"])
        categories.append(["name" : "Swedish", "code": "swedish"])
        categories.append(["name" : "Swiss Food", "code": "swissfood"])
        categories.append(["name" : "Tabernas", "code": "tabernas"])
        categories.append(["name" : "Taiwanese", "code": "taiwanese"])
        categories.append(["name" : "Tapas Bars", "code": "tapas"])
        categories.append(["name" : "Tapas/Small Plates", "code": "tapasmallplates"])
        categories.append(["name" : "Tex-Mex", "code": "tex-mex"])
        categories.append(["name" : "Thai", "code": "thai"])
        categories.append(["name" : "Traditional Norwegian", "code": "norwegian"])
        categories.append(["name" : "Traditional Swedish", "code": "traditional_swedish"])
        categories.append(["name" : "Trattorie", "code": "trattorie"])
        categories.append(["name" : "Turkish", "code": "turkish"])
        categories.append(["name" : "Ukrainian", "code": "ukrainian"])
        categories.append(["name" : "Uzbek", "code": "uzbek"])
        categories.append(["name" : "Vegan", "code": "vegan"])
        categories.append(["name" : "Vegetarian", "code": "vegetarian"])
        categories.append(["name" : "Venison", "code": "venison"])
        categories.append(["name" : "Vietnamese", "code": "vietnamese"])
        categories.append(["name" : "Wok", "code": "wok"])
        categories.append(["name" : "Wraps", "code": "wraps"])
        categories.append(["name" : "Yugoslav", "code": "yugoslav"])
        
        return categories
    }
    
    private func loadYelpCategoriesByType(type: String) -> [[String: String]] {
        // type: {"bars", "shopping", "active"}
        var results = [[String: String]]()
        let path = NSBundle.mainBundle().pathForResource("categories", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
        
        for entry in jsonResult {
            let parentsList = entry["parents"] as! NSArray
            if parentsList.count > 0 {
                if let validParent = parentsList[0] as? String {
                    if validParent == type {
                        let name = entry["title"] as! String
                        let code = entry["alias"] as! String
                        results.append(["name": name, "code": code])
                    }
                }
            }
        }
        return results
    }
    
}
