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
        
        menuIcon.image = menuIcon.image?.withRenderingMode(.alwaysTemplate)
        contactIcon.image = contactIcon.image?.withRenderingMode(.alwaysTemplate)
        
        dismissButton.layer.cornerRadius = 10
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
