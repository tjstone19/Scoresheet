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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameIdViewController: UIViewController, UITextViewDelegate {
    
    // Text field that stores the game id
    @IBOutlet weak var idTF: UITextField!
    
    // Transitions to the CameraView when a touch gesture is detected
    @IBOutlet weak var cameraButton: UIButton!
    
   
    
    // Used to access core data
    let managedObjectContext =
        (UIApplication.shared.delegate
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
    
  
    // Retrieves the GameData object from core data
    // If a GameData object is not already instanciated, a new GameData
    // object will be created
    func fetchGameData() -> GameData {
        let fetchRequest: NSFetchRequest<GameData> = NSFetchRequest(entityName: "GameData")
        var gameData: GameData
        
        // Request access to GameData object from core data
        do {
            try fetchResults =
                (managedObjectContext.fetch(fetchRequest)
                    as [GameData])
            //print(fetchResults)
        } catch {
            print("ERROR: Unable to access core data in GameIDViewController")
        }
        
        // Create a GameData object in core data if one does not exist
        if (fetchResults.count == 0) {
            
            // Used to save the user's name, club name, and team division to core data
            gameData = NSEntityDescription.insertNewObject(
                forEntityName: "GameData", into: managedObjectContext)
                as! GameData
        }
        else {
            // GameData object already created in core data
            gameData = fetchResults[0]
        }
        
        return gameData
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
                       for: UIControlEvents.editingChanged)
        
        cameraButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
            action:#selector(GameIdViewController.takePicture(_:))))
        
        idTF.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
        /*var ret: Bool = false
        
        // Check for text in name field
        if idTF.text?.characters.count == self.constants.GAME_ID_LENGTH {
            // bring down keyboard since input is finished
            ret = true
        }
        
        return ret*/
    }
    
    // Determines if the user typed in characters for the game ID.
    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.saveData()
        
        // Delete last character if it is grater than the allowed game ID length
        if idTF.text?.characters.count > self.constants.GAME_ID_LENGTH {
            idTF.deleteBackward()
        }
    }
    
    // Called when the pictureButton is pressed.
    // Transitions to the CameraViewController if the user has entered a name.
    func takePicture(_ sender: UITapGestureRecognizer) {
        
        // Check that user entered text in game id text field
        if  idTF.text?.characters.count == self.constants.GAME_ID_LENGTH {
            
            // Save Game ID to core data
            self.saveData()
            
            // Transition to CameraViewController
            let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "CameraViewController") as! CameraViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
}
