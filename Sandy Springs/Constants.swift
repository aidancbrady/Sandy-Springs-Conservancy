//
//  Constants.swift
//  Sandy Springs
//
//  Created by Aidan Brady on 1/19/18.
//  Copyright © 2018 aidancbrady. All rights reserved.
//

import Foundation
import CoreLocation

class Constants
{
    // data file information
    static var DATA_URL = "http://server.aidancbrady.com/sandysprings/"
    static var DATA_FILE = "conservancy.json"
    static var DEV_EMAIL = "me@aidancbrady.com"
    
    // server information
    static var SPLITTER = ":"
    static var PORT = 26840
    static var IP = "server.aidancbrady.com"
    
    // last location recieved from location services
    static var LAST_LOCATION: CLLocation?
}
