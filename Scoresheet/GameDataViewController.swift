//
//  ViewController.swift
//  Scoresheet
//
//  Created by Trevor J. Stone on 7/20/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//
//

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


class GameDataViewController: UIViewController,
    UIPickerViewDataSource,
    UIPickerViewDelegate,
    UIScrollViewDelegate,
UITextViewDelegate {
    
    // Labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clubLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    
    // Stores the users name
    @IBOutlet weak var nameTF: UITextField!
    
    // Picker View for selecting which hockey club to use.
    @IBOutlet weak var clubPicker: UIPickerView!
    
    // Picker View for selecting which team "division" to use.
    @IBOutlet weak var teamPicker: UIPickerView!
    
    // Transitions to the GameIDViewController when a touch gesture is detected.
    @IBOutlet weak var doneButton: UIButton!
    
    // List of all clubs
    let clubs: Array<String> = ["Tri-Valley Blue Devils",
                                "Roseville Capital Thunder",
                                "Cupertino Cougars",
                                "Fresno Junior Monsters",
                                "Oakland Bears",
                                "Redwood City Black Stars",
                                "San Francisco Sabercats",
                                "San Jose Junior Sharks",
                                "Santa Clara Blackhawks",
                                "Santa Rosa Flyers",
                                "Lake Tahoe Grizzlies",
                                "Stockton Colts",
                                "Vacaville Jets",
                                "GSE Eagles"]
    
    // List of all team divisions
    let teams: Array<String> = ["MiteX",
                                "Squirt B", "Squirt A",
                                "Pee Wee B", "Pee Wee A",
                                "Bantam B", "Bantam A",
                                "Midget 16 B", "Midget 16 A",
                                "Midget 18 B", "Midget 18 A"]
    
    // Default selected club and team division
    var selectedClub: String = "Tri-Valley Blue Devils"
    var selectedTeam: String = "Mite A"
    
    let managedObjectContext =
        (UIApplication.shared.delegate
         as! AppDelegate).managedObjectContext
    
    // Contains GameData Object stored in core data
    var fetchResults: [GameData] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
    }
    
    // Initializes any UI objects in the view.
    func setUpUI() {
        
        nameTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                         for: UIControlEvents.editingChanged)
        
        doneButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(GameDataViewController.segueToGameIdView(_:))))
    }
    
    // Disables key board for user name text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        var gameData: GameData
        
        
        gameData = fetchGameData()
        
        gameData.setValue(self.nameTF.text, forKey: "userName")
        
        // Only one component in club picker so user component 0
        gameData.setValue(self.clubs[self.clubPicker.selectedRow(inComponent: 0)],
                          forKey: "clubName")
        
        // Only one component in team picker so user component 0
        gameData.setValue(self.teams[self.teamPicker.selectedRow(inComponent: 0)],
                          forKey: "teamDivision")
        
        // Save GameData fields
        do {
            try gameData.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
    
    // Called when the pictureButton is pressed.
    // Transitions to the CameraViewController if the user has entered a name.
    func segueToGameIdView(_ sender: UITapGestureRecognizer) {
        
        // Check that user entered text in name field
        if  nameTF.text?.characters.count > 0 {
            
            // Save user, club, and team to core data
            self.saveData()
            
            // Transition to GameIdViewController
            let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
            let vc = storyboard.instantiateViewController(
                     withIdentifier: "GameIdViewController") as! GameIdViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // Determines if the user typed in characters for their name.
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Check for text in name field
        if nameTF.text?.characters.count > 0 {
            doneButton.isEnabled = true
            doneButton.tintColor = UIColor.blue
            doneButton.backgroundColor = UIColor.lightGray
            
            // Saves the user's name, club, and team to core data
            self.saveData()
            
        }
        else {
            // Disable button
            doneButton.isEnabled = false
            doneButton.tintColor = UIColor.black
            doneButton.backgroundColor = UIColor.red
            
            let alert = UIAlertController(title: "Error",
                                          message: "Enter a name",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.default,
                                          handler: nil))
            self.present(alert, animated: true,
                                       completion: nil)
        }
    }
    
    // Sets the selected club or team for the corresponding UIPickerView
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        switch pickerView.restorationIdentifier! as String {
            
        case "clubPickerView":
            selectedClub = clubs[row]
            break
            
        case "teamPickerView":
            selectedTeam = teams[row]
            break
            
        default:
            print("Unrecognized picker view Restoration Identifier")
        }
    }
    
    // Determines the number of rows in the UIPickerView (pickerView)
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        // Club picker: number of elements in club array
        if pickerView.restorationIdentifier == "clubPickerView" {
            return clubs.count
        }
            // Team picker: number of elements in team array
        else if pickerView.restorationIdentifier == "teamPickerView" {
            return teams.count
        }
        
        return 1
    }
    
    
    // Determines number of seperate columns in the UIPickerView (pickerView).
    // We just need 1 column for both picker views.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Determines the text content for the given row (row) in the
    // UIPickerView (pickerView)
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        var text: String = ""
        
        if pickerView.restorationIdentifier == "clubPickerView" {
            text =  clubs[row]
        }
        else if pickerView.restorationIdentifier == "teamPickerView" {
            text = teams[row]
        }
        
        return text
    }
    
}

