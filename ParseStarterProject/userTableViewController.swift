//
//  userTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Hamada on 7/19/18.
//  Copyright © 2018 Parse. All rights reserved.
//

import UIKit
import Parse
class userTableViewController: UITableViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    var usernames : [String] = []
    var recipientUsername = ""
    var timer = Timer()
    @objc func messageCheck(){
        let query = PFQuery(className: "Image")
        query.whereKey("recepientUsername", equalTo: PFUser.current()?.username)
        do
        {
            let images = try query.findObjects()
            if images.count > 0 {
                    var senderUsername = "Unkown User"
                    if let username = images[0]["senderUsername"] as? String{
                        senderUsername = username
                    }
                    if let pfFile = images[0]["photo"] as? PFFile {
                        pfFile.getDataInBackground(block: { (data, error) in
                            if let imageData = data {
                                images[0].deleteInBackground()
                                self.timer.invalidate()
                                
                                if let imageToDisplay = UIImage(data: imageData){
                                    let alertController2 = UIAlertController(title: "You have Message", message: "Message From " + senderUsername, preferredStyle: .alert)
                                    alertController2.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                        let backgroundImageView  = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                        backgroundImageView.backgroundColor = UIColor.black
                                        backgroundImageView.alpha = 0.8
                                        backgroundImageView.tag = 10
                                        self.view.addSubview(backgroundImageView)
                                        let displayedImageView  = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                        displayedImageView.image = imageToDisplay
                                        displayedImageView.tag = 10
                                        displayedImageView.contentMode = UIViewContentMode.scaleAspectFit
                                        self.view.addSubview(displayedImageView)
                                        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
                                            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(userTableViewController.messageCheck), userInfo: nil, repeats: true)
                                        })
                                        for subView in self.view.subviews {
                                            if subView.tag == 10 {
                                                subView.removeFromSuperview()
                                            }
                                        }
                                        
                                    }))
                                    self.present(alertController2, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                
            }
        }
        catch{
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

      self.navigationController?.navigationBar.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(userTableViewController.messageCheck), userInfo: nil, repeats: true)
        
       
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        do
        {
        let users = try query?.findObjects()
            if let users = users as? [PFUser]{
                for user in users{
                    self.usernames.append(user.username!)
                }
            }
        }
        catch
        {
            print("could not appear in userslist")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipientUsername = usernames[indexPath.row]
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            print("Image Returned")
            let imageToSend  = PFObject(className: "Image")
            imageToSend["photo"] = PFFile(name: "photo.jpeg", data: UIImageJPEGRepresentation(image, 0.5)!)
            imageToSend["senderUsername"] = PFUser.current()?.username
            imageToSend["recipientUsername"] = recipientUsername
            imageToSend.saveInBackground { (success, error) in
                var title = "Sending Failed"
                var description = "please try again later"
                if success{
                    title = "Sending Success"
                    description = "Message has been sent successfully"
                }
                let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alertController, animated: true, completion: nil)
            }
           
           
            
            
          
}
        self.dismiss(animated: true, completion: nil)
}
    
    
    
    
}
