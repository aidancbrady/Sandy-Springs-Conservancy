//
//  ParkController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 2/20/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit
import MapKit

class ParkController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var parkName: String!
    var park: ParkData!
    
    var manager:CLLocationManager?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager!.delegate = self
        manager!.desiredAccuracy = kCLLocationAccuracyBest
        manager!.requestAlwaysAuthorization()
        manager!.startUpdatingLocation()

        setParkData()
        
        phoneLabel.userInteractionEnabled = true
        
        mapView.delegate = self
        
        imageView.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.minY, width: view.frame.width, height: imageView.frame.height)
        scrollView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        
        //Setup park description view
        descriptionView.font = UIFont.systemFontOfSize(17)
        descriptionView.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let maxWidth = scrollView.frame.width - 32
        let descSize = descriptionView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.max))
        descriptionView.frame.size = CGSize(width: max(maxWidth, descSize.width), height: descSize.height)
        descriptionView.frame = CGRect(origin: CGPoint(x: view.frame.minX + 16, y: imageView.frame.maxY + 8), size: descriptionView.frame.size)
        
        phoneTitleLabel.frame.origin.y = descriptionView.frame.maxY + 8
        phoneLabel.frame.origin.y = descriptionView.frame.maxY + 8
        
        amenitiesLabel.frame.origin.y = phoneTitleLabel.frame.maxY + 8
        
        let startX = amenitiesLabel.frame.minX + 8
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
        
        let region = MKCoordinateRegionMake(park.coords, MKCoordinateSpanMake(self.mapView.region.span.longitudeDelta/8192, self.mapView.region.span.latitudeDelta/8192))
        let point = MKPointAnnotation()
        
        point.coordinate = park.coords
        point.title = self.parkName
        point.subtitle = self.park.address
        
        self.mapView.setRegion(region, animated: false)
        self.mapView.addAnnotation(point)
        self.mapView.scrollEnabled = false
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
        
        mapItem.name = annotation.title!
        mapItem.phoneNumber = park.phone
        mapItem.openInMapsWithLaunchOptions(nil)
    }
    
    func setParkData()
    {
        park = Parks.parkData[parkName]
        self.navigationItem.title = parkName
        descriptionView.text = park.description
        phoneLabel.text = park.phone
        park.setImage(self)
    }
    
    @IBAction func numberTapped(sender: AnyObject)
    {
        let number = park.phone.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("-", withString: "")
        
        if let url = NSURL(string: "tel://" + number)
        {
            let alertController = UIAlertController(title: "Confirm", message: "Call " + parkName + "?", preferredStyle: .Alert)
            let yesAction = UIAlertAction(title: "Call", style: .Default, handler: {action in
                UIApplication.sharedApplication().openURL(url)
            })
            let noAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func menuPressed(sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    struct Parks
    {
        static var parkData = [String: ParkData]()
        
        static func initLocationUpdates()
        {
            for data in parkData
            {
                let notification = UILocalNotification()
                notification.alertBody = "Arrived at " + data.0
                notification.regionTriggersOnce = false
                notification.region = CLCircularRegion(center: data.1.coords, radius: 100, identifier: data.0)
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
    }
    
    class ParkData
    {
        var imageUrl: String!
        var description: String!
        var phone: String!
        var amenities: [String] = [String]()
        var address: String!
        var image: UIImage?
        
        var coords: CLLocationCoordinate2D!
        
        init(imageUrl: String)
        {
            self.imageUrl = imageUrl
        }
        
        func setDescription(description: String) -> ParkData
        {
            self.description = description
            
            return self
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
        
        func setCoords(x: Double, y: Double) -> ParkData
        {
            coords = CLLocationCoordinate2DMake(x, y)
            
            return self
        }
        
        func setImage(controller:ParkController)
        {
            controller.imageView.image = image
        }
        
        class func initPark(data:NSDictionary)
        {
            let park = ParkData(imageUrl: data["image"] as! String)
            park.setDescription(data["description"] as! String)
            park.setPhone(data["phone"] as! String)
            park.setCoords(data["coordX"] as! Double, y: data["coordY"] as! Double)
            park.setAddress(data["address"] as! String)
            
            if let amenities = data["amenities"] as? NSArray
            {
                for obj in amenities
                {
                    if let amenity = obj as? String
                    {
                        park.amenities.append(amenity)
                    }
                }
            }
            
            Parks.parkData[data["name"] as! String] = park
            
            //preload image asynchronously
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                if let url = NSURL(string: AppDelegate.DATA_URL + park.imageUrl)
                {
                    if let data = NSData(contentsOfURL: url)
                    {
                        park.image = UIImage(data: data)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    if let window:UIWindow = UIApplication.sharedApplication().keyWindow as UIWindow!
                    {
                        if var controller:UIViewController = window.rootViewController as UIViewController!
                        {
                            let navigation:MenuNavigation = controller.presentedViewController as! MenuNavigation
                            controller = navigation.viewControllers[0] as UIViewController
                            
                            if controller is ParkController
                            {
                                let parkController = controller as! ParkController
                                
                                if park === parkController.park
                                {
                                    park.setImage(parkController)
                                }
                            }
                        }
                    }
                })
            })
        }
    }
}