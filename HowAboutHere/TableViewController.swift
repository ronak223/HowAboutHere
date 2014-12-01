//
//  TableViewController.swift
//  HowAboutHere
//
//  Created by Ronak Patel on 10/15/14.
//  Copyright (c) 2014 Ronak Patel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


var currentPlacemarks = []
var categories:[NSString] = []

class TableViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    /*
        IBOutlets
    */
    @IBOutlet var categoriesTable: UITableView!
    
    /*
        CLLocation vars
    */
    var manager = CLLocationManager()
    var request = MKLocalSearchRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //have to manually set delegate here since CoreLocation is not on the StoryBoard
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //checking NSUserDefaults for category list, if it exists. Otherwise, create one
        if var storedCategories:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("categories"){
            //Iterate through array and add to categories
            categories = []
            for(var i = 0; i < storedCategories.count; ++i){
                categories.append(storedCategories[i] as NSString)
            }
        }
        else{
            //instantiate default list of categories
            categories = ["Food", "Bar", "Bank", "Convenience Store"]
            let fixedCategories = categories
            NSUserDefaults.standardUserDefaults().setObject(fixedCategories, forKey: "categories")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    /*
        override tableView method for when view appears
    */
    override func viewWillAppear(animated: Bool) {
        categoriesTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
        method invoked when "Add" plus button is clicked on header bar
    */
    @IBAction func addCategoryButtonClicked(sender: UIBarButtonItem) {
        
        var alert = UIAlertController(title: "Add Category", message: "Please enter a category", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "e.g. Mall, Department Store, etc"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { action in
            let alertTextField:UITextField = (alert.textFields as [UITextField])[0]
            if(alertTextField.hasText()){
                categories.append(alertTextField.text as NSString)
                
                //adding new category array to NSUserDefaults
                let currentCategoryList = categories
                NSUserDefaults.standardUserDefaults().setObject(currentCategoryList, forKey: "categories")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.categoriesTable.reloadData()
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /*
        necessary UITableViewDataSource methods
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return categories.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel.text = (categories[indexPath.row] as String)
        return cell
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        //setting the naturalQueryString for MKLocalSearch request
        request.naturalLanguageQuery = tableView.cellForRowAtIndexPath(indexPath)?.textLabel.text
        
        var search:MKLocalSearch = MKLocalSearch(request: request)
        search.startWithCompletionHandler{
            (response:MKLocalSearchResponse!, error:NSError!) in
            if (error == nil){
                var placemarks:NSMutableArray = NSMutableArray()
                
                for item in response.mapItems {
                    placemarks.addObject((item as MKMapItem))
                }
                
                //setting global placemark coords for next view
                currentPlacemarks = placemarks
                
                //move to next screen
                if(currentPlacemarks.count != 0){
                    self.performSegueWithIdentifier("categorySelectionSegue", sender: self)
                }
                else{
                    let tapAlert = UIAlertController(title: "Uh oh!", message: "There weren't any nearby locations found", preferredStyle: UIAlertControllerStyle.Alert)
                    tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
                    self.presentViewController(tapAlert, animated: true, completion: nil)
                }
                
                
            }
        }
    }
    
    /*
        tableView method to allow for slide deletion
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            categories.removeAtIndex(indexPath.row)
            let newFixedCategories = categories
            NSUserDefaults.standardUserDefaults().setObject(newFixedCategories, forKey: "categories")
            NSUserDefaults.standardUserDefaults().synchronize()
            categoriesTable.reloadData()
        }
    }
    
    /*
        methods for CoreLocationManager
    */
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation:CLLocation = locations[0] as CLLocation
        
        //level of "zoom"
        var latDelta:CLLocationDegrees = 0.01
        var longDelta:CLLocationDegrees = 0.01
        
        //span from zooms
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        //making single location point
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        //designating region from location and the span
        var region = MKCoordinateRegionMake(location, span)
        
        //setting up MKLocalSearch request instance with region
        request.region = region
        
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        let tapAlert = UIAlertController(title: "Uh oh!", message: "There was an error with Location Manager", preferredStyle: UIAlertControllerStyle.Alert)
        tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        self.presentViewController(tapAlert, animated: true, completion: nil)
    }
    

}
