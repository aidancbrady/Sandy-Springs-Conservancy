//
//  InitController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 7/7/15.
//  Copyright © 2015 aidancbrady. All rights reserved.
//

import UIKit

class InitController: UIViewController, DataManagerDelegate {
    
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressView!
    
    var notificationOpen: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.loadFavorites()
        
        downloadLabel.frame = CGRect(x: view.frame.maxX/2 - downloadLabel.frame.width/2, y: (view.frame.maxY/2 - downloadLabel.frame.height/2) - 8, width: downloadLabel.frame.width, height: downloadLabel.frame.height)
        
        progressView.progressColor = view.tintColor
        if #available(iOS 13.0, *) {
            progressView.trackColor = UIColor.secondarySystemBackground
        } else {
            progressView.trackColor = UIColor.gray
        }
        
        DispatchQueue.global(qos: .background).async {
            let success = DataManager(delegate: self).loadData()
            
            DispatchQueue.main.async {
                if !success {
                    Constants.parkData.removeAll()
                    
                    self.downloadLabel.text = "Download failed."
                } else {
                    AppDelegate.getInstance().initLocationServices()
                    self.performSegue(withIdentifier: "download_complete", sender: self)
                    
                    if let parkName = self.notificationOpen {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let destController = mainStoryboard.instantiateViewController(withIdentifier: "ParkController") as! ParkController
                        let menuNavigation = self.presentedViewController as! MenuNavigation
                        
                        destController.parkName = parkName
                        
                        menuNavigation.present(destController)
                        Utilities.loadPark(menuNavigation)
                        self.notificationOpen = nil
                    }
                }
            }
        }
    }
    
    func progressCallback(progress: Double) {
        DispatchQueue.main.async {
            self.progressView.setProgress(duration: 0, value: Float(progress))
        }
    }
}

