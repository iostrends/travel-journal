//
//  WelcomeViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-22.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class Welcome: UIViewController {
    var logButton : UIButton {
        let button = UIButton()
        button.titleLabel?.textColor = UIColor.black
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        return button
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        //setupUI()
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        self.title = "Travel Journal 2"
        setupBackground()
        setupButtons()
        setupMainLabel()
    }
    
    func setupBackground() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let image = UIImage(named: "background2")
        imageView.image = image
        view.addSubview(imageView)
        imageView.addSubview(blurEffect())
    }
    
    func blurEffect() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        
        return blurEffectView
        
    }
    
    func setupButtons() {
        var x : CGFloat = 10
        var width : CGFloat = 20
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        let loginButton = logButton
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        loginButton.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 140, width: UIScreen.main.bounds.width - width, height: 50)
        view.addSubview(loginButton)
        
        let registerButton = logButton
        registerButton.setTitle("Register", for: .normal)
        registerButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        registerButton.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 80, width: UIScreen.main.bounds.width - width, height: 50)
        view.addSubview(registerButton)
    }
    
    func setupMainLabel() {
        let label = UILabel(frame: CGRect(x: 20, y: UIScreen.main.bounds.size.height/4, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height*0.33))
        label.text = "Add nice slogan here"
        label.textAlignment = .center
        label.font = UIFont(name: "Zapfino", size: 25.0)
        label.textColor = UIColor.white
        view.addSubview(label)
    }
    
    @objc func loginPressed() {
        print("Logging in....")
        let loginViewController = NewTrip()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc func registerPressed() {
        print("Register....")
        let regViewController = Register()
        self.navigationController?.pushViewController(regViewController, animated: true)
    }
}
