//
//  CreatePost.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-28.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import CoreLocation

class NewPost: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth = UIScreen.main.bounds.size.width
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var postContentView = UIView()
    var postImage = UIImageView()
    var postTitle = UITextField()
    var postText = UITextView()
    var createPostBtn = UIBarButtonItem()
    var cameraBtn = UIButton()
    var libraryBtn = UIButton()
    
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
    }
    
    func setupBackground() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "background2")
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        
        view.addSubview(imageView)
        imageView.addSubview(blurEffectView)
    }
    
    func addNewPostUI() {
        
        postContentView.frame = (CGRect(x: 10, y: 80, width: screenWidth - 20, height: screenHeight - 100))
        postContentView.backgroundColor = UIColor.clear
        postContentView.clipsToBounds = true
        view.addSubview(postContentView)
        
        let postViewWidth = postContentView.frame.width
        let postViewHeight = postContentView.frame.height
        
        createPostBtn.style = .plain
        createPostBtn.title = "Save"
        createPostBtn.action = #selector(uploadPost)
        
        self.navigationItem.rightBarButtonItem = createPostBtn
        
        postImage.frame = (CGRect(x: 10, y: 0, width: postViewWidth - 20, height: postViewHeight*0.40))
        postImage.contentMode = .scaleAspectFill
        postImage.layer.cornerRadius = 10.0
        postImage.clipsToBounds = true
        postImage.backgroundColor = UIColor.white
        
        postContentView.addSubview(postImage)

        if orientation != .portrait {
            postContentView.frame = (CGRect(x: 10, y: 44, width: screenWidth - 20, height: screenHeight - 60))
            postImage.frame = (CGRect(x: 0, y: 0, width: postViewWidth, height: (postViewHeight*0.75)))
        }
        
        postTitle.frame = (CGRect(x: 10, y: postViewHeight*0.41, width: postViewWidth - 20, height: postViewHeight*0.09))
        postTitle.backgroundColor = UIColor.white
        postTitle.textColor = UIColor.black
        postTitle.placeholder = " Title" // Intentional space
        postTitle.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
        postTitle.layer.cornerRadius = 10.0
        postContentView.addSubview(postTitle)
        
        postText.frame = (CGRect(x: 10, y: postViewHeight*0.51, width: postViewWidth - 20, height: postViewHeight*0.45))
        postText.text = "Journal entry here"
        postText.textColor = UIColor.lightGray
        postText.backgroundColor = UIColor.white
        postText.layer.cornerRadius = 10.0
        postContentView.addSubview(postText)
        
        cameraBtn.setImage(UIImage(named: "camera"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(cameraPressed), for: .touchUpInside)
        cameraBtn.frame = CGRect(x: 20, y: 10, width: 32, height: 32)
        postContentView.addSubview(cameraBtn)
        
        libraryBtn.setImage(UIImage(named: "library"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(libraryPressed), for: .touchUpInside)
        libraryBtn.frame = CGRect(x: postViewWidth - 52, y: 10, width: 32, height: 32)
        postContentView.addSubview(libraryBtn)
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupBackground()
        addNewPostUI()
    }
    
    @objc func uploadPost() {
        if(postTitle.text != ""){
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, YYYY"
            let date = formatter.string(from: Date())
            
            data.onePost.postTitle = postTitle.text ?? ""
            data.onePost.postText = postText.text ?? ""
            data.onePost.postDate = date
            data.onePost.lat = latitude
            data.onePost.long = longitude
            data.onePost.tripTitle = "London"
            
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
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func libraryPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        print("Library pressed")
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // IMAGE PICKER FUNCTIONS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        postImage.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        dismiss(animated: true, completion: nil)
        postImage.isHidden = false
        postImage.alpha = 1
        
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
        let alert = UIAlertController(title: "Tillagd", message: "Inlägget är tillagd", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
}
