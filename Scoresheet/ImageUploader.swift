//
//  ViewController.swift
//  ImageUploadTest
//
//  Created by Parker Stone on 8/8/16.
//  Copyright © 2016 William Stone. All rights reserved.
//

import UIKit

class ImageUploader: NSObject,
                     NSURLSessionDelegate,
                     NSURLSessionTaskDelegate,
                     NSURLSessionDataDelegate {
    
    // Parameters for the HTTP Request
    var param = [
        "game_number" : "",
        "scoresheet_file" : "ScoresheetPic.jpeg",
        "submitsheet" : "Submit"
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
    
    // when upload is complete, cameraVc's seguetohomescreen method is called
    var cameraVc: CameraViewController
    
    // Contains constant values for entire program
    let constants: Constants = Constants()
    
    
    // Initializes an ImageUploader object with the given parameters
    init(cameraVC: CameraViewController, image: UIImage, name: String,
         club: String, team: String, game: String) {
        
        self.uploadPic = image
        self.userName = name
        self.clubName = club
        self.teamDivision = team
        self.gameId = game
        self.cameraVc = cameraVC
        
        param.updateValue(self.gameId, forKey: "game_number")
        param.updateValue(self.userName, forKey: "username")
        param.updateValue(self.clubName, forKey: "clubname")
        param.updateValue(self.teamDivision, forKey: "teamdivision")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    // Called when a response is received from the Server indicating upload completion.
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
                        didReceiveResponse response: NSURLResponse,
                        completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        print("Upload Complete Resopnse Received")
        
        // Transition to home screen
        dispatch_async(dispatch_get_main_queue(),{
             self.cameraVc.segueToHomeScreen()
        });
    }
    
    // Called when |bytesSent| amount of the image data has been sent to the server
    // Total progress is |bytesSent| / |totalBytesExpectedToSend|
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        // calculate total progress
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        
        // convert percentage to integer
        let progressPercent = Int(uploadProgress*100)
        
        // Update camera view controller on the upload progress
        dispatch_async(dispatch_get_main_queue(),{
            self.cameraVc.setUploadProgress(uploadProgress, percent: progressPercent)
        });
    }
    
    
    // Called when the upload session ends with an error.
    // Prints an error message to the user.
    func URLSession(session: NSURLSession, task: NSURLSessionTask,
                    didCompleteWithError error: NSError?) {
        
        dispatch_async(dispatch_get_main_queue(),{
            self.cameraVc.uploadError((error?.localizedDescription)!)
        });
    }
    
    
    // Uploads the scoresheet jpeg image to the server.
    func uploadImageToServer()
    {
        let myUrl = NSURL(string: constants.UPLOAD_URL)
        
        // new HttpPostTask(this, Constants.NORCAL_SUBMIT_URL, file, gameNum,
        
        // Prepare request
        var request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        
        // Convert to image to jpeg
        let imageData = UIImageJPEGRepresentation(self.uploadPic, 1.0)
        
        // Make sure image conversion succeeded
        if(imageData==nil)  { return; }
        
        // Create http request with our parameters and image
        request.HTTPBody = createBodyWithParameters(param,
                                                    filePathKey: constants.FILE_KEY,
                                                    imageDataKey: imageData!,
                                                    boundary: boundary)
        
        // Use URL defualt configuration
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Create URLSession with our configuration and this ImageUploader as the session's delegate.
        // Once the session is created it begins running in new thread.
        let session = NSURLSession(configuration: configuration,
                                   delegate: self,
                                   delegateQueue: NSOperationQueue.mainQueue())
        
        let task = session.uploadTaskWithRequest(request, fromData: imageData!)
        task.resume()
        
        /*
        // Send http request
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
                
                // Call CameraViewController's segue to home screen method in the main thread
                // after parsing server response
                dispatch_async(dispatch_get_main_queue(),{
                   // self.cameraVc.segueToHomeScreen()
                });
                
            } catch {
                print("ERROR converting server response to JSON")
                
                // Call CameraViewController's segue to home screen method in the main thread
                // after parsing server response
                dispatch_async(dispatch_get_main_queue(),{
                   // self.cameraVc.segueToHomeScreen()
                });
            }
        }
        task.resume()*/
    }
    
    // Creates the body of the HTTP request with |parameters| and the scoresheet image |imageDataKey|.
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
    
    // Creates boundary string for HTTP request
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}


// Extension of NSMutableData that enables strings to be encoded appended 
// and appended to the HTTP request
extension NSMutableData {
    
    // Converts |string| using NSUTF8StringEncoding and then appends the result
    // to the end of the HTTP request
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding,
                                            allowLossyConversion: true)
        appendData(data!)
    }
}




