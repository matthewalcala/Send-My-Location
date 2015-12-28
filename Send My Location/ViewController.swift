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
import ContactsUI
import Contacts


class ViewController: UIViewController, CLLocationManagerDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, CNContactPickerDelegate  {
    
    
    // MARK: Properties
    @IBOutlet weak var debugLocation: UITextField!
    @IBOutlet weak var recipientsField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendLocationButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    
    var imagePicker:UIImagePickerController!
    let locationManager = CLLocationManager()
    var photo:UIImage!
    var recipients = [String:String]()
    //let session = NSURLSession.sharedSession()  // for twilio call
    var imageFileName: String = ""
   // var optionalMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageFileName = ""
              
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
        
        // @@@ also send an msg with instructions on how to enable locaiton services
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: UITextFieldDelegate
   
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    func resetForm () {
        dispatch_async(dispatch_get_main_queue(),{
            self.myActivityIndicator.stopAnimating()
            self.photo = nil
            self.imageView.image = nil
            self.recipientsField.text = ""
            self.messageField.text = ""
          //  self.optionalMessage = ""
            self.photo = nil
            self.imageFileName = ""
            self.recipients.removeAll()
        });
       
    }
    
  
    // MARK: Actions

    @IBAction func showContactsPicker(sender: AnyObject) {
   
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        
        self.presentViewController(contactPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func sendMsgPressed(sender: AnyObject) {
        
        // @@@ add error handling and also manipulate activity indicator
        
        
        var recipientPhoneNumbers:String = ""
        
        
        // Make sure a recipient was selected
        //recipientsField.text = recipientsField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (recipients.count == 0) {
            
            // need to alert user of error
            displayAlertMessage("Recipient is required", msgDesc: "Please enter a valid recipient's phone number or select a contact.", offerEmail: false)
            
            return;
        }
            // Create the list of phone numbers for the message
        else {
            for (_, phoneNumber) in recipients {
                recipientPhoneNumbers += (recipientPhoneNumbers == "") ? phoneNumber : ", " + phoneNumber
            }
        }
        
        // Load the text part of the message if one was added
        //optionalMessage = messageField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (imageView.image != nil) {
            myImageUploadRequest()
        }
        else {
            
            sendSMS()
            
            // @@@ need to capture an error an notify user if message was sent or not
            
            /*{
            // message has been sent
            // this would be cooler if we had a graphic
            print("Message was sent!")
            
            
            //   displayAlertMessage("Message Sent!", msgDesc: "Your message was sent successfully!", offerEmail: false)
            }
            else
            {
            //  displayAlertMessage("Message not sent", msgDesc: "There was an unknown error sending your message. Please try again or report this error to us.", offerEmail: false)
            }
            
            }
            */
        }
        
    }

    @IBAction func takePhoto(sender: AnyObject) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
        let contact = contactProperty.contact
        let phoneNumber = contactProperty.value as! CNPhoneNumber
        
        // Add the recipient to the dictionary
        let contactFullName = contact.givenName + " " + contact.familyName
        recipients[contactFullName] = phoneNumber.stringValue
        
       populateRecipientsTextBox()
        
