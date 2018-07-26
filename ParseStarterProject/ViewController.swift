/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let testObject = PFObject(className: "TestObject2")
//        
//        testObject["foo"] = "bar"
//        
//        testObject.saveInBackground { (success, error) -> Void in
//            
//            // added test for success 11th July 2016
//            
//            if success {
//                
//                print("Object has been saved.")
//                
//            } else {
//                
//                if error != nil {
//                    
//                    print (error)
//                    
//                } else {
//                    
//                    print ("Error")
//                }
//                
//            }
//            
//        }
        
    }
    
    @IBAction func signupButton(_ sender: Any) {
        if userTF.text == ""
        {
            errorLabel.text = "Username is required ... please enter it"
        }
        else
        {
            PFUser.logInWithUsername(inBackground: userTF.text!, password: "password") { (user, error) in
                if error != nil{
                    let user = PFUser()
                    user.username = self.userTF.text
                    user.password = "password"
                    user.signUpInBackground(block: { (success, error) in
                        if let error = error {
                            let errorMessage = "Signup faild ... please try again later"
//                            if let errorString = error.userInfo["error"] as? String {
//                                errorMessage = errorString
//                            }
                            self.errorLabel.text = errorMessage
                        }
                        else
                        {
                           self.performSegue(withIdentifier: "showUsersTable", sender: nil)
                        }
                        
                    })
                }
                else
                {
                    print("Logged in")
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "showUsersTable", sender: nil)
        }
    }
    
}
