//
//  InitController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 7/7/15.
//  Copyright © 2015 aidancbrady. All rights reserved.
//

import UIKit

class InitController: UIViewController {
    
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var downloadActivity: UIActivityIndicatorView!
    
    var notificationOpen: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.loadFavorites()
        
        downloadLabel.frame = CGRect(x: view.frame.maxX/2 - downloadLabel.frame.width/2, y: (view.frame.maxY/2 - downloadLabel.frame.height/2) - 8, width: downloadLabel.frame.width, height: downloadLabel.frame.height)
        downloadActivity.frame = CGRect(x: view.frame.maxX/2 - downloadActivity.frame.width/2, y: downloadLabel.frame.maxY + 8, width: downloadActivity.frame.width, height: downloadActivity.frame.height)
        
        downloadActivity.startAnimating()
        downloadActivity.hidesWhenStopped = true
        
        DispatchQueue.global(qos: .background).async {
            let success = DataManager.loadData()
            
            DispatchQueue.main.async {
                if !success {
                    ParkController.Parks.parkData.removeAll()
                    
                    self.downloadLabel.text = "Download failed."
                    self.downloadActivity.stopAnimating()
                } else {
                   self.performSegue(withIdentifier: "download_complete", sender: self)
                    
                    if let parkName = self.notificationOpen {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
                        let menuNavigation = self.presentedViewController as! MenuNavigation
                        
                        destController.parkName = parkName
                        
                        menuNavigation.pushViewController(destController, animated: true)
                        Utilities.loadPark(menuNavigation)
                        self.notificationOpen = nil
                    }
                }
            }
        }
    }
}

