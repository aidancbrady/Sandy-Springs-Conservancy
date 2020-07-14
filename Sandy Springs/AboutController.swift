//
//  AboutController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 5/16/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class AboutController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    static var html : NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show nav bar
        navigationController!.navigationBar.isHidden = false
        
        if AboutController.html == nil {
            AboutController.html = loadHTML()
        }
        
        let top = 50 + UIApplication.shared.keyWindow!.safeAreaInsets.top
        let image = UIImageView(image: UIImage(named: "logo_alpha.png"))
        let size = self.view.frame.width/3
        image.frame = CGRect(x: self.view.frame.width / 2 - size / 2, y: top + 15, width: size, height: size)
        self.view.addSubview(image)
        
        if let htmlText = AboutController.html {
            textView.frame = CGRect(x: 5, y: image.frame.maxY + 15, width: view.frame.width-10, height: view.frame.height - (image.frame.maxY + 15))
            textView.attributedText = htmlText
            textView.isScrollEnabled = true
            textView.isEditable = false
            textView.contentMode = .scaleToFill
            textView.textColor = isDark() ? UIColor.white : UIColor.black
        }
    }
    
    func isDark() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
    
    func loadHTML() -> NSAttributedString? {
        if let url = Bundle.main.url(forResource: "about", withExtension: "html") {
            do {
                let data = try Data(contentsOf: url)
                return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}
