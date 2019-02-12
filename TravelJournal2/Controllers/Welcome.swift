//
//  WelcomeViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-22.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import FirebaseAuth

class Welcome: UIViewController {
    
    private var logButton : UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor.mainRed(), for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.buttonFont()
        return button
    }
    
    private var textField : UITextField {
        let text = UITextField()
        text.backgroundColor = UIColor.loginBackground()
        text.textAlignment = .center
        text.font = UIFont.textFont()
        text.textColor = UIColor.white
        text.layer.cornerRadius = 10
        return text
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    lazy var emailTextField = textField
    lazy var passwordTextField = textField
    lazy var loginButton = logButton
    lazy var registerButton = logButton
    var mainLabel = UILabel()
    private var backgroundImage = UIImage(named: "background2")
    private var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    lazy private var backgroundImageView = UIImageView(image: backgroundImage)
    lazy private var blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil);
        setupUI()
        if let _ = Auth.auth().currentUser {
            //go to my trips directly if user is logged in
            let myTripsViewController = MyTrips()
            self.navigationController?.pushViewController(myTripsViewController, animated: true)
        }
    }
    
    private func setupMainLabel() {
        if orientation != .portrait {
            mainLabel.isHidden = true
        } else {
            mainLabel.isHidden = false
        }
        
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        let topHeight = navbarHeight + statusbarHeight
        
        mainLabel.frame = CGRect(x: 20, y: topHeight + 20, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.height / 4)
        mainLabel.text = NSLocalizedString("Triping", comment: "")
        mainLabel.font = UIFont.logoFontNormal()
        mainLabel.textAlignment = .center
        mainLabel.textColor = UIColor.white
        mainLabel.shadowColor = UIColor.mainRed()
        mainLabel.shadowOffset = CGSize(width: 3, height: 3)
        
        view.addSubview(mainLabel)
    }
    
    func setupButtons() {
        var x : CGFloat = 40
        var width : CGFloat = 80
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        
        loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
        loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        loginButton.frame = CGRect(x: x, y: (UIScreen.main.bounds.height - 160), width: UIScreen.main.bounds.width - width, height: 50)
        loginButton.roundCorners([.topLeft, .bottomRight], radius: 30.0)
        view.addSubview(loginButton)
        
        registerButton.setTitle(NSLocalizedString("Register", comment: ""), for: .normal)
        registerButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        registerButton.frame = CGRect(x: x, y: (UIScreen.main.bounds.height - 100), width: UIScreen.main.bounds.width - width, height: 50)
        registerButton.roundCorners([.topLeft, .bottomRight], radius: 30.0)
        view.addSubview(registerButton)
    }
    
    private func setupTextFields() {
        var x : CGFloat = 40
        var width : CGFloat = 80
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        emailTextField.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 300, width: UIScreen.main.bounds.width - width, height: 40)
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderColor()])
        view.addSubview(emailTextField)
        
        passwordTextField.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 250, width: UIScreen.main.bounds.width - width, height: 40)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderColor()])
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
    }
    
    @objc private func loginPressed() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if let error = error {
                let alert = UIAlertController(title: NSLocalizedString("Login failed", comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                    //NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                print(error)
                
            } else {
                let myTripsViewController = MyTrips()
                self.navigationController?.pushViewController(myTripsViewController, animated: true)
            }
        }
    }
    
    @objc private func registerPressed() {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: NSLocalizedString("Register failed", comment: ""), message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                    //NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                print(error)
                
            } else {
                let myTripsViewController = MyTrips()
                self.navigationController?.pushViewController(myTripsViewController, animated: true)
                
            }
        }
    }
    
    @objc private func setupUI() {
        guard !orientation.isFlat else { return }
        setupCustomBackground(backgroundImageView: backgroundImageView, blurEffectView: blurEffectView)
        setupMainLabel()
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
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if orientation == .portrait {
                emailTextField.frame.origin.y -= keyboardHeight
                passwordTextField.frame.origin.y -= keyboardHeight
                loginButton.frame.origin.y -= keyboardHeight
                registerButton.frame.origin.y -= keyboardHeight
                mainLabel.frame.origin.y = 20
                mainLabel.font = UIFont.logoFontSmall()
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        let topHeight = navbarHeight + statusbarHeight
        
        if orientation == .portrait {
            emailTextField.frame.origin.y = UIScreen.main.bounds.height - 300
            passwordTextField.frame.origin.y = UIScreen.main.bounds.height - 250
            loginButton.frame.origin.y = UIScreen.main.bounds.height - 160
            registerButton.frame.origin.y = UIScreen.main.bounds.height - 100
            mainLabel.frame.origin.y = topHeight + 20
            mainLabel.font = UIFont.logoFontNormal()
        }
    }
    
}
