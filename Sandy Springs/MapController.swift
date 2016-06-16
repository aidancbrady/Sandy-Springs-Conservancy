//
//  MapController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/16/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    let centerCoordLat = 33.9304;
    let centerCoordLong = -84.3733;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(centerCoordLat, centerCoordLong), MKCoordinateSpanMake(self.mapView.region.span.longitudeDelta/1024, self.mapView.region.span.latitudeDelta/1024))
        
        for data in ParkController.Parks.parkData
        {
            let point = MKPointAnnotation()
            
            point.coordinate = data.1.coords
            point.title = data.0
            point.subtitle = data.1.address
            
            mapView.addAnnotation(point)
        }
        
        mapView.setRegion(region, animated: false)
    }
    
    @IBAction func donePressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKindOfClass(MKUserLocation)
        {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnimation")
        
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewControllerWithIdentifier("ParkController") as! ParkController
        let menuNavigation = self.presentingViewController as! MenuNavigation
            
        destController.parkName = view.annotation!.title!
        
        hideSideMenuView()
        menuNavigation.setViewControllers([destController], animated: true)
        self.dismissViewControllerAnimated(false, completion: nil)
        
        for i in 0..<menuNavigation.tableController.menuData.count
        {
            menuNavigation.tableController.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: false)
        }
        
        menuNavigation.tableController.selectedItem = -1
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            usleep(1000*1000)
            dispatch_async(dispatch_get_main_queue(), {
                if menuNavigation.topViewController is ParkController
                {
                    (menuNavigation.topViewController as! ParkController).loadMap()
                }
            })
        })
    }
}
