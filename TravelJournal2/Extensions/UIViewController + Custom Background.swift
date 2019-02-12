//
//  UIViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-02-12.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func setupCustomBackground(backgroundImageView: UIImageView, blurEffectView: UIVisualEffectView) {
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        view.addSubview(backgroundImageView)
    }
    
}
