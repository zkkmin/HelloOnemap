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
    
    let data = ["Cityhall", "CityCenter", "CityShit"]
    
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
        
        
        resultTableViewController.tableView.reloadData()
    }
    
    func mapViewDidLoad(mapView:AGSMapView!){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "responseToEventChanged:", name: AGSMapViewDidEndZoomingNotification, object: nil)
        

    }
    
    func responseToEventChanged(notification: NSNotification){
        let theString = "xmin = \(mapView.visibleAreaEnvelope.xmin),\nymin = \(mapView.visibleAreaEnvelope.ymin),\nxmax = \(mapView.visibleAreaEnvelope.xmax),\nymax = \(mapView.visibleAreaEnvelope.ymax)"
        println(theString);
    }

}

