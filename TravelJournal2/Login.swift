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
    
    private var logButton : UIButton {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.brown
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        button.layer.cornerRadius = 10
        return button
    }
    
    private var textField : UITextField {
        let text = UITextField()
        text.backgroundColor = UIColor.white
        text.textAlignment = .center
        text.layer.cornerRadius = 10
        return text
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    private var emailTextField = UITextField()
    private var passwordTextField = UITextField()
    private var loginButton = UIButton()
    private var backgroundImageView = UIImageView()
    private var backgroundImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        loginButton = logButton
        emailTextField = textField
        passwordTextField = textField
        backgroundImage =  UIImage(named: "loginbackground")!
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupUI()
    }
    
    private func setupBackground() {
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)
        
    }
    
    private func setupButtons() {
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
    
    private func setupTextFields() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        emailTextField.frame = CGRect(x: x, y: UIScreen.main.bounds.height / 4, width: UIScreen.main.bounds.width - width, height: 40)
        emailTextField.placeholder = "Email"
        view.addSubview(emailTextField)
        
        passwordTextField.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 50, width: UIScreen.main.bounds.width - width, height: 40)
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
    }
    
    @objc private func loginPressed() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if let error = error {
                let alert = UIAlertController(title: "Log in failed", message: "\(error.localizedDescription)", preferredStyle: .alert)
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
    
    @objc private func setupUI() {
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
