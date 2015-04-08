//
//  ViewController.swift
//  HelloOnemap
//
//  Created by Zin Ko Ko Min on 20/3/15.
//  Copyright (c) 2015 ZIN KO KO MIN. All rights reserved.
//

import UIKit
import ArcGIS


class ViewController: UIViewController, AGSMapViewLayerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    
    
    let xmin = 29495.9472786567
    let ymin = 39801.9418330241
    let xmax = 30037.5707551916
    let ymax = 40765.3094566208
    
    var data = ["Cityhall", "CityCenter", "CityShit"]
    
    var resultTableViewController = UITableViewController()
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")
        self.mapView.layerDelegate = self
        
        //let envelope = AGSEnvelope(xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax, spatialReference: self.mapView.spatialReference);
        //self.mapView.zoomToEnvelope(envelope, animated: false)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchController.searchBar.text = data[indexPath.row]
        
        let searchText = searchController.searchBar.text
        searchController.active = false
        searchController.searchBar.text = searchText
        
        
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("click");
        
        let searchText = searchController.searchBar.text
        searchController.active = false
        searchController.searchBar.text = searchText

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowData = data[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = rowData
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        getAddresses("")
        
    }
    
    // Call OneMap's Address Search API to search a location in Singapore
    func getAddresses(keyWord: String ){
        let urlString = "http://www.onemap.sg/API/services.svc/basicSearch?token=qo/s2TnSUmfLz+32CvLC4RMVkzEFYjxqyti1KhByvEacEdMWBpCuSSQ+IFRT84QjGPBCuz/cBom8PfSm3GjEsGc8PkdEEOEr&wc=SEARCHVAL%20LIKE%20%27CITY$%27&otptFlds=CATEGORY&returnGeom=0&nohaxr=10"
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(NSURL(string: urlString)!, completionHandler: { (taskData, taskResponse, taskError) -> Void in
            var jsonReadError : NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(taskData, options: NSJSONReadingOptions.MutableContainers, error: &jsonReadError) as NSDictionary
            
            let resultsArray = jsonResult["SearchResults"] as NSArray
            
            for (index, result) in enumerate(resultsArray){
                if index > 0 {
                    if let placeName = result["SEARCHVAL"] as String? {
                        self.data.append(placeName)
                    }
                }
            }

            self.resultTableViewController.tableView.reloadData()
        }).resume()
    }
    
    func mapViewDidLoad(mapView:AGSMapView!){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "responseToEventChanged:", name: AGSMapViewDidEndZoomingNotification, object: nil)
        

    }
    
    func responseToEventChanged(notification: NSNotification){
        let theString = "xmin = \(mapView.visibleAreaEnvelope.xmin),\nymin = \(mapView.visibleAreaEnvelope.ymin),\nxmax = \(mapView.visibleAreaEnvelope.xmax),\nymax = \(mapView.visibleAreaEnvelope.ymax)"
        println(theString);
    }

}

