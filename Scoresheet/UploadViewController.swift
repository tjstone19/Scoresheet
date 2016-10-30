//
//  UploadViewController.swift
//  Scoresheet
//
//  Created by Trevor J. Stone on 9/17/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UploadViewController: UIViewController {
    
    @IBOutlet weak var sendingLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    // Used to access core data.
    let managedObjectContext =
        (UIApplication.shared.delegate
            as! AppDelegate).managedObjectContext
    
    // Contains GameData Object stored in core data.
    var fetchResults: [GameData] = []
    
    // Contains the game data in core data.
    var gameData: GameData!
    
    // The image to be uploaded.
    var image: UIImage = UIImage()
    
    // Constant values.
    let constants: Constants = Constants()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve GameData from CoreData
        gameData = fetchGameData()
        
        setUpUI()
        
        // upload scoresheet image
        startUpload()
    }
    
    /*
        Initializes UI elements.
     */
    func setUpUI() {
        sendingLabel.text = "Sending..."
        
        progressBar.progress = 0
        progressLabel.text = "0%"
        
        // Add tap gesture recognizers to each button
        resendButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(UploadViewController.resendButtonPressed(_:))))
        
        doneButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(UploadViewController.doneButtonPressed(_:))))
        
        // hide buttons during image upload
        resendButton.isHidden = true
        resendButton.isEnabled = false
        doneButton.isHidden = true
        doneButton.isEnabled = false
        
        resultLabel.isHidden = true
        resultLabel.isEnabled = false
        
        // display progress bar and label during image upload
        progressLabel.isHidden = false
        progressLabel.isEnabled = true
        progressBar.isHidden = false
    }
    
    /* 
        Attempts to upload the image after an unsuccessful attempt.
     */
    func resendButtonPressed(_ sender: UITapGestureRecognizer) {
        setUpUI()
        startUpload()
    }
    
    /*
        Transitions to home screen (GameIdViewController).
     */
    func doneButtonPressed(_ sender: UITapGestureRecognizer) {
        segueToHomeScreen()
    }
    
    /* 
       Initiates an ImageUploader object and begins uploading the scoresheet to the server.
     */
    func startUpload() {
        // uploads the scoresheet image to the server
        let uploader: ImageUploader!
        
        // check if the game data object contains an image
        if gameData.image != nil {
            // Get the image from the GameData Object
            image = UIImage(data: gameData.image! as Data, scale:1.0)!
            
            uploader = ImageUploader(uploadVC: self,
                                     image: image,
                                     game: gameData.gameId!)
            
            // begin upload
            uploader.uploadImageToServer()
        }
        else {
            print("ERROR: Image was nil when trying to upload scoresheet image")
        }

    }
    
    // Retrieves the users name, club, and team from core data.
    func fetchGameData() -> GameData {
        let fetchRequest: NSFetchRequest<GameData> = NSFetchRequest(entityName: "GameData")
        
        // Request access to GameData object from core data
        do {
            try fetchResults =
                (managedObjectContext.fetch(fetchRequest)
                    as [GameData])
        } catch {
            print("ERROR: Unable to access core data in CameraViewController")
        }
        
        return fetchResults[0]
    }
    
    /*
       Transitions to home screen (GameIdViewController).
     */
    func segueToHomeScreen() {
        // Transition to GameIdViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "GameIdViewController") as! GameIdViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    /* 
       Updates the progress bar and progress labels values.
     */
    func setUploadProgress(_ progress: Float, percent: Int) {
        progressBar.progress = progress
        progressLabel.text = "\(percent)%"
    }
    
    /* 
       Called when an error was encountered while uploading the image.
       Presents error message to the user.
    */
    func uploadFail(_ errorMessage: String) {
        sendingLabel.text = "UPLOAD ERROR"
        
        hideProgress()
        
        // show done and retake buttons
        doneButton.isEnabled = true
        doneButton.isHidden = false
        resendButton.isEnabled = true
        resendButton.isHidden = false
        
        // notify user of successful upload
        resultLabel.isHidden = false
        resultLabel.isEnabled = true
        resultLabel.text = errorMessage
    }

    /*
       Called when the upload has completed successfully.
     */
    func uploadSuccess() {
        sendingLabel.text = "SUCCESS"
        
        // hide progress bar and label
        hideProgress()
        
        // only show done button since the upload was successful
        doneButton.isEnabled = true
        doneButton.isHidden = false
        
        // notify user of successful upload
        resultLabel.isHidden = false
        resultLabel.isEnabled = true
        resultLabel.text = constants.UPLOAD_SUCCESS
    }
    
    /*
       Hides the progress label and bar.
     */
    func hideProgress() {
        // hide progress bar and label
        progressLabel.isHidden = true
        progressLabel.isEnabled = false
        progressBar.isHidden = true
    }
}
