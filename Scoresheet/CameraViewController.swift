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
    
    // Retakes a picture when pressed
    @IBOutlet weak var retakeButton: UIButton!
    
    // Sends the picture to the server when pressed
    @IBOutlet weak var okButton: UIButton!
    
    // Transitions to GameIdViewController when pressed
    @IBOutlet weak var backButton: UIButton!
    
    // Picture taken by the user
    var image: UIImage = UIImage()
    
    // Displays what the back camera "sees"
    var cameraPreview = UIView()
    
    // Calls show photo method when a tap is detected
    var pictureGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
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
        
        // set up ui buttons
        self.setUpUI()
        
        // configure AVCaptureSession for camera
        self.setUpCaptureSession()
        
        // Retrieve GameData from CoreData
        gameData = fetchGameData()
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
    

    
    
    // Sets up the AVCaptureSession to take the picture.
    func setUpCaptureSession() {
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
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
        
        retakeButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(CameraViewController.retakeButtonPressed(_:))))
        
        okButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                action:#selector(CameraViewController.okButtonPressed(_:))))
        
        self.pictureGesture =
            UITapGestureRecognizer(target: self,
                                   action:#selector(CameraViewController.showPhoto(_:)))
        
        toggleButtonVisibility()
    }
    
    // Toggles back button and ok button visibility
    func toggleButtonVisibility() {
        //backButton.hidden = !backButton.hidden
        //backButton.enabled = !backButton.enabled
        retakeButton.hidden = !retakeButton.hidden
        retakeButton.enabled = !retakeButton.enabled
        okButton.hidden = !okButton.hidden
        okButton.enabled = !okButton.enabled
    }
    
    // Initializes a GameDataViewController
    func segueToHomeScreen() {
        // Transition to GameIdViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(
            "GameIdViewController") as! GameIdViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    // Sends the photo to the server.
    func okButtonPressed(sender: UITapGestureRecognizer) {
        // TODO: Send photo to server
        let uploader = ImageUploader(image: self.image,
                                     name: gameData.userName!,
                                     club: gameData.clubName!,
                                     team: gameData.teamDivision!,
                                     game: gameData.gameId!)
        
        uploader.uploadImageToServer()
        
        self.segueToHomeScreen()
    }
    
    // Removes input sources to captureSession
    func clearAVCaptureDeviceInputs() {
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
    }
    
    // Reinitializes the capture session to take another picture
    func retakeButtonPressed(sender: UITapGestureRecognizer) {
        self.captureSession.stopRunning()
        self.clearAVCaptureDeviceInputs()
        self.viewDidLoad()
    }
    
    // Called when the back button is pressed.
    // Transitions back to the game id view controller.
    func backButtonPressed(sender: UITapGestureRecognizer) {
    
        // Transition to GameIdViewController
        let storyboard = UIStoryboard(name: "MainStory", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(
            "GameIdViewController") as! GameIdViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }

    
    
    // Sets the back cameras focus mode to "Locked"
    func configureDevice() {
        do {
            let device = backCamera
            
            try device!.lockForConfiguration()
            
            //device!.focusMode = .Locked
            device!.unlockForConfiguration()
            
            let focusMode:AVCaptureFocusMode =
                AVCaptureFocusMode.ContinuousAutoFocus
            
            try device?.lockForConfiguration()
            
            if device!.isFocusModeSupported(focusMode) {
                 // lock for configuration
                device!.focusMode = focusMode
                // unlock
            }
            
            device!.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    // Sets up the camera view.
    func beginSession() {
        // Locks camera for configuration
        configureDevice()
        
        do {
            // add back camera as input to the AVCaptureSession
            try captureSession.addInput(AVCaptureDeviceInput(device: backCamera))
        } catch {
            print(error)
        }
        
        // use photo presets
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        // start the capture session
        captureSession.startRunning()
        
        // set image type to jpeg
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        // initialize the AVCapturePreviewLayer to display what the back camera "sees"
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            cameraPreview = UIView(
                frame: CGRectMake(0.0, 0.0, view.bounds.size.width,
                    view.bounds.size.height))
            
            cameraPreview.layer.addSublayer(previewLayer)
            
            // Add gesture recognizer which takes a picture when 
            // the user taps anywhere on the screen
            cameraPreview.addGestureRecognizer(pictureGesture)
            
            // add back button to camera view
            cameraPreview.addSubview(backButton)
            
            // add the camera view onto the main view
            view.addSubview(cameraPreview)
            
            // Add back button to the camera preview layer
            cameraPreview.addSubview(backButton)
        }
        
    }
    
    // Presents the picture to the user
    func showPhoto(sender: UITapGestureRecognizer) {
        // Prevent more pictures from being taken
        self.cameraPreview.removeGestureRecognizer(pictureGesture)
        
        // Take picture
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                // Convert image to jpeg
                let imageData =
                    AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                // Initialize imageview with the jpeg image
                self.image = UIImage(data: imageData)!
                let imageView = UIImageView(image: self.image)
                imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width,
                                         height: self.view.bounds.size.height)
                
                // add image view to superview
                self.view.addSubview(imageView)
                
                // Add use and retake buttons to imageview
                imageView.addSubview(self.okButton)
                imageView.addSubview(self.retakeButton)
                
                // Make use and retake buttons visible
                self.toggleButtonVisibility()
                
                // allows buttons to recieve tap notifications
                imageView.userInteractionEnabled = true
            }
        }
    }
}

