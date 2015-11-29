//
//  ViewController.swift
//  Send My Location
//
//  Created by Matthew Alcala on 11/22/15.
//  Copyright © 2015 ninjabandito. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    

    
    @IBOutlet weak var recipientsField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendLocationButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker:UIImagePickerController!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get users location right away
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // hi
    }
    
    func hi(){
        
    }

    @IBAction func takePhoto(sender: AnyObject) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil
        )
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
    }
    
    
    @IBAction func sendLocation(sender: AnyObject) {
        
        // Extract the users coordinates
        let userLocation:CLLocation = locationManager.location!
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.recipients = [recipientsField.text!]
        messageVC.body = messageField.text! + " User is at location " + String(userLocation)
        
        messageVC.messageComposeDelegate = self
        
        self.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    
       func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
            
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
            
        case MessageComposeResultFailed.rawValue:
            print("Message Failed")
            self.dismissViewControllerAnimated(true, completion: nil)
            
        case MessageComposeResultSent.rawValue:
            print("Message was sent!")
            self.dismissViewControllerAnimated(true, completion: nil)
            
        default:
            break
            
            
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //userLocation:CLLocation = locations[0]
    
    }
    
   

}

