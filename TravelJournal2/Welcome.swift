//
//  WelcomeViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-22.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class Welcome: UIViewController {
    
    private var logButton : UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor(red: 144/255, green: 12/255, blue: 63/255, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont(name: "Hamilyn", size: 30)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
//        button.layer.cornerRadius = 80
        return button
    }
    
    private var loginButton = UIButton()
    private var registerButton = UIButton()
    private var mainLabel = UILabel()
    private var backgroundImageView = UIImageView()
    private var backgroundImage = UIImage()
    private var blurEffectStyle = UIBlurEffect()
    private var blurEffectView = UIVisualEffectView()
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @objc private func setupUI() {
        guard !orientation.isFlat else { return }
        setupBackground()
        setupButtons()
        setupMainLabel()
        UIView.animate(withDuration: 2.0) {
            self.mainLabel.alpha = 1
        }
    }
    
    private func setupBackground() {
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
        var x : CGFloat = 50
        var width : CGFloat = 100
        if orientation != .portrait {
            x *= 4
            width *= 4
        }
        loginButton.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 140, width: UIScreen.main.bounds.width - width, height: 50)
        loginButton.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
        loginButton.addTarget(self, action: #selector(goToLoginPressed), for: .touchUpInside)
        loginButton.roundCorners([.topLeft, .bottomRight], radius: 30.0)
        
        registerButton.frame = CGRect(x: x, y: UIScreen.main.bounds.height - 80, width: UIScreen.main.bounds.width - width, height: 50)
        registerButton.setTitle(NSLocalizedString("Register", comment: ""), for: .normal)
        registerButton.addTarget(self, action: #selector(goToRegisterPressed), for: .touchUpInside)
        registerButton.roundCorners([.topLeft, .bottomRight], radius: 30.0)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    private func setupMainLabel() {
        mainLabel.frame = CGRect(x: 20, y: UIScreen.main.bounds.size.height/4, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height*0.33)
        mainLabel.text = NSLocalizedString("Triping", comment: "")
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont(name: "Medinah", size: 85.0)
        mainLabel.textColor = UIColor.white
        mainLabel.alpha = 0
        view.addSubview(mainLabel)
        
    }
    
    @objc private func goToLoginPressed() {
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc private func goToRegisterPressed() {
        let regViewController = Register()
        self.navigationController?.pushViewController(regViewController, animated: true)
    }
    
}

extension UIButton {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
