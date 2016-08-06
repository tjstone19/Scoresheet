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
    
    @IBOutlet weak var backButton: UIButton!
    
    // Used to access core data
    let managedObjectContext =
        (UIApplication.sharedApplication().delegate
            as! AppDelegate).managedObjectContext
    
    // Contains GameData Object stored in core data
    var fetchResults: [GameData] = []
    
    // Contains the game data in core data
    var gameData: GameData!
    
    // Contains constant values for application
    var constants: Constants = Constants()

    
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
            //print(fetchResults)
        } catch {
            print("ERROR: Unable to access core data in GameIDViewController")
        }
        
        return fetchResults[0]
    }
    
    // Saves the user's name, club name, and team division to core data.
    func saveData() {
        let gameData: GameData = fetchGameData()
        
        // Only one component in team picker so user component 0
        gameData.setValue(self.idTF.text, forKey: "gameId")
        
        // Save GameData fields
        do {
            try gameData.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }

    // Initializes UI Objects
    func setUpUI() {
        idTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                       forControlEvents: UIControlEvents.EditingChanged)
        
        cameraButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
            action:#selector(GameIdViewController.takePicture(_:))))
        
        backButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(GameIdViewController.backButtonPressed(_:))))
        
        idTF.text = gameData.gameId
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
        if idTF.text?.characters.count == 8 {
            cameraButton.enabled = true
            cameraButton.tintColor = UIColor.blueColor()
            cameraButton.backgroundColor = UIColor.lightGrayColor()
            
            self.saveData()
        }
    }
    
    // Called when the back button is pressed.
    // Transitions back to the game data view controller.
    func backButtonPressed(sender: UITapGestureRecognizer) {
        self.saveData()
        
        // Transition to GameIdViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(
            "GameDataViewController") as! GameDataViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    // Called when the pictureButton is pressed.
    // Transitions to the CameraViewController if the user has entered a name.
    func takePicture(sender: UITapGestureRecognizer) {
        
        // Check that user entered text in game id text field
        if  idTF.text?.characters.count == self.constants.GAME_ID_LENGTH {
            
            // Save Game ID to core data
            self.saveData()
            
            // Transition to CameraViewController
            let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(
                "CameraViewController") as! CameraViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }
}