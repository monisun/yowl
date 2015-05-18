## Yowl

Yowl is like Yelp. Search for local venues using filters, text search, or map locator.

<img src="https://github.com/monisun/yowl/blob/master/launch.png" width="150px"/>

Time spent: `20`

### Features

#### Required

- [x] Search results page
   - [x] Table rows should be dynamic height according to the content height
   - [x] Custom cells should have the proper Auto Layout constraints
   - [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [x] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [x] The filters you should actually have are: category, sort (best match, distance, highest rated), radius (meters), deals (on/off).
   - [x] The filters table should be organized into sections as in the mock.
   - [x] Use the default UISwitch for on/off states.
   - [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [x] Display some of the available Yelp categories (choose any 3-4 that you want).
      - [x] User can choose between Food, Bars/Nightlife, Shopping, Activities, or Local Services categories. 

#### Optional

- [x] Search results page
   - [x] Infinite scroll for restaurant results
   - [x] Implement map view of restaurant results. Map markers are loaded for all Business results.
   - [x] Map automatically renders to include all markers within view bounds.
   - [x] Integrated Google Maps iOS SDK to render maps in normal, satellite, or hybrid view modes.
   - [x] Implemented Location Services to ask user for permission to access location while app is in foreground.
   - [x] Map automatically recenters to user's current location via center pin.
- [x] Filter page
   - [x] Radius filter should expand as in the real Yelp app
   - [x] Categories should show a subset of the full list with a "See All" row to expand. Category list is here: http://www.yelp.com/developers/documentation/category_list (Links to an external site.)
- [x] Implement a custom switch
- [ ] Implement the restaurant detail page.

### Walkthrough

<img src="https://github.com/monisun/yowl/blob/master/yelp_demo.gif" width="350px"/>
<img src="https://github.com/monisun/yowl/blob/master/yelp_demo3.gif" width="350px"/>

Credits
---------
* [Yelp API](http://developer.rottentomatoes.com/docs/read/JSON)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
