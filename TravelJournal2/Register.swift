//
//  RegisterViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-22.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import FirebaseAuth

class Register: UIViewController, UITextViewDelegate {
    
    var logButton : UIButton {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.brown
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        button.layer.cornerRadius = 10
        return button
    }
    
    var usernameTextField = UITextField()
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupUI()
    }
    
    func setupBackground() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let image = UIImage(named: "registerbackground")
        imageView.image = image
        view.addSubview(imageView)
        
    }
    
    func setupTextFields() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        usernameTextField = UITextField(frame: CGRect(x: x, y: UIScreen.main.bounds.height / 4, width: UIScreen.main.bounds.width - width, height: 40))
        usernameTextField.backgroundColor = UIColor.white
        usernameTextField.placeholder = "Username"
        usernameTextField.textAlignment = .center
        usernameTextField.layer.cornerRadius = 10
        view.addSubview(usernameTextField)
        
        emailTextField = UITextField(frame: CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 50, width: UIScreen.main.bounds.width - width, height: 40))
        emailTextField.backgroundColor = UIColor.white
        emailTextField.placeholder = "Email"
        emailTextField.textAlignment = .center
        emailTextField.layer.cornerRadius = 10
        view.addSubview(emailTextField)
        
        passwordTextField = UITextField(frame: CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 100, width: UIScreen.main.bounds.width - width, height: 40))
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.placeholder = "Password"
        passwordTextField.textAlignment = .center
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
    }
    
    func setupButtons() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        let loginButton = logButton
        loginButton.setTitle("Register", for: .normal)
        loginButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        loginButton.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 150, width: UIScreen.main.bounds.width - width, height: 50)
        view.addSubview(loginButton)
    }
    
    @objc func registerPressed() {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if(error != nil){
                let alert = UIAlertController(title: "Register failed", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                print(error!)
                
            } else {
                
                let myTripViewController = MyTrips()
                self.navigationController?.pushViewController(myTripViewController, animated: true)
                
            }
        }
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        self.title = "Register"
        setupBackground()
        setupTextFields()
        setupButtons()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard on hitting return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