        print(recipients)
    }
    
    func populateRecipientsTextBox() {
        // Repopulate the textbox of recipients
        recipientsField.text = ""
        var textForField = ""
        
        for (fullName, _) in recipients {
            if textForField == "" {
                textForField = fullName
            }
            else {
                textForField += ", " + fullName
            }
            
            recipientsField.text = textForField
            
        }

    }

    
    func sendSMS() //-> Bool
    {
        var mediaUrl : String = ""
        var message : String = ""
        
        //Sender ID = AC5cdj7g8d56gs7c4f1721cdc
        //token secret = f1452eijsk748eydhu284cd1062649ff8c7
        var returnStatus = false
        
        let twilioSID = "ACa08504aba0c17df9fee4b6a653b86792"
        let twilioSecret = "f793576101d25255c0c879ad546b87bf"
        
        //Note replace + = %2B , for To and From phone number
        let fromNumber = "%2B19162993100"
        let toNumber = "%2B19167928290"
        
        if (imageView.image != nil) {
            mediaUrl = "&MediaUrl=http://www.darmilabs.com/sml/engine/appphotos/" + self.imageFileName
        }

        message = "&Body=" + constructMessageText()
        
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=\(fromNumber)&To=\(toNumber)\(message)\(mediaUrl)".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the completion block and send the request
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                // Success
                print("Response: \(responseDetails)")
                returnStatus = true
            } else {
                // Failure
                print("Error: \(error)")
                returnStatus = false
            }
            
            // change the permissions of the image on darmi labs server so it is secure from outside world
            if (self.imageView.image != nil) {
                self.modifyImagePermissionsOnServer()
            }
            
            self.resetForm()
        }).resume()
        
        self.myActivityIndicator.stopAnimating()
        
        //return returnStatus
    }
    
    
    // Construct the message text. Format is:
    // (TimeStamp)
    // Message (optional)
    // Google location link
    func constructMessageText() -> String {
        
        var msgText = ""
    
        msgText = getTimeStampText() + "\n"
        msgText += getOptionalMessageText()
        msgText += getGoogleMapURLText()
    
        
        return msgText;
    }
    

    
    func getOptionalMessageText() -> String {
        var retText = ""
        
        // Load the text part of the message if one was added
        let optionalMsg = messageField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (optionalMsg != "") {
            retText = "Message from user: " + optionalMsg + "\n"
        }
        else {
               retText = ""
        }

        return retText
    }
    
    func getGoogleMapURLText() -> String
    {
        // Extract the users coordinates
        let userLocation:CLLocation = locationManager.location!
        
        let myCoord = String(userLocation.coordinate.latitude) + "," + String(userLocation.coordinate.longitude)
        
        
        
        let url  = "Location of user: http://maps.google.com/?q=\(myCoord)"
        
        return url
        
    }
    
    func getTimeStampText() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        
        let timestamp = "(" + formatter.stringFromDate(NSDate()) + ")"
        
        return timestamp
    }
    

    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        photo = info[UIImagePickerControllerOriginalImage] as? UIImage
        print ("photo was taken successfully")
    }
    
    func formatPhoto (photo: UIImage) {
        // Define a new image object
        // resize here @@@
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //print(locations[0])
    
    }

    func displayAlertMessage(msgTitle: String, msgDesc: String, offerEmail: Bool) {
       
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
    
    
    func myImageUploadRequest()
    {
    
       let myUrl = NSURL(string: "http://www.darmilabs.com/sml/engine/postphoto.php");
        
        let request = NSMutableURLRequest(URL:myUrl!);
      
        request.HTTPMethod = "POST";
        
        let param = [
            "firstName"  : "Flash",
            "lastName"    : "Steele",
            "userId"    : "777"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0)
        
        if (imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        
        myActivityIndicator.startAnimating();
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            
            //var err: NSError?
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
            }
            catch {}
            
            
            /*
            if let parseJSON = json {
            var firstNameValue = parseJSON["firstName"] as? String
            println("firstNameValue: \(firstNameValue)")
            }
            */
            
            // now that the picture is uploaded, we can call twilio to send message
            self.sendSMS()
            
        }
        
        task.resume()
        
      //  print("photo has been save to servers as \(imageFileName)")
        
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let uuid = NSUUID().UUIDString
        
        imageFileName =  "\(uuid).jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(imageFileName)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func modifyImagePermissionsOnServer() {

        let myUrl = NSURL(string: "http://www.darmilabs.com/sml/engine/modfileperms.php");
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        // Compose a query string
        let postString = "fileName=" + imageFileName;
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            do {
                let myJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
              
                /*
                if let parseJSON = myJSON {
                    // Now we can access value of First Name by its key
                    let firstNameValue = parseJSON["firstName"] as? String
                    print("firstNameValue: \(firstNameValue)")
                }
                */
                
            }
            catch {}
            
            
            
        }
        
        task.resume()
    }
    
}

// MARK: Extenstions

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

extension NSURLSession {
    func synchronousDataTaskWithURL(url: NSURL) -> (NSData?, NSURLResponse?, NSError?) {
        var data: NSData?
        var response: NSURLResponse?
        var error: NSError?
        
        let sem = dispatch_semaphore_create(0)
        
        let task = self.dataTaskWithURL(url, completionHandler: {
            data = $0
            response = $1
            error = $2
            dispatch_semaphore_signal(sem)
        })
        
        task.resume()
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
        
        return (data, response, error)
    }
}




/*
extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

*/
