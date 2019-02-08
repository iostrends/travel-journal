//
//  NewTripViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-17.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewTrip: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    //var tripContentView = UIView()
    var showcaseImage = UIImageView()
    var backgroundImageView = UIImageView()
    var backgroundImage = UIImage(named: "background2")
    var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    var cameraBtn = UIButton()
    var libraryBtn = UIButton()
    var tripTitle = UITextField()
    var datePicker = UIDatePicker()
    var saveTripBtn = UIBarButtonItem()
    
    let tripData = TripData()
    var tripsArray : [String] = []
    var dateChoosenString = ""
    var currentUser = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        currentUser = Auth.auth().currentUser?.email ?? "User not found"
        self.title = "Add Trip"
        blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
        setupSaveTripButton()
        setupUI()
        tripTitle.delegate = self
    }
    
    func setupBackground() {
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = backgroundImage
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        view.addSubview(backgroundImageView)
    }
    
    fileprivate func setupSaveTripButton() {
        saveTripBtn.style = .plain
        saveTripBtn.title = "Save"
        saveTripBtn.target = self
        saveTripBtn.action = #selector(saveNewTrip)
        self.navigationItem.rightBarButtonItem = saveTripBtn
    }
    
    func addNewTripUI() {
//        let screenHeight = UIScreen.main.bounds.size.height
//        let screenWidth = UIScreen.main.bounds.size.width
        
//        tripContentView.frame = (CGRect(x: 10, y: 80, width: screenWidth - 20, height: screenHeight - 100))
//        tripContentView.backgroundColor = UIColor.white
//        tripContentView.clipsToBounds = true
//        tripContentView.layer.cornerRadius = 10.0
//        view.addSubview(tripContentView)
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let y = navbarHeight + statusbarHeight + 10
        
        showcaseImage.frame = (CGRect(x: 10, y: y, width: view.frame.width - 20, height: view.frame.height*0.65))
        showcaseImage.contentMode = .scaleAspectFill
        showcaseImage.clipsToBounds = true
        showcaseImage.backgroundColor = .white
        showcaseImage.layer.cornerRadius = 20
        view.addSubview(showcaseImage)
        
        tripTitle.frame = (CGRect(x: 10, y: showcaseImage.frame.height + 10 + y, width: view.frame.width - 20, height: 50))
        tripTitle.placeholder = "Trip Title"
        tripTitle.layer.cornerRadius = 10
        tripTitle.backgroundColor = .white
        tripTitle.minimumFontSize = 20.0
        tripTitle.textAlignment = .center
        view.addSubview(tripTitle)
        
        datePicker.frame = (CGRect(x: 10, y: showcaseImage.frame.height + tripTitle.frame.height + 20 + y, width: view.frame.width - 20, height: 50))
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true
        view.addSubview(datePicker)

        if orientation != .portrait {
//            tripContentView.frame = (CGRect(x: 10, y: 44, width: screenWidth - 20, height: screenHeight - 60))
            showcaseImage.frame = (CGRect(x: 10, y: y, width: (view.frame.width / 2) - 20, height: (view.frame.height - y - 10)))
            //showcaseImage.layer.borderWidth = 1
            tripTitle.frame = (CGRect(x: showcaseImage.frame.width + 20, y: y, width: (view.frame.width / 2) - 20, height: 50))
            datePicker.frame = (CGRect(x: showcaseImage.frame.width + 20, y: tripTitle.frame.height + 10 + y, width: (view.frame.width / 2) - 20, height: 50))
        }
        
        setupCameraButtons()
    }
    
    func setupCameraButtons() {
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let y = navbarHeight + statusbarHeight + 10
        
        var cameraFrame = CGRect(x: 20, y: y + 10, width: 32, height: 32)
        var libraryFrame = CGRect(x: view.frame.width - 52, y: y + 10, width: 32, height: 32)
        
        if orientation != .portrait {
            cameraFrame = CGRect(x: 20, y: y + 10, width: 32, height: 32)
            libraryFrame = CGRect(x: showcaseImage.frame.width - 32, y: y + 10, width: 32, height: 32)
        }
        
        cameraBtn.setImage(UIImage(named: "camera"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(cameraPressed), for: .touchUpInside)
        cameraBtn.frame = cameraFrame
        view.addSubview(cameraBtn)
        
        libraryBtn.setImage(UIImage(named: "library"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(libraryPressed), for: .touchUpInside)
        libraryBtn.frame = libraryFrame
        view.addSubview(libraryBtn)
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupBackground()
        addNewTripUI()
    }
    
    @objc func cameraPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func libraryPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // SAVE NEW TRIP TO DATABASE
    
    @objc func saveNewTrip(_ sender: UIBarButtonItem) {
        let tripName = tripTitle.text!
        
        print("tripname=\(tripName), triparray \(tripsArray)")
        //Checks if the fields are empty and if the Trip Name already exists
        if(tripName != "" && !tripsArray.contains(tripName.lowercased())){
            
            tripData.oneTrip.userEmail = currentUser
            tripData.oneTrip.tripTitle = tripTitle.text ?? ""
            tripData.oneTrip.tripDate = getChoosenDate()
            
            if showcaseImage.image != nil {
                tripData.oneTrip.tripImg = showcaseImage.image
            } else {
                invalidFormMessage(errMessage: 3)
            }
            
            tripData.uploadData()
            
            print("Trip saved")
            uploadSuccessMessage()
            
        } else if(tripName == "") {
            print("No title")
            invalidFormMessage(errMessage: 1)
            
        } else if(tripsArray.contains(tripName.lowercased())) {
            print("Trip already exists")
            invalidFormMessage(errMessage: 2)
        }
        
    }
    
    // IMAGE PICKER FUNCTIONS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        showcaseImage.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        print(info)
        dismiss(animated: true, completion: nil)
        showcaseImage.isHidden = false
        showcaseImage.alpha = 1
        
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    // ALERTS
    
    func invalidFormMessage(errMessage: Int){
        var alert = UIAlertController()
        
        if(errMessage == 1){
            alert = UIAlertController(title: "Titel saknas", message: "Fyll i titelfältet", preferredStyle: .alert)
        } else if(errMessage == 2){
            alert = UIAlertController(title: "Resan finns redan", message: "Titeln finns redan", preferredStyle: .alert)
        } else if(errMessage == 3){
            alert = UIAlertController(title: "Bild saknas", message: "Välj en bild från galleri eller ta en ny", preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadSuccessMessage(){
        let alert = UIAlertController(title: "Tillagd", message: "Resan är tillagd", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
            self.emptyFields()
            
            // Returns to previous view controller
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MISC
    
    func emptyFields(){
        tripTitle.text = ""
    }
    
    func getChoosenDate() -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, YYYY"
        let date = formatter.string(from: datePicker.date)
        print("date datePickerDate", formatter.string(from: datePicker.date))
        
        return date
    }
}
