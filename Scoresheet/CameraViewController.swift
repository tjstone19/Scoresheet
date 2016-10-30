//  Parker Stone
//  TJ Stone
//  CameraViewController.swift
//  cameraTest
//
//
//  Created by Trevor J. Stone on 7/15/16.
//  Copyright © 2016 Trevor J. Stone. All rights reserved.
//
import UIKit
import CoreData
import AVFoundation

class CameraViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // picture captured from camera
    let stillImageOutput = AVCaptureStillImageOutput()
    
    // back camera
    var backCamera : AVCaptureDevice?
    
    
    // Transitions to GameIdViewController when pressed
    @IBOutlet weak var backButton: UIButton!
    
    // Takes a photo when pressed.
    @IBOutlet weak var photoButton: UIButton!
    
    // Picture taken by the user
    var image: UIImage = UIImage()
    
    // Displays what the back camera "sees"
    var cameraPreview = UIView()
    
    // Used to access core data
    let managedObjectContext =
        (UIApplication.shared.delegate
            as! AppDelegate).managedObjectContext
    
    // Contains GameData Object stored in core data
    var fetchResults: [GameData] = []
    
    // Contains the game data in core data
    var gameData: GameData!
    
    // Application constant values
    let constants: Constants = Constants()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up ui buttons
        self.setUpUI()
        
        // configure AVCaptureSession for camera
        self.setUpCaptureSession()
        
        // Retrieve GameData from CoreData
        gameData = fetchGameData()
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
    
    // Saves the image of the scoresheet to core data.
    func saveData() {
        let imageData: Data = UIImageJPEGRepresentation(self.image, 1)!
        
        // Only one component in team picker so user component 0
        gameData.setValue(imageData, forKey: "image")
        
        // Save GameData fields
        do {
            try gameData.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }

    
    // Sets up the AVCaptureSession to take the picture.
    func setUpCaptureSession() {
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                    backCamera = device as? AVCaptureDevice
                    if backCamera != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }
    
    // Initializes UI Objects
    func setUpUI() {
        // Add tap gesture recognizers to each button
        backButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(CameraViewController.backButtonPressed(_:))))
        
        // Convers entire view which allows users to tap screen anywhere to take a picture
        photoButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(CameraViewController.takePhoto(_:))))
    }
    
    
    // Initializes a GameDataViewController after a response from the server has been received
    func segueToHomeScreen() {
        // Transition to GameIdViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "GameIdViewController") as! GameIdViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    // Removes input sources to captureSession
    func clearAVCaptureDeviceInputs() {
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
    }
    
    // Called when the back button is pressed.
    // Transitions back to the game id view controller.
    func backButtonPressed(_ sender: UITapGestureRecognizer) {
        segueToHomeScreen()
    }
    
    // Sets the back cameras focus mode to "Locked"
    func configureDevice() {
        do {
            
            let device = backCamera
            
            // Set focus mode to continously focus on the content in the center of the camera
            let focusMode:AVCaptureFocusMode =
                AVCaptureFocusMode.continuousAutoFocus
            
            // Lock back camera for configuration
            // (Must have lock on the camera before you can alter the focus mode)
            try device?.lockForConfiguration()
            
            // Check if the camera supports focus mode
            if device!.isFocusModeSupported(focusMode) {
                
                device!.focusMode = focusMode
                
            }
            // Unlock device since we finished configuring the camera and want to allow for
            // future alterations to the back camera's configuration
            device!.unlockForConfiguration()
            
        } catch {
            print(error)
        }
    }
    
    // Sets up the camera view.
    func beginSession() {
        
        // Configure back camera's focus mode
        configureDevice()
        
        do {
            // Add back camera as input to the AVCaptureSession
            try captureSession.addInput(AVCaptureDeviceInput(device: backCamera))
        } catch {
            print(error)
        }
        
        // Use photo preset: allows for full resolution photo quality output
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Start the capture session
        captureSession.startRunning()
        
        // Set image type to jpeg
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        // Check if the capture session can add an AVCaptureOutput
        if captureSession.canAddOutput(stillImageOutput) {
            // Add an AVCaptureStillImageOutput object to the capture session which will
            // store the image of the scoresheet.
            captureSession.addOutput(stillImageOutput)
        }
        
        // initialize the AVCapturePreviewLayer to display what the back camera "sees"
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            cameraPreview = UIView(
                frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width,
                    height: view.bounds.size.height))
            
            cameraPreview.layer.addSublayer(previewLayer)
            
            
            // add back button to camera view
            cameraPreview.addSubview(backButton)
            
            // add photo button to camera view
            
            photoButton.center = cameraPreview.center
            
            photoButton.frame = CGRect(x: cameraPreview.center.x,
                                       y: cameraPreview.center.y,
                                       width: photoButton.frame.width,
                                       height: photoButton.frame.height)
            
            cameraPreview.addSubview(photoButton)
           
            
            // add the camera view onto the main view
            view.addSubview(cameraPreview)
            
        }
    }
    
    
    /* 
       Called when the user taps the screen.
       Takes a picture then transitions to the ImageViewController.
     */
    func takePhoto(_ sender: UITapGestureRecognizer) {
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                // Convert image to jpeg
                let imageData =
                    AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                // Initialize imageview with the jpeg image
                self.image = UIImage(data: imageData!)!
                
                // Save image to core data
                self.saveData()
                
                // Transition to ImageViewController
                self.segueToImageVC()
            }
        }
    }
    
    /*
     Initializes an ImageViewController
     */
    func segueToImageVC() {
        // Transition to CameraViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "ImageViewController") as! ImageViewController
        self.present(vc, animated: true, completion: nil)
    }
}

