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

class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var parkListButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var amenitySearchButton: UIButton!
    
    static var backgrounds = [UIImage]()
    
    var imageView: UIImageView!
    var backgroundIndex: Int = 0
    var timer: Timer!
    var favoritesActive = false
    var defFavoritesY: CGFloat = 0
    var updatingTable = false
    
    override func viewWillAppear(_ animated: Bool) {
        //hide nav bar
        navigationController!.navigationBar.isHidden = true
        favoritesTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //show nav bar
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewStretch = max(0, (view.frame.height/view.frame.width)-1.75)
        let startBoost = viewStretch*160
        let heightNum = 16+42+16+42+16+32
        let bottomHeight = CGFloat(heightNum)+(viewStretch*80)
        var topPadding = UIApplication.shared.keyWindow!.safeAreaInsets.top
        
        if topPadding == 0 {
            topPadding = 16
        }
        
        //set up logo
        logoImage.frame = CGRect(x: view.frame.width/4, y: navigationController!.navigationBar.frame.maxY+48+startBoost, width: view.frame.width/2, height: view.frame.width/2)
        logoImage.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoPressed))
        logoImage.addGestureRecognizer(tapRecognizer)
        
        //menu button
        menuButton.frame = CGRect(x: view.frame.maxX - 16 - 60, y: topPadding + 16, width: 60, height: 34)
        menuButton.layer.cornerRadius = 10
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = menuButton.titleLabel!.textColor.cgColor
        
        //button borders
        favoritesButton.layer.borderWidth = 1
        favoritesButton.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        parkListButton.layer.borderWidth = 1
        parkListButton.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        mapButton.layer.borderWidth = 1
        mapButton.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        amenitySearchButton.layer.borderWidth = 1
        amenitySearchButton.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
        defFavoritesY = view.frame.maxY - bottomHeight
        favoritesButton.frame = CGRect(x: view.frame.minX + 16, y: defFavoritesY, width: view.frame.width - 32, height: 42)
        favoritesButton.layer.cornerRadius = 10
        
        favoritesTable.frame = CGRect(x: view.frame.minX+16, y: favoritesButton.frame.maxY + 4, width: view.frame.width-32, height: 0)
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.isScrollEnabled = true
        favoritesTable.allowsMultipleSelectionDuringEditing = false
        favoritesTable.layer.cornerRadius = 10
        favoritesTable.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.65)
        
        parkListButton.frame = CGRect(x: view.frame.minX + 16, y: favoritesButton.frame.maxY + 8, width: (view.frame.width/2 - 4) - (view.frame.minX + 16), height: 42)
        parkListButton.layer.cornerRadius = 10
        
        mapButton.frame = CGRect(x: parkListButton.frame.maxX + 8, y: favoritesButton.frame.maxY + 8, width: (view.frame.width - 16) - (parkListButton.frame.maxX + 8), height: 42)
        mapButton.layer.cornerRadius = 10
        
        amenitySearchButton.frame = CGRect(x: view.frame.minX + 16, y: parkListButton.frame.maxY + 8, width: view.frame.width - 32, height: 42)
        amenitySearchButton.layer.cornerRadius = 10
        
        //background image
        imageView = UIImageView(image: MenuController.backgrounds[0])
        imageView.frame = view.frame
        self.view.addSubview(imageView)
        
        //background blur
        let blurEffect = UIBlurEffect(style: .regular)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.7
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        view.sendSubview(toBack: blurredEffectView)
        view.sendSubview(toBack: imageView)
        
        //circle around logo
        let logoRadius = logoImage.frame.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: logoImage.frame.minX+logoRadius, y: logoImage.frame.minY+logoRadius+2), radius: logoRadius+10, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi*2), clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        circleLayer.fillColor = UIColor.white.withAlphaComponent(0.4).cgColor
        blurredEffectView.layer.addSublayer(circleLayer)
        
        //update background images
        timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(updateBackground), userInfo: nil, repeats: true)
        
        Utilities.checkFirstLaunch(controller: self)
    }
    
    @objc func logoPressed() {
        if let url = URL(string: Constants.WEBSITE) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func updateBackground() {
        backgroundIndex = (backgroundIndex+1)%MenuController.backgrounds.count
        let newImage = MenuController.backgrounds[backgroundIndex]
        UIView.transition(with: imageView, duration: 2, options: .transitionCrossDissolve, animations: {self.imageView.image = newImage}, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Utilities.favorites.count == 0 && !updatingTable {
            return 1
        }
        
        return Utilities.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Utilities.favorites.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! FavoriteCell
            cell.parkTitle.text = Utilities.favorites[(indexPath as NSIndexPath).row]
            return cell
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "NoFavoriteCell")! as UITableViewCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Utilities.favorites.count == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
        let menuNavigation = self.navigationController as! MenuNavigation
        
        destController.parkName = Utilities.favorites[(indexPath as NSIndexPath).row]
        
        hideSideMenuView()
        tableView.deselectRow(at: indexPath, animated: true)
        menuNavigation.pushViewController(destController, animated: true)
        
        Utilities.loadPark(menuNavigation)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return Utilities.favorites.count > 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Utilities.toggleFavorite(Utilities.favorites[indexPath.row])
            
            updatingTable = true
            tableView.deleteRows(at: [indexPath], with: .fade)
            updatingTable = false
            
            if Utilities.favorites.count == 0 {
                tableView.insertRows(at: [indexPath], with: .none)
            }
        }
    }
    
    @IBAction func favoritesPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            //toggle favorites
            self.favoritesActive = !self.favoritesActive
            //set up new bottom frame from new starting y pos
            let yStart = self.favoritesActive ? self.logoImage.frame.maxY + 32 : self.defFavoritesY
            self.favoritesButton.frame = CGRect(x: self.view.frame.minX + 16, y: yStart, width: self.view.frame.width - 32, height: 42)
            let tableYStart = self.favoritesButton.frame.maxY + (self.favoritesActive ? 8 : 4)
            //set up table view from these updated positions
            let frame = self.favoritesTable.frame
            var height = (self.parkListButton.frame.minY - 8) - tableYStart
            //we don't want a negative height
            if !self.favoritesActive {
                height = 0
            }
            self.favoritesTable.frame = CGRect(x: frame.minX, y: tableYStart, width: frame.width, height: height)
        })
    }
    
    @IBAction func parkListPressed(_ sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkSearchController") as! ParkSearchController
        menuNavigation.pushViewController(destController, animated: true)
    }
    
    @IBAction func amenitySearchPressed(_ sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "AmenityController") as! AmenityController
        menuNavigation.pushViewController(destController, animated: true)
    }
    
    @IBAction func menuPressed(_ sender: AnyObject) {
        toggleSideMenuView()
    }
    
    @IBAction func mapPressed(_ sender: AnyObject) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavigation = self.navigationController as! MenuNavigation
        let destController = mainStoryboard.instantiateViewController(withIdentifier: "MapController") as! MapController
        menuNavigation.pushViewController(destController, animated: true)
    }
}
