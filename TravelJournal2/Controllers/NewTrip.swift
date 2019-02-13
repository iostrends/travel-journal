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
    
    var showcaseImage = UIImageView(image: UIImage(named: "addnewphoto"))
    private var backgroundImage = UIImage(named: "background2")
    private var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    lazy private var backgroundImageView = UIImageView(image: backgroundImage)
    lazy private var blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil);
        currentUser = Auth.auth().currentUser?.email ?? NSLocalizedString("User not found", comment: "")
        setupSaveTripButton()
        setupUI()
        tripTitle.delegate = self
        showcaseImage.alpha = 0.4
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        showcaseImage.isUserInteractionEnabled = true
        showcaseImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupSaveTripButton() {
        saveTripBtn.style = .plain
        saveTripBtn.title = NSLocalizedString("Save", comment: "")
        saveTripBtn.target = self
        saveTripBtn.action = #selector(saveNewTrip)
        self.navigationItem.rightBarButtonItem = saveTripBtn
    }
    
    func addNewTripUI() {
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let y = navbarHeight + statusbarHeight + 10
        
        showcaseImage.frame = (CGRect(x: 10, y: y, width: view.frame.width - 20, height: view.frame.height*0.65))
        showcaseImage.contentMode = .scaleAspectFill
        showcaseImage.clipsToBounds = true
        showcaseImage.layer.cornerRadius = 20
        view.addSubview(showcaseImage)
        
        tripTitle.frame = (CGRect(x: 80, y: showcaseImage.frame.height + 10 + y, width: view.frame.width - 160, height: 40))
        tripTitle.layer.cornerRadius = 10
        tripTitle.backgroundColor = .clear
        tripTitle.attributedPlaceholder =  NSAttributedString(string: NSLocalizedString("Trip title", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tripTitle.textColor = .white
        tripTitle.minimumFontSize = 20.0
        tripTitle.textAlignment = .center
        view.addSubview(tripTitle)
        
        datePicker.frame = (CGRect(x: 20, y: showcaseImage.frame.height + tripTitle.frame.height + 20 + y, width: view.frame.width - 40, height: 50))
        datePicker.backgroundColor = .clear
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.datePickerMode = .date
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true
        view.addSubview(datePicker)

        if orientation != .portrait {
            showcaseImage.frame = (CGRect(x: 10, y: y, width: (view.frame.width / 2) - 20, height: (view.frame.height - y - 10)))
            //showcaseImage.layer.borderWidth = 1
            tripTitle.frame = (CGRect(x: showcaseImage.frame.width + 20, y: y, width: (view.frame.width / 2) - 20, height: 50))
            datePicker.frame = (CGRect(x: showcaseImage.frame.width + 20, y: tripTitle.frame.height + 10 + y, width: (view.frame.width / 2) - 20, height: 50))
        }
        
        addLineToView(view: tripTitle, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 1.0)
        addLineToView(view: datePicker, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 1.0)
    }
    
    private func picturePressed() {
        let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Pick a picture from gallery or take a new picture", comment: ""), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { (action) in
            self.cameraPressed()
        }
        
        let galleryAction = UIAlertAction(title: NSLocalizedString("Gallery", comment: ""), style: .default) { (action) in
            self.libraryPressed()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupCustomBackground(backgroundImageView: backgroundImageView, blurEffectView: blurEffectView)
        addNewTripUI()
    }
    
    @objc func cameraPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true, completion: nil)
        showcaseImage.alpha = 1.0
    }
    
    @objc func libraryPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        showcaseImage.alpha = 1.0
    }
    
    // SAVE NEW TRIP TO DATABASE
    
    @objc func saveNewTrip(_ sender: UIBarButtonItem) {
        let tripName = tripTitle.text!
        
        //print("tripname=\(tripName), triparray \(tripsArray)")
        //Checks if the fields are empty and if the Trip Name already exists
        if(tripName != "" && !tripsArray.contains(tripName.lowercased()) && showcaseImage.image != nil){
            
            tripData.oneTrip.userEmail = currentUser
            tripData.oneTrip.tripTitle = tripTitle.text ?? ""
            tripData.oneTrip.tripDate = datePicker.date
            
            tripData.oneTrip.tripImg = showcaseImage.image
            
            tripData.uploadData { (result) in
                self.uploadSuccessMessage()
            }
            
            
        } else if(tripName == "") {
            //print("No title")
            invalidFormMessage(errMessage: 1)
            
        } else if(tripsArray.contains(tripName.lowercased())) {
            //print("Trip already exists")
            invalidFormMessage(errMessage: 2)
        } else {
            invalidFormMessage(errMessage: 3)
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
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        picturePressed()
        // Your action
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
            alert = UIAlertController(title: NSLocalizedString("Missing title", comment: ""), message: NSLocalizedString("Fill in title field", comment: ""), preferredStyle: .alert)
        } else if(errMessage == 2){
            alert = UIAlertController(title: NSLocalizedString("Trip already exists", comment: ""), message: NSLocalizedString("Change your trip title", comment: ""), preferredStyle: .alert)
        } else if(errMessage == 3){
            alert = UIAlertController(title: NSLocalizedString("Picture missing", comment: ""), message: NSLocalizedString("Pick a picture from gallery or take a new picture", comment: ""), preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadSuccessMessage(){
        let alert = UIAlertController(title: NSLocalizedString("Trip added", comment: ""), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
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
                view.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if orientation == .portrait {
            view.frame.origin.y = 0
        }
    }
}
