//
//  ImageViewController.swift
//  Scoresheet
//
//  Created by Trevor J. Stone on 9/15/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageViewController : UIViewController {
    // Displays the image of the scoresheet
    @IBOutlet weak var imageView: UIImageView!
    
    // Initiates a CameraViewController when pressed
    @IBOutlet weak var retakeButton: UIButton!
    
    // Initiates an upViewController when pressed
    @IBOutlet weak var useButton: UIButton!
    
    // Used to access core data
    let managedObjectContext =
        (UIApplication.sharedApplication().delegate
            as! AppDelegate).managedObjectContext
    
    // Contains GameData Object stored in core data
    var fetchResults: [GameData] = []
    
    // Contains the game data in core data
    var gameData: GameData!
    
    // Contains constant values.
    let constants: Constants = Constants()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // gets the image of the scoresheet from core data
        gameData = fetchGameData()
        
        // display enlarged scoresheet image
        self.setUpZoomView()
        
        // set up ui buttons and the image view
        self.setUpUIButtons()
    }
    
    /*
       Calculate the dimensions of the image view to zoom in on the scoresheet image.
     
       let newOrigin: CGPoint = CGPoint(x: 0 - (self.constants.ZOOM_FACTOR / 2.0),
       y: 0 - (self.constants.ZOOM_FACTOR / 2.0))
     
       let newSize: CGSize = CGSize(width: self.view.bounds.width + self.constants.ZOOM_FACTOR ,
       height: self.view.bounds.height + self.constants.ZOOM_FACTOR)
     
       self.imageView.frame = CGRect(origin: newOrigin, size: newSize)

     */
    func setUpZoomView() {
        // Initialize the image view with the scoresheet image
        imageView.image = UIImage(data: gameData.image!, scale:1.0)
        
        // new origin for the image view
        let newOrigin: CGPoint = CGPoint(x: 0 - (self.constants.ZOOM_FACTOR / 2.0),
                                         y: 0 - (self.constants.ZOOM_FACTOR / 2.0))
        
        // new size of the image view frame
        let newSize: CGSize = CGSize(width: self.imageView.bounds.width + self.constants.ZOOM_FACTOR ,
                                     height: self.imageView.bounds.height + self.constants.ZOOM_FACTOR)
        
        // set the dimensions of the image view
        self.imageView.frame = CGRect(origin: newOrigin, size: newSize)
        
        
        // add image view to superview
        //self.view.addSubview(self.imageView)
    }
    
    // Adds gesture recognizers to the retake and use buttons.
    // Also sets the image for the
    func setUpUIButtons() {
        
        
        // add gesture recognizers to buttons
        retakeButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(ImageViewController.retakeButtonPressed(_:))))
        
        useButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(ImageViewController.useButtonPressed(_:))))
    }
    
    // Retrieves the users name, club, and team from core data.
    func fetchGameData() -> GameData {
        let fetchRequest = NSFetchRequest(entityName: "GameData")
        
        // Request access to GameData object from core data
        do {
            try fetchResults =
                (managedObjectContext.executeFetchRequest(fetchRequest)
                    as? [GameData])!
            //print(fetchResults)
        } catch {
            print("ERROR: Unable to access core data in GameIDViewController")
        }
        
        return fetchResults[0]
    }
    
    // Saves the image of the scoresheet to core data.
    func saveData() {
        let gameData: GameData = fetchGameData()
        
        // Only one component in team picker so user component 0
        gameData.setValue(self.imageView.image, forKey: "image")
        
        // Save GameData fields
        do {
            try gameData.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
    
    // Reinitializes a CameraViewController to retake the photo
    func retakeButtonPressed(sender: UITapGestureRecognizer) {
        // clear old image
        self.imageView.image = nil
        
        // Transition to CameraViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(
            "CameraViewController") as! CameraViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    // Transitions to the UploadViewController to send the scoresheet image to the server.
    func useButtonPressed(sender: UITapGestureRecognizer) {
        // Transition to UploadViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(
            "UploadViewController") as! UploadViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
