//
//  WelcomeViewController.swift
//  Flash Chat
//
//  This is the welcome view controller - the first thing the user sees
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // if someone is logged in, bypass this screen, and go straight to msgs
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "goToChat", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
