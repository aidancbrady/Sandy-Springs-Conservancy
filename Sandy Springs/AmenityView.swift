//
//  AmenityView.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 7/14/20.
//  Copyright © 2020 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class AmenityView: UIView {
    var amenityName: String!
    
    var imageView: UIImageView!
    var amenityLabel: UILabel!
    
    var frameSize = 110
    var imageSize = 45
    
    init(amenityName: String, xPos: Int, yPos: Int) {
        super.init(frame: CGRect(x: xPos, y: yPos, width: frameSize, height: frameSize))
        self.amenityName = amenityName
        
        imageView = UIImageView(frame: CGRect(x: (frameSize / 2) - (imageSize / 2), y: 20, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: Utilities.formatAmenity(self.amenityName))?.withRenderingMode(.alwaysTemplate)
        addSubview(imageView)
        let yStart = Int(imageView.frame.maxY)
        amenityLabel = UILabel(frame: CGRect(x: 0, y: yStart, width: frameSize, height: 30))
        amenityLabel.numberOfLines = 0
        amenityLabel.text = amenityName
        amenityLabel.textAlignment = NSTextAlignment.center
        amenityLabel.font = UIFont.systemFont(ofSize: 15)
        self.layer.cornerRadius = 8
        addSubview(amenityLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
