//
//  SearchResult.swift
//  GoogleMapsProject
//
//  Created by Miguel Tepale on 6/1/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

//import UIKit
import GoogleMaps

class SearchResult: GMSMarker {
    
    var website: String?
    
    init(name: String, imageName: String, latitude: Double, longitude: Double, websiteURL: String) {
        
        super.init()
        self.title = name
        self.icon = UIImage(named: imageName)
        self.position = CLLocationCoordinate2DMake(latitude, longitude)
        self.website = websiteURL
    }
    
}
