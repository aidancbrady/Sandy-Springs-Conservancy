//
//  ParkController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 2/20/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class ParkController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let favoriteEdge = UIEdgeInsets(top: 5, left: 17, bottom: 5, right: 0)
    
    var imageScroll: UIScrollView!
    var imageViews: [UIImageView] = [UIImageView]()
    var pageControl: UIPageControl!
    
    var parkName: String!
    var park: ParkData!
    
    var manager:CLLocationManager?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //show nav bar
        navigationController!.navigationBar.isHidden = false
        
        manager = CLLocationManager()
        manager!.delegate = self
        manager!.desiredAccuracy = kCLLocationAccuracyBest
        manager!.requestAlwaysAuthorization()
        manager!.startUpdatingLocation()

        setParkData()
        
        phoneLabel.isUserInteractionEnabled = true
        
        mapView.delegate = self
        
        //Favorite menu bar item
        updateFavoriteButton(Utilities.isFavorite(parkName))

        //Setup main scroll view
        scrollView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        
        //Setup image view's horizontal paging scroll view
        imageScroll = UIScrollView(frame: CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.width/1.68))
        imageScroll.isPagingEnabled = true
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
        descriptionView.font = UIFont.systemFont(ofSize: 17)
        descriptionView.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        let maxWidth = scrollView.frame.width - 32
        let descSize = descriptionView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
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
        amenityView.backgroundColor = UIColor.groupTableViewBackground
        
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
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: mapView.frame.maxY)
        
        mapView.isHidden = true
        
        let region = MKCoordinateRegionMake(park.coords, MKCoordinateSpanMake(self.mapView.region.span.longitudeDelta/8192, self.mapView.region.span.latitudeDelta/8192))
        let point = MKPointAnnotation()
        
        point.coordinate = park.coords
        point.title = self.parkName
        point.subtitle = self.park.address
        
        self.mapView.setRegion(region, animated: false)
        self.mapView.addAnnotation(point)
        self.mapView.isScrollEnabled = false
    }
    
    func loadMap()
    {
        mapView.isHidden = false
        mapView.alpha = 0.1
        
        UIView.transition(with: view, duration: 0.4, options: UIViewAnimationOptions.curveEaseOut, animations: {() in
            self.mapView.alpha = 1
        }, completion: {b in
            return
        })
    }
    
    @objc func onFavoriteToggle(_ sender: AnyObject)
    {
        updateFavoriteButton(Utilities.toggleFavorite(parkName))
    }
    
    func updateFavoriteButton(_ favorite: Bool)
    {
        let btnFavourite = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btnFavourite.addTarget(self, action: #selector(onFavoriteToggle), for: .touchUpInside)
        btnFavourite.setImage(UIImage(named: favorite ? "heart_filled" : "heart_empty")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        btnFavourite.imageEdgeInsets = favoriteEdge
        
        let rightButton = UIBarButtonItem(customView: btnFavourite)
        rightButton.tintColor = UIColor.blue
        self.navigationItem.setRightBarButtonItems([rightButton], animated: true)
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
        let annotation = view.annotation!
        let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = annotation.title!
        mapItem.phoneNumber = park.phone
        mapItem.openInMaps(launchOptions: nil)
    }
    
    func setParkData()
    {
        park = Parks.parkData[parkName]
        let label = MarqueeLabel(frame: CGRect.zero, duration: 2.0, fadeLength: 10.0)
        label.adjustsFontSizeToFitWidth = true
        label.fadeLength = 10
        label.type = .leftRight
        label.text = parkName
        label.sizeToFit()
        self.navigationItem.titleView = label
        descriptionView.text = park.description
        phoneLabel.text = park.phone
    }
    
    @IBAction func numberTapped(_ sender: AnyObject)
    {
        let number = park.phone.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        
        if let url = URL(string: "tel://" + number)
        {
            let alertController = UIAlertController(title: "Confirm", message: "Call " + parkName + "?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Call", style: .default, handler: {action in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            let noAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func menuPressed(_ sender: AnyObject)
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
                let region = CLCircularRegion(center: data.1.coords, radius: 150, identifier: data.0)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                let content = UNMutableNotificationContent()
                content.title = "You're Near " + data.value.parkName
                content.body = "Tap for more details."
                content.userInfo = ["PARK":data.key]
                let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
                let identifier = data.value.parkName.replacingOccurrences(of: " ", with: "")
                let request = UNNotificationRequest(identifier: identifier + "_region_notification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    if let error = error {
                        print("Error requesting notification: (\(error), \(error.localizedDescription))")
                    }
                }
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
    var imageSize = 45
    
    init(amenityName: String, xPos: Int, yPos: Int)
    {
        super.init(frame: CGRect(x: xPos, y: yPos, width: frameSize, height: frameSize))
        self.amenityName = amenityName
        
        imageView = UIImageView(frame: CGRect(x: (frameSize/2)-(imageSize/2), y: 20, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: Utilities.formatAmenity(self.amenityName))?.withRenderingMode(.alwaysTemplate)
        addSubview(imageView)
        let yStart = Int(imageView.frame.maxY)
        amenityLabel = UILabel(frame: CGRect(x: 0, y: yStart, width: frameSize, height: 30))
        amenityLabel.numberOfLines = 0
        amenityLabel.text = amenityName
        amenityLabel.textAlignment = NSTextAlignment.center
        amenityLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(amenityLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
