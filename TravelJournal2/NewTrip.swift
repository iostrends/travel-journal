//
//  NewTripViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-17.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class NewTrip: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth = UIScreen.main.bounds.size.width
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var tripContentView = UIView()
    var showcaseImage = UIImageView()
    var cameraBtn = UIButton()
    var libraryBtn = UIButton()
    var tripTitle = UITextField()
    var datePicker = UIDatePicker()
    var saveTripBtn = UIBarButtonItem()
    
    let tripData = TripData()
    var tripsArray : [String] = []
    var dateChoosenString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupUI()
        tripTitle.delegate = self
        tripsArray = tripData.trips.map { $0.tripTitle.lowercased() }
    }
    
    func setupBackground() {
        let backgroundImage = UIImage(named: "background2")
        let imageView = UIImageView(image: backgroundImage)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(imageView)
        imageView.addSubview(blurEffectView)
        
        
    }
    
    func addNewTripUI() {
        
        tripContentView.frame = (CGRect(x: 10, y: 80, width: screenWidth - 20, height: screenHeight - 100))
        tripContentView.backgroundColor = UIColor.white
        tripContentView.clipsToBounds = true
        tripContentView.layer.cornerRadius = 10.0
        view.addSubview(tripContentView)
        
        saveTripBtn.style = .plain
        saveTripBtn.title = "Save"
        saveTripBtn.action = #selector(saveNewTrip)
        
        self.navigationItem.rightBarButtonItem = saveTripBtn
        
        showcaseImage.frame = (CGRect(x: 0, y: 0, width: tripContentView.frame.width, height: tripContentView.frame.height*0.75))
        showcaseImage.contentMode = .scaleAspectFill
        showcaseImage.clipsToBounds = true
        
        tripContentView.addSubview(showcaseImage)

        if orientation != .portrait {
            tripContentView.frame = (CGRect(x: 10, y: 44, width: screenWidth - 20, height: screenHeight - 60))
            showcaseImage.frame = (CGRect(x: 0, y: 0, width: tripContentView.frame.width, height: (tripContentView.frame.height*0.75)))
        }
        
        cameraBtn.setImage(UIImage(named: "camera"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(cameraPressed), for: .touchUpInside)
        cameraBtn.frame = CGRect(x: 10, y: 10, width: 32, height: 32)
        tripContentView.addSubview(cameraBtn)
        
        libraryBtn.setImage(UIImage(named: "library"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(libraryPressed), for: .touchUpInside)
        libraryBtn.frame = CGRect(x: tripContentView.frame.width - 42, y: 10, width: 32, height: 32)
        tripContentView.addSubview(libraryBtn)
        
        tripTitle.frame = (CGRect(x: 10, y: tripContentView.frame.height*0.75, width: tripContentView.frame.width - 20, height: tripContentView.frame.height*0.10))
        tripTitle.placeholder = "Trip Title"
        tripTitle.minimumFontSize = 20.0
        tripTitle.textAlignment = .center
        tripContentView.addSubview(tripTitle)
        
        datePicker.frame = (CGRect(x: 10, y: tripContentView.frame.height*0.85, width: tripContentView.frame.width - 20, height: tripContentView.frame.height*0.15))
        datePicker.datePickerMode = .date
        tripContentView.addSubview(datePicker)
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        self.title = "Add Trip"
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
        
        //Checks if the fields are empty and if the Trip Name already exists
        if(tripName != "" && !tripsArray.contains(tripName.lowercased())){
            
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
