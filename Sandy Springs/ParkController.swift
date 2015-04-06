//
//  ParkController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 2/20/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit
import MapKit

class ParkController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var parkName: String!
    var park: ParkData!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setParkData()
        
        mapView.delegate = self
        
        imageView.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY, width: view.frame.width, height: imageView.frame.height)
        scrollView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        
        var startX = amenitiesLabel.frame.minX + 8
        var startY = amenitiesLabel.frame.maxY + 8
        
        for data in park.amenities
        {
            let label = UILabel(frame: CGRectMake(startX, startY, amenitiesLabel.frame.width-8, amenitiesLabel.frame.height))
            label.text = "- " + data
            scrollView.addSubview(label)
            startY += label.frame.height + 4
        }
        
        mapLabel.frame = CGRect(x: mapLabel.frame.minX, y: startY + 4 + 8, width: mapLabel.frame.width, height: mapLabel.frame.height)
        mapView.frame = CGRect(x: view.frame.minX, y: mapLabel.frame.maxY + 8, width: view.frame.width, height: 2*view.frame.width/3)
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, mapView.frame.maxY)
        
        mapView.hidden = true
        
        var geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(park.address, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark
            {
                let pRegion = placemark.region as CLCircularRegion
                
                let region = MKCoordinateRegionMake(pRegion.center, MKCoordinateSpanMake(self.mapView.region.span.longitudeDelta/8192, self.mapView.region.span.latitudeDelta/8192))
                let point = MKPointAnnotation()
                
                point.setCoordinate(pRegion.center)
                point.title = self.parkName
                point.subtitle = self.park.address
                
                self.mapView.setRegion(region, animated: false)
                self.mapView.addAnnotation(point)
            }
        })
    }
    
    func loadMap()
    {
        mapView.hidden = false
        mapView.alpha = 0.1
        
        UIView.transitionWithView(view, duration: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {() in
            self.mapView.alpha = 1
        }, completion: {b in
            return
        })
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
        if annotation.isKindOfClass(MKUserLocation)
        {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnimation")
        
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!)
    {
        let annotation = view.annotation
        let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = annotation.title
        mapItem.openInMapsWithLaunchOptions(nil)
    }
    
    func setParkData()
    {
        park = Parks.parkData[parkName]
        self.navigationItem.title = parkName
        imageView.image = UIImage(named: park.imageUrl)
        phoneLabel.text = park.phone
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    struct Parks
    {
        static var parkData = [String: ParkData]()
        
        static func checkParkData()
        {
            if Parks.parkData.count == 0
            {
                Parks.parkData["Abernathy Greenway"] = ParkData(imageUrl: "greenway.jpeg").setPhone("(770) 730-5600").setAmenities("Pavilion", "Picnic Tables", "Playground", "Restrooms").setAddress("70 Abernathy Road Sandy Springs, GA 30328")
                
                Parks.parkData["Abernathy Park"] = ParkData(imageUrl: "abernathy.jpeg").setPhone("(770) 730-5600").setAmenities("Playground", "Tennis Courts").setAddress("254 Johnson Ferry Rd Sandy Springs, GA 30068")
                
                Parks.parkData["Allen Road"] = ParkData(imageUrl: "allen.jpeg").setPhone("(770) 730-5600").setAmenities("Basketball", "Courts", "Picnic Tables", "Playground", "Sports Field", "Walking/Hiking", "Trails").setAddress("5900 Lake Forest Drive Sandy Springs, GA 30328")
                
                Parks.parkData["Big Trees Forest Preserve"] = ParkData(imageUrl: "trees.jpeg").setPhone("(770) 730-5600").setAmenities("Restrooms", "Walking/Hiking", "Trails").setAddress("7645 Roswell Road Sandy Springs, GA 30350")
                
                Parks.parkData["Chattahoochee River: East Palisades"] = ParkData(imageUrl: "river_palisades.jpeg").setPhone("(770) 952-0370").setAmenities("Walking/Hiking", "Trails").setAddress("1425 Indian Trail NW Sandy Springs, GA 30327")
                
                Parks.parkData["Chattahoochee River: Island Ford"] = ParkData(imageUrl: "river_ford.jpeg").setPhone("(770) 730-5600").setAmenities("Fishing", "Walking/Hiking", "Trails").setAddress("8850 Roberts Road Sandy Springs, GA 30350")
                
                Parks.parkData["Chattahoochee River: Powers Island"] = ParkData(imageUrl: "river_powers.jpeg").setPhone("(770) 952-0370").setAmenities("Walking/Hiking", "Trails").setAddress("5450 Interstate North Parkway Sandy Springs, GA 30328")
                
                Parks.parkData["Hammond Park"] = ParkData(imageUrl: "hammond.jpeg").setPhone("(770) 206-2035").setAmenities("Basketball", "Courts", "Gymnastics", "Center", "Pavilion", "Picnic Tables", "Playground", "Restrooms", "Sports Field", "Tennis Courts").setAddress("705 Hammond Drive Sandy Springs, GA 30328")
                
                Parks.parkData["Morgan Falls Ball Fields"] = ParkData(imageUrl: "morgan_fields.jpeg").setPhone("(770) 730-5600").setAmenities("Pavilion", "Picnic Tables", "Playground", "Restrooms", "Sports Field").setAddress("450 Morgan Falls Road Sandy Springs, GA 30350")
                
                Parks.parkData["Morgan Falls Overlook Park"] = ParkData(imageUrl: "morgan_overlook.jpeg").setPhone("(770) 730-5600").setAmenities("Fishing", "Picnic Tables", "Playground", "Restrooms", "Walking/Hiking", "Trails").setAddress("200 Morgan Falls Road Sandy Springs, GA 30350")
                
                Parks.parkData["Morgan Falls River Park"] = ParkData(imageUrl: "morgan_river.jpeg").setPhone("(770) 730-5600").setAmenities("Boat Ramp", "Dog Park", "Fishing").setAddress("100 Morgan Falls Road Sandy Springs, GA 30350")
                
                Parks.parkData["Ridgeview Park"] = ParkData(imageUrl: "ridgeview.jpeg").setPhone("(770) 730-5600").setAmenities("Pavilion", "Picnic Tables", "Playground", "Walking/Hiking", "Trails").setAddress("5200 South Trimble Road Sandy Springs, GA 30342")
                
                Parks.parkData["Sandy Springs Historical Site"] = ParkData(imageUrl: "historical_site.jpeg").setPhone("(404) 303-6182").setAmenities("Restrooms", "Tennis Courts", "Walking/Hiking", "Trails").setAddress("6075 Sandy Springs Circle Sandy Springs, GA 30328")
                
                Parks.parkData["Sandy Springs Tennis Center"] = ParkData(imageUrl: "tennis_center.jpeg").setPhone("(404) 851-1911").setAmenities("Walking/Hiking", "Trails").setAddress("500 Abernathy Road Sandy Springs, GA 30328")
            }
        }
    }
    
    class ParkData
    {
        var imageUrl: String!
        var phone: String!
        var amenities: [String] = [String]()
        var address: String!
        
        var coordX: Double!
        var coordY: Double!
        
        init(imageUrl: String)
        {
            self.imageUrl = imageUrl
        }
        
        func setPhone(phone: String) -> ParkData
        {
            self.phone = phone
            
            return self
        }
        
        func setAmenities(amenities: String...) -> ParkData
        {
            self.amenities = amenities
            
            return self
        }
        
        func setAddress(address: String) -> ParkData
        {
            self.address = address
            
            return self
        }
    }
}