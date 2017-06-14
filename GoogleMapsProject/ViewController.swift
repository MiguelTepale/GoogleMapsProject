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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var terrainSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    
    var initialFirstSearchInitiated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        searchBar.delegate = self
        
        loadStockSearchMarkers()
        
        let camera = GMSCameraPosition.camera(withLatitude: 40.708656, longitude: -74.014856, zoom: 16.0)
        mapView.animate(to: camera)
    
        self.mapView.bringSubview(toFront: logoImage)
        self.mapView.bringSubview(toFront: toolbarView)
        self.mapView.bringSubview(toFront: terrainSegmentedControl)
        self.mapView.bringSubview(toFront: searchBar)
        
        mapView.mapType = .normal
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        searchBar.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
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
                    let image = bar["Image"] as? String {
                    var website = "https://www.google.com"
                    var address = "Hello, World!"
                    var id = "id does not exist"
                    
                    if let websiteExists = bar["Website"] {
                        website = websiteExists as! String
                    }
                    
                    if let addressExists = bar["Address"] {
                        address = addressExists as! String
                    }
                    
                    if let idExists = bar["Id"] {
                        id = idExists as! String
                    }
                    
                    let barEntry = CustomGMSMarker(name: name, imageURL: image, latitude: latitude, longitude: longitude, websiteURL: website, address: address, entryID: id, photoID: "")
                    barEntry.map = mapView
                    userResults.append(barEntry)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showWebViewController" {
            let nav = segue.destination as! UINavigationController
            let webVC = nav.viewControllers[0] as! WebViewController
            
            let marker = sender as? CustomGMSMarker
            
            if let websiteExists = marker?.website {
                webVC.userUrl = websiteExists
                print(webVC.userUrl)
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

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        initialFirstSearchInitiated = true
        searchBar.resignFirstResponder()
        
        for search in self.userResults {
            search.map = nil
        }
        self.userResults.removeAll()
        
        guard let safeQuery = searchBar.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let apiString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.708656,-74.014856&radius=500&types=restaurant&name=\(safeQuery)&key=AIzaSyDhXH99Wt-yp3AaKvZfnlVdL_jekrKAAx8"
        let apiURL = URL(string: apiString)
        URLSession.shared.dataTask(with: apiURL!) { data, response, error in
            
            guard let jsonData = data, error == nil else {
                return
            }
            guard let decodedJSON = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any] else {
                return
            }
            
            let searchResults = decodedJSON["results"]! as! [[String:Any]]
            
            for result in searchResults {
                
                guard let name = result["name"] as? String else {
                    print("Locale name doesn't exist")
                    continue
                }
                guard let placeID = result["place_id"] as? String else {
                    print("Locale place_id doesn't exist")
                    continue
                }
                guard let address = result["vicinity"] as? String else {
                    print("Locale address doesn't exist")
                    continue
                }
                
                var latitude = Double()
                var longitude = Double()
                var photoIdReference: String = ""
                
                if let geometryDictionary = result["geometry"] as? [String:Any] {
                    if let locationDictionary = geometryDictionary["location"] as? [String:Double] {
                        latitude = locationDictionary["lat"]!
                        longitude = locationDictionary["lng"]!
                    }
                    else {
                        print("Longitude or Latitude doesn't exist")
                    }
                }
                if let photosArray = result["photos"] as? [[String:Any]] {
                    for photo in photosArray {
                        if let photoObjectExists = photo["photo_reference"] as? String {
                            photoIdReference = photoObjectExists
                        }
                        else {
                            print("'photoIdReference' does not exist")
                        }
                    }
                }
                else {
                    print("photo's array doesn't exist")
                }
                let currentMarker = CustomGMSMarker(name: name, imageURL: "", latitude: latitude, longitude: longitude, websiteURL: "", address: address, entryID: placeID, photoID: photoIdReference)
                self.userResults.append(currentMarker)
                currentMarker.map = self.mapView
            }
        }
        .resume()
    }
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        guard let customInfoWindow = Bundle.main.loadNibNamed("CustomAnnotation", owner: nil, options: nil)?[0] as? CustomAnnotation else { return nil }
        marker.tracksInfoWindowChanges = true
        let myMarker = marker as! CustomGMSMarker
        customInfoWindow.titleLabel.text = myMarker.title
        customInfoWindow.detailLabel.text = myMarker.addressString
        
        let photoID = myMarker.photoIdString!
        let apiString = "https://maps.googleapis.com/maps/api/place/photo?maxheight=250&maxwidth=250&photoreference=\(photoID)&key=AIzaSyDhXH99Wt-yp3AaKvZfnlVdL_jekrKAAx8"
        
        let apiURL = URL(string: apiString)
        
        if initialFirstSearchInitiated {
            
            URLSession.shared.dataTask(with: apiURL!) { data, response, error in
                
                guard let jsonData = data, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    customInfoWindow.searchImageIcon.image = UIImage(data: jsonData)
                }
            }
                .resume()
        }
        else {
            
            if let imageURLExists = myMarker.imageURLString {
                customInfoWindow.searchImageIcon.image = UIImage(named:imageURLExists)
            } else {
                customInfoWindow.searchImageIcon.image = UIImage(named:"apple-icon-180x180.png")
            }
        }
        return customInfoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let currentMarker = marker as? CustomGMSMarker
        
        if initialFirstSearchInitiated {
            
            let placeID = currentMarker!.entryIdString!
            let apiString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=AIzaSyDhXH99Wt-yp3AaKvZfnlVdL_jekrKAAx8"
            let apiURL = URL(string: apiString)
            
            URLSession.shared.dataTask(with: apiURL!) { data, response, error in
            
                guard let jsonData = data, error == nil else {
                    return
                }
                
                guard let decodedJSON = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any] else {
                    return
                }
                
                var website = "https://www.google.com"
                let searchResults = decodedJSON["result"]! as! [String:Any]
                if let websiteExists = searchResults["website"] {
                    website = websiteExists as! String
                }
                
                print(website)
                currentMarker?.website = website
                
                DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "showWebViewController", sender: currentMarker)
                })
            }
            .resume()
        } else {
        //Option #1
        performSegue(withIdentifier: "showWebViewController", sender: currentMarker)
        }
    }
}


//Option #2
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let webViewNavController = storyboard.instantiateViewController(withIdentifier:"WebNav") as! UINavigationController
//        let webViewController = webViewNavController.viewControllers[0] as! WebViewController
//        webViewController.userUrl = currentMarker?.website
//
//        self.present(webViewNavController, animated: true, completion: nil)
