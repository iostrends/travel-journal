//
//  CreatePost.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-28.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import CoreLocation
import CoreML
import Vision

class NewPost: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var currentUser = ""
    
    private var backgroundImage = UIImage(named: "background2")
    private var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    lazy private var backgroundImageView = UIImageView(image: backgroundImage)
    lazy private var blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
    
    var tripTitle = ""
    var postImage = UIImageView(image: UIImage(named: "addnewphoto"))
    var postTitle = UITextField()
    var postText = UITextView()
    var createPostBtn = UIBarButtonItem()
    
    let data = TripData()
    let locationManager = CLLocationManager()
    
    var latitude = ""
    var longitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        findMyLocation()
        setupUI()
        postText.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
        postImage.alpha = 0.4
    }
    
    func addNewPostUI() {
        
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let width = view.frame.width - 20
        let height = view.frame.height
        var y = navbarHeight + statusbarHeight + 10
        
        createPostBtn.style = .plain
        createPostBtn.target = self
        createPostBtn.title = NSLocalizedString("Save", comment: "")
        createPostBtn.action = #selector(uploadPost)
        
        self.navigationItem.rightBarButtonItem = createPostBtn
        
        postImage.frame = (CGRect(x: 10, y: y, width: width, height: height*0.40))
        postImage.contentMode = .scaleAspectFill
        postImage.layer.cornerRadius = 10.0
        postImage.clipsToBounds = true
        postImage.backgroundColor = .clear
        view.addSubview(postImage)
        
        y += postImage.bounds.size.height
        
        postTitle.frame = (CGRect(x: 70, y: y + 10, width: view.frame.width - 140, height: height*0.05))
        postTitle.backgroundColor = .clear
        postTitle.textColor = UIColor.white
        postTitle.textAlignment = .center
        postTitle.attributedPlaceholder =  NSAttributedString(string: NSLocalizedString("Title", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        postTitle.font = UIFont(name: "AvenirNext-Medium", size: 22.0)
        addLineToView(view: postTitle, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 1.0)
        view.addSubview(postTitle)
        y += postTitle.bounds.size.height
        
        postText.frame = (CGRect(x: 10, y: y + 30, width: width, height: height*0.35))
        postText.text = NSLocalizedString("Journal entry here", comment: "")
        postText.textColor = UIColor.lightGray
        postText.backgroundColor = UIColor.white
        postText.layer.borderColor = UIColor.black.cgColor
        postText.layer.borderWidth = 1
        postText.layer.cornerRadius = 10.0
        view.addSubview(postText)
        
        //y += postText.bounds.size.height
        if orientation != .portrait {
            y = navbarHeight + statusbarHeight + 10
            postImage.frame = (CGRect(x: 10, y: y, width: (view.frame.width / 2) - 20, height: (view.frame.height - y - 10)))
            postTitle.frame = (CGRect(x: postImage.frame.width + 20, y: y, width: (view.frame.width / 2) - 20, height: 40))
            postText.frame = (CGRect(x: postImage.frame.width + 20, y: postTitle.frame.height + 10 + y, width: (view.frame.width / 2) - 20, height: 200))
        }
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
        addNewPostUI()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        picturePressed()
        // Your action
    }
    
    @objc func uploadPost() {
        if(postTitle.text != ""){
            
            data.onePost.userEmail = currentUser
            data.onePost.postTitle = postTitle.text ?? ""
            data.onePost.postText = postText.text ?? ""
            data.onePost.postDate = Date()
            data.onePost.lat = latitude
            data.onePost.long = longitude
            data.onePost.tripTitle = tripTitle
            
            if postImage.image != nil {
                data.onePost.postImg = postImage.image
            } else {
                invalidFormMessage(errMessage: 3)
            }
            
            data.uploadPost()
            
            print("Post saved")
            uploadSuccessMessage()
            
        } else if(postTitle.text == "") {
            print("No title")
            invalidFormMessage(errMessage: 1)
        }
    }
    
    @objc func cameraPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true) {
            self.postImage.alpha = 1.0
        }
        
    }
    
    @objc func libraryPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        print("Library pressed")
        self.present(imagePicker, animated: true) {
            self.postImage.alpha = 1.0
        }
    }
    
    func detectCML(image: CIImage) {
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            guard let observe = request.results as? [VNClassificationObservation] else {return}
            for classification in observe {
                if classification.confidence > 0.01 { print(classification.identifier, classification.confidence) }
            }
            print(topResult.identifier)
            self.postTitle.text = topResult.identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
    }
    
    // IMAGE PICKER FUNCTIONS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            postImage.image = image
            dismiss(animated: true, completion: nil)
            postImage.isHidden = false
            postImage.alpha = 1
            postImage.clipsToBounds = true
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            
            detectCML(image: ciImage)
        }
        
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
            alert = UIAlertController(title: NSLocalizedString("Title missing", comment: ""), message: NSLocalizedString("Fill in title field", comment: ""), preferredStyle: .alert)
        } else if(errMessage == 2){
            alert = UIAlertController(title: NSLocalizedString("Trip already exists", comment: ""), message: NSLocalizedString("A Trip with that title already exists", comment: ""), preferredStyle: .alert)
        } else if(errMessage == 3){
            alert = UIAlertController(title: NSLocalizedString("Picture missing", comment: ""), message: NSLocalizedString("Pick a picture from gallery or take a new picture", comment: ""), preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadSuccessMessage(){
        let alert = UIAlertController(title: NSLocalizedString("Added", comment: ""), message: NSLocalizedString("Post is added", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
            self.emptyFields()
            
            // Returns to previous view controller
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // LOCATION
    
    func findMyLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        // stop updating when you get a valid result. If horizontalAcc is below 0 it is an invalid result
        if location.horizontalAccuracy > 0 {
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            print("Long: \(longitude) and Lat: \(latitude)")
        }
    }
    
    // MISC
    
    func emptyFields(){
        postTitle.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard on hitting return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            postText.text = NSLocalizedString("Journal entry here", comment: "")
            postText.textColor = UIColor.lightGray
        }
    }
}
