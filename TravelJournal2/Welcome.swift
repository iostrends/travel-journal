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
    
    var loginButton = UIButton()
    var registerButton = UIButton()
    var mainLabel = UILabel()
    var backgroundImageView = UIImageView()
    var backgroundImage = UIImage()
    var blurEffectStyle = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Travel Journal 2"
        view.backgroundColor = UIColor.clear
        loginButton = logButton
        registerButton = logButton
        backgroundImage = UIImage(named: "background2")!
        blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupBackground()
        setupButtons()
        setupMainLabel()
    }
    
    func setupBackground() {
        //backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = backgroundImage
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
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
        loginButton.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 140, width: UIScreen.main.bounds.width - width, height: 50)
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        registerButton.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 80, width: UIScreen.main.bounds.width - width, height: 50)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    func setupMainLabel() {
        mainLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.size.height/4, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height*0.33)
        mainLabel.text = "Add nice slogan here"
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont(name: "Zapfino", size: 25.0)
        mainLabel.textColor = UIColor.white
        view.addSubview(mainLabel)
        
    }
    
    @objc func loginPressed() {
        print("Logging in....")
        let loginViewController = PostsCollectionViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc func registerPressed() {
        print("Register....")
        let regViewController = Register()
        self.navigationController?.pushViewController(regViewController, animated: true)
    }
}
