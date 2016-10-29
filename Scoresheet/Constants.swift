//
//  Constants.swift
//  Scoresheet
//
//  Created by Trevor J. Stone on 8/2/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//

import Foundation
import UIKit

class Constants: NSObject {
    let GAME_ID_LENGTH: Int = 6
    
    let ZOOM_FACTOR: CGFloat = 1000.0
    
    let UPLOAD_URL: String = "http://stats.caha.timetoscore.com/submit-scoresheet.php"
    
    let FILE_KEY: String = "scoresheet_file"
    
    let SCORESHEET_ACCEPTED: String = "Scoresheet Accepted"
    
    let UPLOAD_FAIL_MESSAGE: String = "Invalid Game Number (Nonexistant, or in the Future)"
    
    let UPLOAD_SUCCESS: String = "Scoresheet Sent Successfully!"
    
    let NORCAL_POLICY: String = "Hard copies of scoresheets may still need to be mailed to NORCAL. Check NORCAL's policies."
    
}
