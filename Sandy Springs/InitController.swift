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
    @IBOutlet weak var retryButton: UIButton!
    
    var notificationOpen: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilities.loadFavorites()
        initiate()
    }
    
    func initiate() {
        retryButton.isHidden = true
        downloadLabel.text = "Downloading Park List..."
        progressView.setProgress(value: 0, animate: true)
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
                    self.onError()
                } else {
                    self.onSuccess()
                }
            }
        }
    }
    
    func onSuccess() {
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
    
    func onError() {
        Constants.parkData.removeAll()
        self.downloadLabel.text = "Download failed."
        self.retryButton.isHidden = false
        self.progressView.setProgress(value: 1, animate: true)
        if #available(iOS 13.0, *) {
            self.progressView.progressColor = UIColor.systemRed
        } else {
            self.progressView.progressColor = UIColor.red
        }
    }
    
    @IBAction func onRetryPressed(_ sender: Any) {
        initiate()
    }
    
    func progressCallback(progress: Double) {
        DispatchQueue.main.async {
            self.progressView.setProgress(value: Float(progress), animate: false)
        }
    }
}

