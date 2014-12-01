//
//  ViewController.swift
//  HowAboutHere
//
//  Created by Ronak Patel on 10/14/14.
//  Copyright (c) 2014 Ronak Patel. All rights reserved.
//

import UIKit
import MapKit
import QuartzCore

/* 
    ACCESIBLE GLOBALS:
    var currentPlacemarks:NSMutableArray
*/

//TODO: Cancel location updating on app backgrounding or cancellation



class ViewController: UIViewController, MKMapViewDelegate {

    /* 
        IBOutlets
    */
    
    @IBOutlet weak var placemarkName: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placemarkAddress: UILabel!
    @IBOutlet weak var placemarkPhoneNumber: UILabel!
    
    /* 
        local vars
    */
    var placemarkCount = 0
    var maxPlacemarkCount = currentPlacemarks.count
    
    /*
        initializing MapView vars
    */
    
    //level of "zoom"
    var latDelta:CLLocationDegrees = 0.005
    var longDelta:CLLocationDegrees = 0.005
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting MKMapView background
        mapView.layer.borderColor = UIColor.lightGrayColor().CGColor
        mapView.layer.borderWidth = 1.0
        mapView.layer.cornerRadius = 8
        
        //setting placemark on Map
        setPlacemarkOnMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
        Goes through placemarks array to shuffle nearby locations based on category
    */
    
    @IBAction func shufflePlacemarks(sender: AnyObject) {
        ++placemarkCount
        
        if(placemarkCount < maxPlacemarkCount){
            setPlacemarkOnMap()
        }
        else{
            placemarkCount = 0
            setPlacemarkOnMap()
        }
        
    }
    
    /*
        Method invoked when placemarkAddress button is clicked
    */
    @IBAction func openAddressInMaps(sender: UIButton) {
        if(placemarkAddress.text != "No Address Found"){
            var currentMapItem = currentPlacemarks[placemarkCount] as MKMapItem
            currentMapItem.openInMapsWithLaunchOptions(nil)
        }
    }
    
    /*
        Method invoked when placemarkPhone button is clicked
    */
    @IBAction func callNumber(sender: UIButton) {
        if(placemarkPhoneNumber.text != "No Number Found"){
            //TODO: Test on phone to check if working
            var telephoneString = "telprompt://\(placemarkPhoneNumber.text!)"
            
            //call number
            UIApplication.sharedApplication().openURL(NSURL(string: telephoneString)!)
        }
    }
    
    /*
        Reset count if Done Button pressed, then segue back to main table view
    */
    @IBAction func doneButtonPressed(sender: AnyObject) {
        placemarkCount = 0
    }
    
    
    func setPlacemarkOnMap(){
        
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation as MKPointAnnotation)
        }
        
        //setting currently viewed Placemark coordinate
        var currentPlacemarkLocation:CLLocationCoordinate2D = (currentPlacemarks[placemarkCount] as MKMapItem).placemark.coordinate
        
        //span from zooms
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        //designating region from location and the span
        var region:MKCoordinateRegion = MKCoordinateRegionMake(currentPlacemarkLocation, span)
        
        mapView.setRegion(region, animated: true)
        mapView.setCenterCoordinate(currentPlacemarkLocation, animated: true)
        
        //adding annotation point to map for Placemark
        var annot = MKPointAnnotation()
        annot.coordinate = currentPlacemarkLocation
        mapView.addAnnotation(annot)
        
        //updating information of placemark on view
        updateInformation(currentPlacemarks[placemarkCount] as MKMapItem)
    }
    
    /*
        updated UILabels with address and phone number
    */
    func updateInformation(currentPlacemark:MKMapItem){
        
        placemarkName.text = currentPlacemark.name
        
        //checking for nil and empty string values of placemark phone number
        if(currentPlacemark.phoneNumber == nil){
            placemarkPhoneNumber.text = "No Number Found"
        }
        else if(currentPlacemark.phoneNumber != ""){
            placemarkPhoneNumber.text = currentPlacemark.phoneNumber
        }
        else{
            placemarkPhoneNumber.text = "No Number Found"
            
        }
        
        //decoding placemark address
        CLGeocoder().reverseGeocodeLocation(currentPlacemark.placemark.location, completionHandler: {
            (allPlacemarks, error) in
            
            if(error != nil){
                //TODO: If geocoding doesn't work, popup error alert and go back to categories
                println("Error: \(error)")
            }
            else{
                var geocodedPlacemark = CLPlacemark(placemark: allPlacemarks[0] as CLPlacemark)
                
                if(geocodedPlacemark.subThoroughfare != nil){
                    self.placemarkAddress.text = "\(geocodedPlacemark.subThoroughfare) \(geocodedPlacemark.thoroughfare) \n\(geocodedPlacemark.locality), \(geocodedPlacemark.administrativeArea) \(geocodedPlacemark.postalCode)"
                }
                else{
                    self.placemarkAddress.text = "No Address Found"
                }
            }
        })
        
    }
    
    
}

