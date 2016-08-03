//
//  GameIdViewController.swift
//  Scoresheet
//
//  Created by Trevor J. Stone on 7/27/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GameIdViewController: UIViewController, UITextViewDelegate {
    
    // Text field that stores the game id
    @IBOutlet weak var idTF: UITextField!
    
    // Transitions to the CameraView when a touch gesture is detected
    @IBOutlet weak var cameraButton: UIButton!
    
    // Name label
    @IBOutlet weak var nameL: UILabel!
    
    // Club label
    @IBOutlet weak var clubL: UILabel!
    
    // Team label
    @IBOutlet weak var teamL: UILabel!
    
    // Used to access core data
    let managedObjectContext =
        (UIApplication.sharedApplication().delegate
            as! AppDelegate).managedObjectContext
    
    // Contains GameData Object stored in core data
    var fetchResults: [GameData] = []
    
    // Contains the game data in core data
    var gameData: GameData!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameData = self.fetchGameData()
        
        self.setUpUI()
    }
    
    // Retrieves the users name, club, and team from core data.
    func fetchGameData() -> GameData {
        let fetchRequest = NSFetchRequest(entityName: "GameData")
        
        // Request access to GameData object from core data
        do {
            try fetchResults =
                (managedObjectContext.executeFetchRequest(fetchRequest)
                    as? [GameData])!
            print(fetchResults)
        } catch {
            print("ERROR: Unable to access core data in GameIDViewController")
        }
        
        return fetchResults[0]
    }

    // Initializes UI Objects
    func setUpUI() {
        self.nameL.text = gameData.valueForKey("userName") as? String
        self.clubL.text = gameData.valueForKey("clubName") as? String
        self.teamL.text = gameData.valueForKey("teamDivision") as? String
        
        idTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                       forControlEvents: UIControlEvents.EditingChanged)
        
        cameraButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
            action:#selector(GameIdViewController.takePicture(_:))))
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Determines if the user typed in characters for the game ID.
    func textFieldDidChange(textField: UITextField) {
        // Check for text in name field
        if idTF.text?.characters.count >= 8 {
            cameraButton.enabled = true
            cameraButton.tintColor = UIColor.blueColor()
            cameraButton.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    // Called when the pictureButton is pressed.
    // Transitions to the CameraViewController if the user has entered a name.
    func takePicture(sender: UITapGestureRecognizer) {
        
        // Check that user entered text in game id text field
        if  idTF.text?.characters.count > 0 {
            
            // TODO: Save Game ID to core data
            
            // Transition to CameraViewController
            let cameraVC:CameraViewController = CameraViewController()
            self.presentViewController(cameraVC, animated: true, completion: nil)
            
        }
    }
}