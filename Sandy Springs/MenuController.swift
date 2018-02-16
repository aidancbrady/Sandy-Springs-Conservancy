//
//  MenuController.swift
//  Sandy Springs
//
//  Created by aidancbrady on 1/26/15.
//  Copyright (c) 2015 aidancbrady. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var parkListButton: UIButton!
    @IBOutlet weak var amenitySearchButton: UIButton!
    
    var imageView: UIImageView!
    var backgroundIndex: Int = 0
    var timer: Timer!
    var favoritesActive = false
    var defFavoritesY: CGFloat = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //hide nav bar
        navigationController!.navigationBar.isHidden = true
        
        let viewStretch = (view.frame.height/view.frame.width)-1.75
        let startBoost = viewStretch*160
        let bottomHeight = CGFloat(16+42+16+42+16+32)+(viewStretch*80)
        var topPadding = UIApplication.shared.keyWindow!.safeAreaInsets.top
        
        if topPadding == 0 {
            topPadding = 16
        }
        
        logoImage.frame = CGRect(x: view.frame.width/4, y: navigationController!.navigationBar.frame.maxY+48+startBoost, width: view.frame.width/2, height: view.frame.width/2)
        logoImage.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoPressed))
        logoImage.addGestureRecognizer(tapRecognizer)
        
        menuButton.frame = CGRect(x: view.frame.minX + 16, y: topPadding + 16, width: 60, height: 34)
        menuButton.layer.cornerRadius = 10
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = menuButton.titleLabel!.textColor.cgColor
        
        favoritesButton.layer.borderWidth = 2
        favoritesButton.layer.borderColor = menuButton.titleLabel!.textColor.cgColor
        parkListButton.layer.borderWidth = 2
        parkListButton.layer.borderColor = menuButton.titleLabel!.textColor.cgColor
        amenitySearchButton.layer.borderWidth = 2
        amenitySearchButton.layer.borderColor = menuButton.titleLabel!.textColor.cgColor
        
        defFavoritesY = view.frame.maxY - bottomHeight
        favoritesButton.frame = CGRect(x: view.frame.minX + 16, y: defFavoritesY, width: view.frame.width - 32, height: 42)
        favoritesButton.layer.cornerRadius = 10
        
        favoritesTable.frame = CGRect(x: view.frame.minX+16, y: favoritesButton.frame.maxY + 16, width: view.frame.width-32, height: 0)
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.isScrollEnabled = true
        favoritesTable.layer.cornerRadius = 10
        favoritesTable.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.65)
        
        parkListButton.frame = CGRect(x: view.frame.minX + 16, y: favoritesButton.frame.maxY + 8, width: view.frame.width - 32, height: 42)
        parkListButton.layer.cornerRadius = 10
        
        amenitySearchButton.frame = CGRect(x: view.frame.minX + 16, y: parkListButton.frame.maxY + 8, width: view.frame.width - 32, height: 42)
        amenitySearchButton.layer.cornerRadius = 10
        
        //background image
        imageView = UIImageView(image: UIImage(named: "background_0.png"))
        imageView.frame = view.frame
        self.view.addSubview(imageView)
        
        //background blur
        let blurEffect = UIBlurEffect(style: .regular)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.9
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        view.sendSubview(toBack: blurredEffectView)
        view.sendSubview(toBack: imageView)
        
        //update background images
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(updateBackground), userInfo: nil, repeats: true)
    }
    
    @objc func logoPressed()
    {
        print("TET")
        if let url = URL(string: "https://sandyspringsconservancy.org")
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func updateBackground()
    {
        backgroundIndex = (backgroundIndex+1)%3
        let newImage = UIImage(named: "background_" + String(backgroundIndex) + ".png")
        UIView.transition(with: imageView, duration: 2, options: .transitionCrossDissolve, animations: {self.imageView.image = newImage}, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 52
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if Utilities.favorites.count == 0
        {
            return 1
        }
        
        return Utilities.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if Utilities.favorites.count > 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! FavoriteCell
            
            cell.parkTitle.text = Utilities.favorites[(indexPath as NSIndexPath).row]
            
            return cell
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "NoFavoriteCell")! as UITableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if Utilities.favorites.count == 0
        {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
        let menuNavigation = self.navigationController as! MenuNavigation
        
        destController.parkName = Utilities.favorites[(indexPath as NSIndexPath).row]
        
        hideSideMenuView()
        menuNavigation.setViewControllers([destController], animated: true)
        
        Utilities.loadPark(menuNavigation)
    }
    
    @IBAction func favoritesPressed(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, animations: {
            //toggle favorites
            self.favoritesActive = !self.favoritesActive
            //set up new bottom frame from new starting y pos
            let yStart = self.favoritesActive ? self.logoImage.frame.maxY + 32 : self.defFavoritesY
            self.favoritesButton.frame = CGRect(x: self.view.frame.minX + 16, y: yStart, width: self.view.frame.width - 32, height: 42)
            //set up table view from these updated positions
            let frame = self.favoritesTable.frame
            var height = (self.parkListButton.frame.minY - 16) - (self.favoritesButton.frame.maxY + 16)
            //we don't want a negative height
            if !self.favoritesActive {
                height = 0
            }
            self.favoritesTable.frame = CGRect(x: frame.minX, y: self.favoritesButton.frame.maxY + 16, width: frame.width, height: height)
        })
    }
    
    @IBAction func parkListPressed(_ sender: AnyObject)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkSearchController") as! ParkSearchController
        menuNavigation.setViewControllers([destController], animated: true)
        menuNavigation.tableController.selectedItem = -1
    }
    
    @IBAction func amenitySearchPressed(_ sender: AnyObject)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "AmenityController") as! AmenityController
        menuNavigation.setViewControllers([destController], animated: true)
        menuNavigation.tableController.selectedItem = -1
        
        //For testing purposes
        /*let data = ParkController.Parks.parkData["Abernathy Greenway"]!
        let content = UNMutableNotificationContent()
        content.title = "You're Near " + data.parkName
        content.body = "Tap for more details."
        content.userInfo = ["PARK":data.parkName]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error requesting notification: (\(error), \(error.localizedDescription))")
            }
        }*/
    }
    
    @IBAction func menuPressed(_ sender: AnyObject)
    {
        toggleSideMenuView()
    }
    
    @IBAction func mapPressed(_ sender: AnyObject)
    {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "MapController") as! MapController
        menuNavigation.setViewControllers([destController], animated: true)
        menuNavigation.tableController.selectedItem = -1
    }
}
