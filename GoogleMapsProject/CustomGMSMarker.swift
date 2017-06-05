//
//  SearchResult.swift
//  GoogleMapsProject
//
//  Created by Miguel Tepale on 6/1/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

//import UIKit
import GoogleMaps

class CustomGMSMarker: GMSMarker {
    
    var website: String?
    var imageURLString: String?
    
    init(name: String, imageURL: String, latitude: Double, longitude: Double, websiteURL: String) {
        
        super.init()
        self.title = name
        self.imageURLString = imageURL
        self.position = CLLocationCoordinate2DMake(latitude, longitude)
        self.website = websiteURL
    }
    
}
