//
//  ViewController.swift
//  Flash Chat
//
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!         // what is this
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var topButton = UIButton()                                  // why do i even need this, it's not being used
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self                        // why do i do this for a textfield???
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        //TODO: Register your MessageCell.xib file here:
        // customMessageCell --  is the identifier for this custom cell, as you can see by going to MessageCell.xib file
        // and MessageCell is the name of the xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")

        // essentially the first method that gets called in this viewdidLoad method
        configureTableView()
        
        // retrieve your msgs here -- loads up all the msgs when the app starts up
        retrieveMessages()
        
        // why here???
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a temp cell and assign the table cell to it
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        // set its properties
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        // changing some colors for good UI
        // if current user is logged in, make his screen blue
        if cell.senderUsername.text == Auth.auth().currentUser?.email! {
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        // otherwise make it grey
        else {
            
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        // return the cell
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    // this method is called inside retreiveMsgs(), probably to configure the display of the msg
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    // these methods below take care of the text field size
    // once you start typing, text field becomes taller
    // when you end editing, text field shrinks
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField : UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing (_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //TODO: Send the message to Firebase and save it in our database
        
        // first off, disable some stuff - the button and the text field
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // create an instance of a db on Firebase
        let messagesDB = Database.database().reference().child("Messages")
        
        // create a dictionary - this will save your msg, and will eventually be added to the db
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email,
                                "MessageBody" : messageTextfield.text!]
        
        // pass on the msg to Firebase, use the closure technique to get a response back and stuff
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            // just play around with the error that's returned
            if error != nil {
                print (error!)
            }
            else {
                print ("Message successfully added to our Firebase db")
            }
            
            // reset your buttons and text field
            self.sendButton.isEnabled = true
            self.messageTextfield.isEnabled = true
            self.messageTextfield.text = ""
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        
        // get the messagesDB
        let messagesDB = Database.database().reference().child("Messages")
        
        // use the observe method provided by firebase to get a "snapshot"
        messagesDB.observe(.childAdded) {
            (snapshot) in
        
            // use that snapshot result, store the dictionary in a local variable
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            // this snapshot result has two parts - the sender info and the msg body.
            let sender = snapshotValue["Sender"]!
            let text = snapshotValue["MessageBody"]!
        
            // now create an instance your Message class, to store these results
            let msg = Message()
            msg.sender = sender
            msg.messageBody = text
            
            // once the Message object has been populated, add the message to the message array
            self.messageArray.append(msg)
            
            // now call configure table viw to do some displaying config (perhaps???)
            self.configureTableView()
            
            // then call reload data method to make sure message array is reloaded/refreshed on the screen
            self.messageTableView.reloadData()
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print ("Error occured while logging out")
        }
        
    }
    
}
