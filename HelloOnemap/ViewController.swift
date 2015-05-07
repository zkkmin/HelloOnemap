//
//  ViewController.swift
//  HelloOnemap
//  Added Address Search
//  Created by Zin Ko Ko Min on 20/3/15.
//  Copyright (c) 2015 ZIN KO KO MIN. All rights reserved.
//

import UIKit
import ArcGIS

struct Place {
    var placeName = ""
    var Category = ""
    var X = 0.0
    var Y = 0.0
}


class ViewController: UIViewController, AGSMapViewLayerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    var graphicLayer = AGSGraphicsLayer()
    
    let xmin = 29495.9472786567
    let ymin = 39801.9418330241
    let xmax = 30037.5707551916
    let ymax = 40765.3094566208
    
    var searchResults = [Place]()
    let session = NSURLSession.sharedSession()
    
    var resultTableViewController = UITableViewController()
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UISearchController Setup
        searchController = UISearchController(searchResultsController: resultTableViewController)
        
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.titleView = searchController.searchBar
        
        definesPresentationContext = true
        
        resultTableViewController.tableView.dataSource = self
        
        resultTableViewController.tableView.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.delegate = self
        
        searchController.searchBar.delegate = self
    
        
        
        // add base map
        let url = NSURL(string: "http://e1.onemap.sg/arcgis/rest/services/BASEMAP/MapServer")
        let tiledLayer = AGSTiledMapServiceLayer(URL: url)
        mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")
        mapView.layerDelegate = self
        mapView.addMapLayer(graphicLayer, withName: "graphicLayer")
        let envelope = AGSEnvelope(xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax, spatialReference: mapView.spatialReference);
        mapView.zoomToEnvelope(envelope, animated: false)
        
    }
    
    // This function accept a Place structure and create a Point Graphics on the map representing the Place
    func showSelectedSearchPlace(selectedPlace :Place){
        searchController.active = false
        searchController.searchBar.text = selectedPlace.placeName
        
        let myMarkerSymbol = AGSSimpleMarkerSymbol()
        myMarkerSymbol.color = UIColor.redColor()
        
        let point = AGSPoint(x: selectedPlace.X, y: selectedPlace.Y, spatialReference: mapView.spatialReference)
        mapView.centerAtPoint(point, animated: false)
        
        var pointGraphic = AGSGraphic(geometry: point, symbol: myMarkerSymbol, attributes: nil)
        graphicLayer.removeAllGraphics()
        graphicLayer.addGraphic(pointGraphic)
        
    }
    
    // When user click on one of the cells, the address is passed to showSelectedSearchPlace function to display it on map
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchController.searchBar.text = searchResults[indexPath.row].placeName
        showSelectedSearchPlace(searchResults[indexPath.row])
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //showSelectedSearchPlace()
    }
    
    // Show addresses in table cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowData = searchResults[indexPath.row].placeName
        let cell = UITableViewCell()
        cell.textLabel?.text = rowData
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    // This function is called when the user enter address in search bar
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        getAddresses(searchController.searchBar.text)
        
    }
    
    // Call OneMap's Address Search API to search a location in Singapore
    func getAddresses(keyWord: String ){
        
        
        if keyWord != "" {
            let keyWordEscaped = keyWord.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            
            let urlString = "http://www.onemap.sg/API/services.svc/basicSearch?token=qo/s2TnSUmfLz+32CvLC4RMVkzEFYjxqyti1KhByvEacEdMWBpCuSSQ+IFRT84QjGPBCuz/cBom8PfSm3GjEsGc8PkdEEOEr&wc=SEARCHVAL%20LIKE%20%27\(keyWordEscaped!)$%27&otptFlds=CATEGORY&returnGeom=0&nohaxr=10"
            
            session.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (taskData, taskResponse, taskError) -> Void in
                println("\(urlString)")
                var jsonReadError : NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(taskData, options: NSJSONReadingOptions.MutableContainers, error: &jsonReadError) as NSDictionary
                
                let resultsArray = jsonResult["SearchResults"] as NSArray
                self.searchResults = []
                for (index, result) in enumerate(resultsArray){
                    if index > 0 {
                        var place = Place()
                        
                        if let placeName = result["SEARCHVAL"] as String? {
                            place.placeName = placeName
                        }
                        
                        if let category = result["CATEGORY"] as String? {
                            place.Category = category
                        }
                        
                        if let x = result["X"] as NSString? {
                            place.X = x.doubleValue
                        }
                        
                        if let y = result["Y"] as NSString? {
                            place.Y = y.doubleValue
                        }
                        
                        self.searchResults.append(place)
                    }
                }
                
                self.resultTableViewController.tableView.reloadData()
            }).resume()
        }
        
    }
    
    func mapViewDidLoad(mapView:AGSMapView!){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "responseToEventChanged:", name: AGSMapViewDidEndZoomingNotification, object: nil)

    }
    
    func responseToEventChanged(notification: NSNotification){
        let theString = "xmin = \(mapView.visibleAreaEnvelope.xmin),\nymin = \(mapView.visibleAreaEnvelope.ymin),\nxmax = \(mapView.visibleAreaEnvelope.xmax),\nymax = \(mapView.visibleAreaEnvelope.ymax)"
        // println(theString);
        println("sale \(mapView.mapScale)")
    }

}

