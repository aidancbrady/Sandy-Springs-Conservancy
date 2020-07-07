//
//  WelcomeController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 2/21/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class WelcomeController: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactIcon: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewStretch = max(0, (view.frame.height/view.frame.width)-1.75)
        let startBoost = viewStretch*160
        var topPadding = UIApplication.shared.keyWindow!.safeAreaInsets.top
        
        if topPadding == 0 {
            topPadding = 16
        }
        
        //set up logo
        logoImage.frame = CGRect(x: view.frame.width/4, y: 48+startBoost, width: view.frame.width/2, height: view.frame.width/2)
        welcomeLabel.frame = CGRect(x: view.frame.minX, y: logoImage.frame.maxY + 16, width: view.frame.width, height: 40)
        menuLabel.frame = CGRect(x: view.frame.minX + 32, y: welcomeLabel.frame.maxY + 32, width: (view.frame.width*3/5)-32, height: 80)
        contactLabel.frame = CGRect(x: view.frame.minX + 32, y: menuLabel.frame.maxY + 24, width: (view.frame.width*3/5)-32, height: 80)
        
        menuIcon.frame = CGRect(x: view.frame.maxX - 32 - menuIcon.frame.width, y: menuLabel.frame.minY, width: menuIcon.frame.width, height: menuIcon.frame.height)
        menuIcon.image = menuIcon.image?.withRenderingMode(.alwaysTemplate)
        
        contactIcon.frame = CGRect(x: view.frame.maxX - 32 - menuIcon.frame.width + 10, y: contactLabel.frame.minY + 10, width: contactIcon.frame.width, height: contactIcon.frame.height)
        contactIcon.image = contactIcon.image?.withRenderingMode(.alwaysTemplate)
        
        dismissButton.frame = CGRect(x: view.frame.minX + 16, y: view.frame.maxY - 48 - 16 - 32 - viewStretch*80, width: view.frame.width - 32, height: 48)
        dismissButton.layer.cornerRadius = 10
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
