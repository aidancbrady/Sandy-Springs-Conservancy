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
    static var DATA_URL = "https://app.sandyspringsconservancy.org/"
    static var DATA_FILE = "conservancy.json"
    static var DEV_EMAIL = "me@aidancbrady.com"
    
    // sandy springs info
    static var WEBSITE = "https://www.sandyspringsconservancy.org"
    static var DONATE_SITE = "https://www.sandyspringsconservancy.org/waystodonate/"
    
    // last location recieved from location services
    static var LAST_LOCATION: CLLocation?
}
