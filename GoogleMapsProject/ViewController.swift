//
//  ViewController.swift
//  GoogleMapsProject
//
//  Created by Miguel Tepale on 5/31/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    var userResults: [CustomGMSMarker] = []

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var terrainSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        loadStockSearchMarkers()
        
        let camera = GMSCameraPosition.camera(withLatitude: 40.708656, longitude: -74.014856, zoom: 16.0)
        mapView.animate(to: camera)
        let marker = GMSMarker()
        marker.position = camera.target
        marker.title = "TurnToTech"
        marker.snippet = "I hate you GMS"
        marker.map = mapView
    
        self.mapView.bringSubview(toFront: logoImage)
        self.mapView.bringSubview(toFront: toolbarView)
        self.mapView.bringSubview(toFront: terrainSegmentedControl)
        
        mapView.mapType = .normal
        
    }
    
    func loadStockSearchMarkers() {
        
        guard let plistUrl = Bundle.main.url(forResource: "BarList", withExtension: "plist"), let pListData = NSData(contentsOf: plistUrl) else { return }
        var format = PropertyListSerialization.PropertyListFormat.xml
        var barEntries: NSArray!
        
        do {
            barEntries = try PropertyListSerialization.propertyList(from: pListData as Data, options: .mutableContainersAndLeaves, format: &format) as? NSArray
        } catch {
            print("Error reading plits")
        }
        
        if let barEntries = barEntries as? [[String:Any]] {
            for bar in barEntries {
                if let name = bar["Name"] as? String,
                    let latitude = bar["Latitude"] as? Double,
                    let longitude = bar["Longitude"] as? Double,
                    let image = bar["Image"] as? String,
                    let website = bar["Website"] as? String {
                    
                    let barEntry = CustomGMSMarker(name: name, imageURL: image, latitude: latitude, longitude: longitude, websiteURL: website)
                    barEntry.map = mapView
                    userResults.append(barEntry)
                }
            }
        }
    }
    
    @IBAction func mapSegmentedAction(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .normal
        case 1:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .satellite
        }
    }
    
}

extension ViewController:  GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        guard let customInfoWindow = Bundle.main.loadNibNamed("CustomAnnotation", owner: nil, options: nil)?[0] as? CustomAnnotation else { return nil }
        
        let myMarker = marker as! CustomGMSMarker
        customInfoWindow.titleLabel.text = myMarker.title
        customInfoWindow.detailLabel.text = "Hello World!"
        
        if let imageURLExists = myMarker.imageURLString {
            customInfoWindow.searchImageIcon.image = UIImage(named:imageURLExists)
        }
        else {
            customInfoWindow.searchImageIcon.image = UIImage(named:"apple-icon-180x180.png")
        }
        
        return customInfoWindow
    }
}



