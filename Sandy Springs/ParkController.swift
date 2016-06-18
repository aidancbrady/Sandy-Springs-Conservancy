//
//  ParkController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 2/20/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit
import MapKit

class ParkController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let favoriteEdge = UIEdgeInsets(top: 6, left: 12, bottom: 8, right: 3)
    
    var imageScroll: UIScrollView!
    var imageViews: [UIImageView] = [UIImageView]()
    var pageControl: UIPageControl!
    
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
        
        //Favorite menu bar item
        updateFavoriteButton(Utilities.isFavorite(parkName))

        //Setup main scroll view
        scrollView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        
        //Setup image view's horizontal paging scroll view
        imageScroll = UIScrollView(frame: CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.width/1.68))
        imageScroll.pagingEnabled = true
        imageScroll.delegate = self
        scrollView.addSubview(imageScroll)
        
        //Add individual images to scroll view
        for i in 0..<park.images.count
        {
            let imageX = imageScroll.frame.minX + CGFloat(i)*imageScroll.frame.width
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: imageX, y: imageScroll.frame.minY), size: imageScroll.frame.size))
            imageScroll.addSubview(imageView)
            imageViews.append(imageView)
        }
        
        park.setImages(self)
        
        imageScroll.contentSize = CGSize(width: imageScroll.frame.width*CGFloat(park.images.count), height: imageScroll.frame.height)
        
        //Setup park description view
        descriptionView.font = UIFont.systemFontOfSize(17)
        descriptionView.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let maxWidth = scrollView.frame.width - 32
        let descSize = descriptionView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.max))
        descriptionView.frame.size = CGSize(width: max(maxWidth, descSize.width), height: descSize.height)
        descriptionView.frame = CGRect(origin: CGPoint(x: view.frame.minX + 16, y: imageScroll.frame.maxY + 8), size: descriptionView.frame.size)
        
        //Setup phone labels
        phoneTitleLabel.frame.origin.y = descriptionView.frame.maxY + 8
        phoneLabel.frame.origin.y = descriptionView.frame.maxY + 8
        
        //Amenity layout
        let margins = 20
        let amenityWidth = view.frame.width-CGFloat(margins*2)
        let perRow = Int(amenityWidth/110)
        let rows = Int(ceil(Float(park.amenities.count)/Float(perRow)))
        
        let amenityView = UIView(frame: CGRect(x: view.frame.minX, y: phoneTitleLabel.frame.maxY + 8, width: view.frame.width, height: CGFloat(rows*110) - 10))
        amenityView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        for i in 0..<rows
        {
            for j in 0..<perRow
            {
                let index = i*perRow + j
                
                if index > park.amenities.count-1
                {
                    break
                }
                
                let startX = (Int(amenityWidth)/perRow)/2 - 110/2
                let amenity = AmenityView(amenityName: park.amenities[index], xPos: margins + (Int(amenityWidth)/perRow)*j + startX, yPos: 110*i)
                amenityView.addSubview(amenity)
            }
        }
        
        scrollView.addSubview(amenityView)
        
        //Setup map label and view
        mapLabel.frame = CGRect(x: mapLabel.frame.minX, y: amenityView.frame.maxY + 4 + 8, width: mapLabel.frame.width, height: mapLabel.frame.height)
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
    
    func onFavoriteToggle(sender: AnyObject)
    {
        updateFavoriteButton(Utilities.toggleFavorite(parkName))
    }
    
    func updateFavoriteButton(favorite: Bool)
    {
        let btnFavourite = UIButton(frame: CGRectMake(0, 0, 30, 30))
        btnFavourite.addTarget(self, action: #selector(onFavoriteToggle), forControlEvents: .TouchUpInside)
        btnFavourite.setImage(UIImage(named: favorite ? "heart_filled" : "heart_empty")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        let rightButton = UIBarButtonItem(customView: btnFavourite)
        rightButton.imageInsets = favoriteEdge
        rightButton.tintColor = UIColor.blueColor()
        self.navigationItem.setRightBarButtonItems([rightButton], animated: true)
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
}

class AmenityView: UIView
{
    var amenityName: String!
    
    var imageView: UIImageView!
    var amenityLabel: UILabel!
    
    var frameSize = 110
    var imageSize = 60
    
    init(amenityName: String, xPos: Int, yPos: Int)
    {
        super.init(frame: CGRect(x: xPos, y: yPos, width: frameSize, height: frameSize))
        self.amenityName = amenityName
        
        imageView = UIImageView(frame: CGRect(x: (frameSize/2)-(imageSize/2), y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "park_leaf")
        addSubview(imageView)
        let yStart = Int(imageView.frame.maxY)
        amenityLabel = UILabel(frame: CGRect(x: 0, y: yStart, width: frameSize, height: 30))
        amenityLabel.numberOfLines = 0
        amenityLabel.text = amenityName
        amenityLabel.textAlignment = NSTextAlignment.Center
        amenityLabel.font = UIFont.systemFontOfSize(15)
        addSubview(amenityLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}