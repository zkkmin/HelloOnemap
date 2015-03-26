//
//  ViewController.swift
//  HelloOnemap
//
//  Created by Zin Ko Ko Min on 20/3/15.
//  Copyright (c) 2015 ZIN KO KO MIN. All rights reserved.
//

import UIKit
import ArcGIS


class ViewController: UIViewController, AGSMapViewLayerDelegate {

    @IBOutlet weak var mapView: AGSMapView!
    
    
    let xmin = 29495.9472786567
    let ymin = 39801.9418330241
    let xmax = 30037.5707551916
    let ymax = 40765.3094566208

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add base map
        let url = NSURL(string: "http://e1.onemap.sg/arcgis/rest/services/BASEMAP/MapServer")
        let tiledLayer = AGSTiledMapServiceLayer(URL: url)
        self.mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")
        self.mapView.layerDelegate = self
        
        let envelope = AGSEnvelope(xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax, spatialReference: self.mapView.spatialReference);
        //self.mapView.zoomToEnvelope(envelope, animated: false)
        
    }
    
    func mapViewDidLoad(mapView:AGSMapView!){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "responseToEventChanged:", name: AGSMapViewDidEndZoomingNotification, object: nil)
        

    }
    
    func responseToEventChanged(notification: NSNotification){
        let theString = "xmin = \(mapView.visibleAreaEnvelope.xmin),\nymin = \(mapView.visibleAreaEnvelope.ymin),\nxmax = \(mapView.visibleAreaEnvelope.xmax),\nymax = \(mapView.visibleAreaEnvelope.ymax)"
        println(theString);
    }

}

