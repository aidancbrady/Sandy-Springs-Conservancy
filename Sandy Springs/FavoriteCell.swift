//
//  FavoriteCell.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 6/16/16.
//  Copyright © 2016 aidancbrady. All rights reserved.
//

import Foundation
import UIKit

class FavoriteCell: UITableViewCell
{
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var parkTitle: UILabel!
    
    override func didMoveToWindow()
    {
        let rect = CGRect(x: parkTitle.frame.minX, y: parkTitle.frame.minY, width: self.contentView.frame.maxX-parkTitle.frame.minX-5, height: parkTitle.frame.size.height)
        parkTitle.frame = rect
        (parkTitle as! MarqueeLabel).type = .leftRight
    }
}
