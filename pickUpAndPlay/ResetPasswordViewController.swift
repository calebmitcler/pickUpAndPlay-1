//
//  ResetPasswordViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/19/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var submitButtonTextField: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        if emailTextField.text != "" {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
                // ...
            }
        }
    }
    
    private func setupButtons() {
        submitButtonTextField.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
    }
}
