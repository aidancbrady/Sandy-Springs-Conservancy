//
//  ParkCell.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 1/19/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class ParkCell: UITableViewCell
{
    @IBOutlet weak var parkImage: UIImageView!
    @IBOutlet weak var parkName: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func didMoveToWindow()
    {
        let rect = CGRect(x: parkName.frame.minX, y: parkName.frame.minY, width: self.superview!.frame.maxX-parkName.frame.minX-5, height: parkName.frame.size.height)
        parkName.frame = rect
        (parkName as! MarqueeLabel).type = .leftRight
    }
}
