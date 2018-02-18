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
        
        //show nav bar
        navigationController!.navigationBar.isHidden = false
        
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
        mapView.showsUserLocation = true
    }
    
    @IBAction func donePressed(_ sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKind(of: MKUserLocation.self)
        {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnimation")
        
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
        let menuNavigation = self.navigationController as! MenuNavigation
            
        destController.parkName = view.annotation!.title!
        
        hideSideMenuView()
        menuNavigation.pushViewController(destController, animated: true)
        
        Utilities.loadPark(menuNavigation)
    }
}
