//
//  OperationsManager.swift
//  VocabCrack-iOS
//
//  Created by aidancbrady on 12/3/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

struct Operations
{
    static var currentOperations = 0
    
    static func setNetworkActivity(_ activity:Bool)
    {
        if activity
        {
            currentOperations += 1
        }
        else {
            currentOperations -= 1
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = currentOperations > 0
        }
    }
}
