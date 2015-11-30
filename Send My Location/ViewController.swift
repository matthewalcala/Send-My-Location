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


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate  {
    

    
    @IBOutlet weak var recipientsField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendLocationButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker:UIImagePickerController!
    let locationManager = CLLocationManager()
    var photo:UIImage!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipientsField.delegate = self
        messageField.delegate = self
        
        photo = nil
        
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 1
            
        
        // Get users location right away
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // @@@ check to see if location services is on and a valid location was returned
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   
    @IBAction func sendMsg(sender: AnyObject) {
    
        // Make sure the device can send an SMS
        if (!MFMessageComposeViewController.canSendText()) {
            
            // need to alert user of error
            sendAlertMessage("SMS Message Failure", msgDesc: "There was an error sending your location. Please verify that your device has SMS enabled.", offerEmail: true)
            
            return;
        }
        
        // Make sure a recipient was selected
        recipientsField.text = recipientsField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (recipientsField.text == "") {
            
            // need to alert user of error
            sendAlertMessage("Recipient is required", msgDesc: "Please enter a valid recipient's phone number or select a contact.", offerEmail: false)
            
            return;
        }
        
        
        // Extract the users coordinates
        let userLocation:CLLocation = locationManager.location!
        
        
        // Construct the message and send
        let messageVC = MFMessageComposeViewController()
        messageVC.recipients = [recipientsField.text!]
        messageVC.body = messageField.text! + " User is at location " + String(userLocation)
        
        
        // Check for image and attach if exist
        if photo != nil {
            let imageData = UIImageJPEGRepresentation(photo, 1.0)
            messageVC.addAttachmentData(imageData!, typeIdentifier: "image/jpeg", filename: "location.jpeg")
        }
        
        messageVC.messageComposeDelegate = self
        
        self.presentViewController(messageVC, animated: true, completion: nil)
        
    
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
        photo = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    func formatPhoto (photo: UIImage) {
        // Define a new image object
        
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
            photo = nil
            imageView.image = nil
            recipientsField.text = ""
            messageField.text = ""
            self.dismissViewControllerAnimated(true, completion: nil)
            
        default:
            break
            
            
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //userLocation:CLLocation = locations[0]
    
    }
    
    func sendAlertMessage(msgTitle: String, msgDesc: String, offerEmail: Bool) {
       
        // need to alert user of error
        let alert = UIAlertController(title: msgTitle, message: msgDesc, preferredStyle: UIAlertControllerStyle.Alert)
        let email = UIAlertAction(title: "Report Error...", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            // Do something when email is tapped
        }
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        
        if offerEmail {
            alert.addAction(email)
        }
        
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}

