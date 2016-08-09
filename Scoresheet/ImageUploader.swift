//
//  ViewController.swift
//  ImageUploadTest
//
//  Created by Parker Stone on 8/8/16.
//  Copyright © 2016 William Stone. All rights reserved.
//

import UIKit

class ImageUploader: NSObject {
    
    // Parameters for the HTTP Request
    var param = [
        "game_number"  : "",
        "scoresheet_file"    : "ScoresheetPic.jpeg",
        "submitsheet"    : "Submit"
    ]
    
    // Contains the picture of the scoresheet to be uploaded
    var uploadPic: UIImage
    
    // Name of the user
    var userName: String
    
    // Name of the user's club
    var clubName: String
    
    // Division of the user's team
    var teamDivision: String
    
    // NORCAL game ID
    var gameId: String
    
    // Contains constant values for entire program
    let constants: Constants = Constants()
    
    // Initializes an ImageUploader object with the given parameters
    init(image: UIImage, name: String, club: String, team: String, game: String) {
        self.uploadPic = image
        self.userName = name
        self.clubName = club
        self.teamDivision = team
        self.gameId = game
        
        param.updateValue(self.gameId, forKey: "game_number")
        
        param.updateValue(self.userName, forKey: "username")
        param.updateValue(self.clubName, forKey: "clubname")
        param.updateValue(self.teamDivision, forKey: "teamdivision")
    }
    
    func uploadImageToServer()
    {
        let myUrl = NSURL(string: constants.UPLOAD_URL)
        
        // new HttpPostTask(this, Constants.NORCAL_SUBMIT_URL, file, gameNum,
        
        var request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(self.uploadPic, 1.0)
        
        if(imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(param,
                                                    filePathKey: constants.FILE_KEY,
                                                    imageDataKey: imageData!,
                                                    boundary: boundary)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            
            
            do {
                var json = try NSJSONSerialization.JSONObjectWithData(data!,
                                                                      options: .MutableContainers) as? NSDictionary
                
            } catch {
                print("ERROR converting server response to JSON")
            }
        }
        
        task.resume()
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpeg"
        
        let mimetype = "image/jpeg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}



extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding,
                                            allowLossyConversion: true)
        appendData(data!)
    }
}




