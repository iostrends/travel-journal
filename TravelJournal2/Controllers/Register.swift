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
    
    private var logButton : UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor(red: 144/255, green: 12/255, blue: 63/255, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Hamilyn", size: 30)
        return button
    }
    
    var textField : UITextField {
        let text = UITextField()
        text.backgroundColor = UIColor.white
        text.textAlignment = .center
        text.layer.cornerRadius = 10
        return text
    }
    
    private var emailTextField = UITextField()
    private var passwordTextField = UITextField()
    private var registerButton = UIButton()
    private var backgroundImage = UIImage(named: "background2")
    private var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    lazy private var backgroundImageView = UIImageView(image: backgroundImage)
    lazy private var blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        self.title = NSLocalizedString("Register", comment: "")
        registerButton = logButton
        emailTextField = textField
        passwordTextField = textField
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupUI()
    }
    
    func setupTextFields() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        
        emailTextField.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4), width: UIScreen.main.bounds.width - width, height: 40)
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        view.addSubview(emailTextField)
        
        passwordTextField.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 50, width: UIScreen.main.bounds.width - width, height: 40)
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
    }
    
    func setupButtons() {
        var x : CGFloat = 20
        var width : CGFloat = 40
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        
        registerButton.frame = CGRect(x: x, y: (UIScreen.main.bounds.height / 4) + 100, width: UIScreen.main.bounds.width - width, height: 50)
        registerButton.setTitle(NSLocalizedString("Register", comment: ""), for: .normal)
        registerButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        registerButton.roundCorners([.topLeft, .bottomRight], radius: 30.0)
        view.addSubview(registerButton)
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
                
                let myTripViewController = MyTrips()
                self.navigationController?.pushViewController(myTripViewController, animated: true)
                
            }
        }
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupCustomBackground(backgroundImageView: backgroundImageView, blurEffectView: blurEffectView)
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
