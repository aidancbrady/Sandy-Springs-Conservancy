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
        let annotation = view.annotation!
        let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let park = ParkController.Parks.parkData[annotation.title!!]!
        
        mapItem.name = annotation.title!
        mapItem.phoneNumber = park.phone
        mapItem.openInMapsWithLaunchOptions(nil)
    }
}
