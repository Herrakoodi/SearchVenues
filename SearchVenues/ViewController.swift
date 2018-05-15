//
//  ViewController.swift
//  SearchVenues
//
//  Created by Janne Mäkinen on 15/05/2018.
//  Copyright © 2018 Janne Mäkinen. All rights reserved.
//

import UIKit
import CoreLocation

let client_id = "" // visit developer.foursqure.com for API key
let client_secret = "" // visit developer.foursqure.com for API key

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D!
    var searchResults = [JSON]()
    var numberOfSearches = 0
    let cellReuseIdentifier = "cell"
    var venueName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        getCurrentLocation()
        
        textField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("locations = \(locations)")
        currentLocation = locations.last?.coordinate
    }
    
    func getCurrentLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print(textField.text)
        snapToPlace()
        searchForVenue(searchText:textField.text!)
        numberOfSearches = numberOfSearches + 1
    }
    
    func snapToPlace() {
        let url = "https://api.foursquare.com/v2/venues/search?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&intent=checkin&limit=1&radius=4000&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            var currentVenueName:String?
            
            let json = JSON(data: data!)
            currentVenueName = json["response"]["venues"][0]["name"].string
            
            // set label name and visible
            DispatchQueue.main.async {
                if let v = currentVenueName {
                    print("\(v)")
                }
            }
        })
        task.resume()
    }
    
    func searchForVenue(searchText: String) {
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(currentLocation.latitude),\(currentLocation.longitude)&v=20160607&intent=\(searchText)&limit=15&client_id=\(client_id)&client_secret=\(client_secret)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, err -> Void in
            
            let json = JSON(data: data!)
            self.searchResults = json["response"]["group"]["results"].arrayValue
        })
        
        task.resume()
        print("\(searchResults)")
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return searchResults.count
        return 10
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        var tempString = ""
        
        if (numberOfSearches>1) {
            tempString.append(searchResults[(indexPath as NSIndexPath).row]["venue"]["name"].string!)
            tempString.append(" ")
            tempString.append("\(searchResults[(indexPath as NSIndexPath).row]["venue"]["location"]["distance"].intValue)m")
            tempString.append(" ")
            tempString.append(searchResults[(indexPath as NSIndexPath).row]["venue"]["location"]["address"].string!)
            cell.textLabel?.text = tempString
        }
        return cell
    }
}

