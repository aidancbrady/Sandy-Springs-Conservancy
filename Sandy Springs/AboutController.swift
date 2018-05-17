//
//  AboutController.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 5/16/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class AboutController: UIViewController
{
    @IBOutlet weak var textView: UITextView!
    
    static var html : NSAttributedString?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if AboutController.html == nil
        {
            AboutController.html = loadHTML()
        }
        
        if let htmlText = AboutController.html
        {
            textView.frame = CGRect(x: 5, y: 0, width: view.frame.width-10, height: view.frame.height)
            textView.attributedText = htmlText
            textView.isScrollEnabled = true
            textView.isEditable = false
            textView.contentMode = .scaleToFill
        }
    }
    
    func loadHTML() -> NSAttributedString?
    {
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
