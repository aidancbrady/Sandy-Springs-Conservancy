//
//  InitController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 7/7/15.
//  Copyright © 2015 aidancbrady. All rights reserved.
//

import UIKit

class InitController: UIViewController
{
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var downloadActivity: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Utilities.loadFavorites()
        
        downloadLabel.frame = CGRect(x: view.frame.maxX/2 - downloadLabel.frame.width/2, y: (view.frame.maxY/2 - downloadLabel.frame.height/2) - 8, width: downloadLabel.frame.width, height: downloadLabel.frame.height)
        downloadActivity.frame = CGRect(x: view.frame.maxX/2 - downloadActivity.frame.width/2, y: downloadLabel.frame.maxY + 8, width: downloadActivity.frame.width, height: downloadActivity.frame.height)
        
        downloadActivity.startAnimating()
        downloadActivity.hidesWhenStopped = true
        
        DispatchQueue.global(qos: .background).async {
            var errored = false
            
            if let url = URL(string: AppDelegate.DATA_URL + AppDelegate.DATA_FILE)
            {
                if let data = try? Data(contentsOf: url)
                {
                    do {
                        let raw: Any? = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        
                        if let top = raw as? NSDictionary
                        {
                            if let parks = top["parks"] as? NSArray
                            {
                                for obj in parks
                                {
                                    if let park = obj as? NSDictionary
                                    {
                                        ParkData.initPark(park)
                                    }
                                    else {
                                        errored = true
                                        break
                                    }
                                }
                            }
                            else {
                                errored = true
                            }
                        }
                        else {
                            errored = true
                        }
                    } catch {
                        errored = true
                    }
                }
                else {
                    errored = true
                }
            }
            else {
                errored = true
            }
            
            DispatchQueue.main.async {
                if errored
                {
                    ParkController.Parks.parkData.removeAll()
                    
                    self.downloadLabel.text = "Download failed."
                    self.downloadActivity.stopAnimating()
                }
                else {
                   self.performSegue(withIdentifier: "download_complete", sender: self)
                }
            }
        }
    }
}

