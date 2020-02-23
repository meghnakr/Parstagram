//
//  LoginViewController.swift
//  Parstagram
//
//  Created by user162638 on 2/19/20.
//  Copyright © 2020 user162638. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let email = usernameField.text! + "@domain.com"
        let password = passwordField.text!
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if(error == nil)
            {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                let user = Auth.auth().currentUser
                let uniqueId = user?.uid
                self.ref.child("Users").child(uniqueId!).setValue(["username": self.usernameField.text!])
            }
            else
            {
               let alert = UIAlertController.init(title: "", message: "Username Already Exists", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated:true)
            }
        }
    }

    @IBAction func onLogin(_ sender: Any) {
        let email = usernameField.text! + "@domain.com"
        let password = passwordField.text!
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let strongSelf = self else {return}
            if(error == nil)
            {
                strongSelf.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else
            {
                let alert = UIAlertController.init(title: "Incorrect", message: "Incorrect Username or Password", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated:true)
                self?.passwordField.text = ""
            }
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
