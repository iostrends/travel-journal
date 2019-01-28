//
//  LoginViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-22.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextViewDelegate {
    
    var logButton : UIButton {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.brown
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        button.layer.cornerRadius = 10
        return button
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var loginButton = UIButton()
    var backgroundImageView = UIImageView()
    var backgroundImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        loginButton = logButton
        backgroundImage =  UIImage(named: "loginbackground")!
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupUI()
    }
    
    func setupBackground() {
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)
        
    }
    
    func setupButtons() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        loginButton.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 100, width: UIScreen.main.bounds.width - width, height: 50)
        view.addSubview(loginButton)
    }
    
    func setupTextFields() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        emailTextField.frame = CGRect(x: x, y: UIScreen.main.bounds.height / 4, width: UIScreen.main.bounds.width - width, height: 40)
        emailTextField.backgroundColor = UIColor.white
        emailTextField.placeholder = "Email"
        emailTextField.textAlignment = .center
        emailTextField.layer.cornerRadius = 10
        view.addSubview(emailTextField)
        
        passwordTextField.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 50, width: UIScreen.main.bounds.width - width, height: 40)
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.placeholder = "Password"
        passwordTextField.textAlignment = .center
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
    }
    
    @objc func loginPressed() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if let error = error {
                let alert = UIAlertController(title: "Log in failed", message: "Email or password is not correct", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                print(error)
                
            } else {
                let newTripViewController = MyTrips()
                self.navigationController?.pushViewController(newTripViewController, animated: true)
            }
        }
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        self.title = "Login"
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
