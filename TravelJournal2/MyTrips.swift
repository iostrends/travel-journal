//
//  ViewController.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-09.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class MyTrips: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    var sendDataButton : UIButton {
        let button = UIButton()
        button.setTitle("Send Data", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        button.addTarget(self, action: #selector(sendDataPressed), for: .touchUpInside)
        button.backgroundColor = UIColor.black
        return button
    }
    
    var addNewTripButton : UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTripPressed))
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.red
        self.title = "My Trips"
        navigationItem.rightBarButtonItem = addNewTripButton
        let button = sendDataButton
        button.frame = CGRect(x: view.bounds.width / 2 - 75, y: view.bounds.height / 2, width: 150, height: 50)
        view.addSubview(button)
    }
    
    @objc func sendDataPressed() {
        let db = Firestore.firestore()
        let dataDict = [
            "tripTitle": "Sam test",
            "date": "12/4 - 19"
        ]
        
        db.collection("Trips").document().setData(dataDict) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("Dokument sparat")
            }
        }
    }
    
    @objc func addNewTripPressed() {
        let newTripViewController = NewTrip()
        self.navigationController?.pushViewController(newTripViewController, animated: true)
    }
    
    
}

