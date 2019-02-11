//
//  EditPost.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-02-02.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import CoreML
import Vision

class EditPost: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, PostDelegate {
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var userEmail = ""
    var postId = ""
    var postDate = ""
    var newImage = false
    
    var backgroundImage = UIImageView()
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    
    var tripTitle = ""
    var editImage = UIImageView()
    var editTitle = UITextField()
    var editText = UITextView()
    var savePostBtn = UIBarButtonItem()
    var cameraBtn = UIButton()
    var libraryBtn = UIButton()
    
    let data = TripData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        data.loadOnePost(postId: postId)
        blurEffectView.effect = blurEffect
        setupUI()
        data.postDel = self
        editText.delegate = self
    }
    
    func setupBackground() {
        backgroundImage.frame = UIScreen.main.bounds
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.image = UIImage(named: "background2")
        
        blurEffectView.frame = view.bounds
        
        view.addSubview(backgroundImage)
        backgroundImage.addSubview(blurEffectView)
    }
    
    func addEditPostUI() {
        
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let width = view.frame.width - 20
        let height = view.frame.height
        var y = navbarHeight + statusbarHeight + 10
        
        savePostBtn.style = .plain
        savePostBtn.title = NSLocalizedString("Save", comment: "")
        savePostBtn.target = self
        savePostBtn.action = #selector(updatePost)
        
        navigationItem.rightBarButtonItem = savePostBtn
        
        editImage.frame = (CGRect(x: 10, y: y, width: width, height: height*0.40))
        editImage.contentMode = .scaleAspectFill
        editImage.layer.cornerRadius = 10.0
        editImage.clipsToBounds = true
        editImage.backgroundColor = UIColor.white
        
        view.addSubview(editImage)
        
        cameraBtn.setImage(UIImage(named: "camera"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(cameraPressed), for: .touchUpInside)
        cameraBtn.frame = CGRect(x: 20, y: y + 10, width: 32, height: 32)
        view.addSubview(cameraBtn)
        
        libraryBtn.setImage(UIImage(named: "library"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(libraryPressed), for: .touchUpInside)
        libraryBtn.frame = CGRect(x: width - 32, y: y + 10, width: 32, height: 32)
        view.addSubview(libraryBtn)
        y += editImage.bounds.size.height
        
        editTitle.frame = (CGRect(x: 10, y: y + 10, width: width, height: height*0.05))
        editTitle.backgroundColor = UIColor.white
        editTitle.textColor = UIColor.black
        editTitle.font = UIFont(name: "AvenirNext-Medium", size: 22.0)
        editTitle.layer.cornerRadius = 10.0
        editTitle.setInsetLeft(10.0)
        view.addSubview(editTitle)
        y += editTitle.bounds.size.height
        
        editText.frame = (CGRect(x: 10, y: y + 20, width: width, height: height*0.35))
        editText.textColor = UIColor.black
        editText.backgroundColor = UIColor.white
        editText.layer.cornerRadius = 10.0
        view.addSubview(editText)
        y += editText.bounds.size.height
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupBackground()
        addEditPostUI()
    }
    
    @objc func updatePost() {
        if(editTitle.text != ""){

            data.onePost.postTitle = editTitle.text ?? ""
            data.onePost.postText = editText.text ?? ""
            data.onePost.postDate = postDate
            data.onePost.userEmail = userEmail
                    print("user email", userEmail)
            print("post date", postDate)

            if editImage.image != nil {
                data.onePost.postImg = editImage.image
            } else {
                invalidFormMessage(errMessage: 3)
            }

            data.updatePost(postId: postId, newImage: newImage)
            newImage = false

            print("Post updated")
            uploadSuccessMessage()

        } else if(editTitle.text == "") {
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
            self.editTitle.text = topResult.identifier
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
            
            editImage.image = image
            dismiss(animated: true, completion: nil)
            editImage.isHidden = false
            editImage.alpha = 1
            newImage = true
            
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
            alert = UIAlertController(title: "Titel saknas", message: "Fyll i titelfältet", preferredStyle: .alert)
        } else if(errMessage == 3){
            alert = UIAlertController(title: "Bild saknas", message: "Välj en bild från galleri eller ta en ny", preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadSuccessMessage(){
        let alert = UIAlertController(title: "Uppdaterat", message: "Inlägget har blivit uppdaterat", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
            self.emptyFields()
            
            // Returns to previous view controller
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MISC
    
    func emptyFields(){
        editTitle.text = ""
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            editText.text = "Journal entry here"
            editText.textColor = UIColor.lightGray
        }
    }
    
    func SetPostData(description:[String:Any]) {
        editTitle.text = description["postTitle"] as? String
        postDate = description["postDate"] as? String ?? ""
        editText.text = description["postText"] as? String
        userEmail = description["userEmail"] as? String ?? ""
    }
    
    func setPostImg(img:UIImage) {
        editImage.image = img
    }
}
