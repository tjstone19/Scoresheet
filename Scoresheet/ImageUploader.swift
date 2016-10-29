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
    
    // NORCAL game ID
    var gameId: String
    
    // when upload is complete, cameraVc's seguetohomescreen method is called
    var uploadVC: UploadViewController
    
    // Contains constant values for entire program
    let constants: Constants = Constants()
    
    
    // Initializes an ImageUploader object with the given parameters
    init(uploadVC: UploadViewController, image: UIImage, game: String) {
        
        self.uploadPic = image
        self.gameId = game
        self.uploadVC = uploadVC
        
        param.updateValue(self.gameId, forKey: "game_number")
        print(param)
    }
    
    // Called when a response is received from the Server indicating upload completion.
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
                        didReceiveResponse response: NSURLResponse,
                        completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        print("Response")
        print(response)
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
            self.uploadVC.setUploadProgress(uploadProgress, percent: progressPercent)
        });
    }
    
    
    
    // Called when the upload session ends with an error.
    // Prints an error message to the user.
    func URLSession(session: NSURLSession, task: NSURLSessionTask,
                    didCompleteWithError error: NSError?) {
        
        dispatch_async(dispatch_get_main_queue(),{
            self.uploadVC.uploadFail((error?.localizedDescription)!)
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
        let config = NSURLSession.sharedSession().configuration
        
        
        //let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // Create URLSession with our configuration and this ImageUploader as the session's delegate.
        // Once the session is created it begins running in new thread.
        let session = NSURLSession(configuration: config,
                                   delegate: self,
                                   delegateQueue: NSOperationQueue.mainQueue())
        
        //let task = session.uploadTaskWithRequest(request, fromData: imageData!) {
        let task = session.dataTaskWithRequest(request) {
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
            
            // Check if scoresheet was accepted
            if responseString!.containsString(self.constants.SCORESHEET_ACCEPTED) {
                dispatch_async(dispatch_get_main_queue(),{
                    self.uploadVC.uploadSuccess()
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(),{
                    self.uploadVC.uploadFail(self.constants.UPLOAD_FAIL_MESSAGE)
                });
            }
        }

        task.resume()
        
        
        /* 
         789AA1
         789AB1
         789AC1
         789AD1
         789AE1
         789AF1
         789AG1
         789AH1
         789AI1
         789AJ1
        */
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




