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
    var newImage = false
    
    private var backgroundImage = UIImage(named: "background2")
    private var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    lazy private var backgroundImageView = UIImageView(image: backgroundImage)
    lazy private var blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
    
    var tripTitle = ""
    var editImage = UIImageView()
    var editTitle = UITextField()
    var editText = UITextView()
    var savePostBtn = UIBarButtonItem()
    
    let data = TripData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        data.loadOnePost(postId: postId)
        setupUI()
        data.postDel = self
        editText.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        editImage.isUserInteractionEnabled = true
        editImage.addGestureRecognizer(tapGestureRecognizer)
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
        editImage.backgroundColor = .clear
        
        view.addSubview(editImage)
        
        y += editImage.bounds.size.height
        
        editTitle.frame = (CGRect(x: 70, y: y + 10, width: view.frame.width - 140, height: height*0.05))
        editTitle.backgroundColor = .clear
        editTitle.textColor = UIColor.white
        editTitle.textAlignment = .center
        editTitle.font = UIFont.titleFont()
        editTitle.clearButtonMode = .whileEditing
        editTitle.autocapitalizationType = .sentences
        editTitle.layer.cornerRadius = 10.0
        editTitle.setInsetLeft(10.0)
        addLineToView(view: editTitle, position: .LINE_POSITION_BOTTOM, color: UIColor.white, width: 1.0)
        view.addSubview(editTitle)
        y += editTitle.bounds.size.height
        
        editText.frame = (CGRect(x: 10, y: y + 20, width: width, height: height*0.35))
        editText.textColor = UIColor.black
        editText.autocapitalizationType = .sentences
        editText.backgroundColor = UIColor.white
        editText.layer.cornerRadius = 10.0
        view.addSubview(editText)
        y += editText.bounds.size.height
        
        if orientation != .portrait {
            y = navbarHeight + statusbarHeight + 10
            editImage.frame = (CGRect(x: 10, y: y, width: (view.frame.width / 2) - 20, height: (view.frame.height - y - 10)))
            
            editTitle.frame = (CGRect(x: editImage.frame.width + 20, y: y, width: (view.frame.width / 2) - 20, height: 40))
            
            editText.frame = (CGRect(x: editImage.frame.width + 20, y: editTitle.frame.height + 10 + y, width: (view.frame.width / 2) - 20, height: 200))
            
        }
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        picturePressed()
        // Your action
    }
    
    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupCustomBackground(backgroundImageView: backgroundImageView, blurEffectView: blurEffectView)
        addEditPostUI()
    }
    
    @objc func updatePost() {
        if(editTitle.text != ""){
            
            data.onePost.postTitle = editTitle.text ?? ""
            data.onePost.postText = editText.text ?? ""
            data.onePost.postDate = Date()
            data.onePost.userEmail = userEmail

            if editImage.image != nil {
                data.onePost.postImg = editImage.image
            } else {
                invalidFormMessage(errMessage: 3)
            }

            data.updatePost(postId: postId, newImage: newImage) { (result) in
                self.uploadSuccessMessage()
            }
            newImage = false

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
            alert = UIAlertController(title: NSLocalizedString("Title missing", comment: ""), message: NSLocalizedString("Fill in title field", comment: ""), preferredStyle: .alert)
        } else if(errMessage == 3){
            alert = UIAlertController(title: NSLocalizedString("Picture missing", comment: ""), message: NSLocalizedString("Pick a picture from gallery or take a new picture", comment: ""), preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadSuccessMessage(){
        let alert = UIAlertController(title: NSLocalizedString("Updated", comment: ""), message: NSLocalizedString("Your post is now updated", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            
            self.emptyFields()
            
            // Returns to posts view controller
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: PostsCollectionViewController.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MISC
    
    func emptyFields(){
        editTitle.text = ""
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
            editText.text = NSLocalizedString("Journal entry here", comment: "")
            editText.textColor = UIColor.lightGray
        }
    }
    
    func SetPostData(description:[String:Any]) {
        editTitle.text = description["postTitle"] as? String
        editText.text = description["postText"] as? String
        userEmail = description["userEmail"] as? String ?? ""
    }
    
    func setPostImg(img:UIImage) {
        let editImg = img
        
        let inW = editImg.size.width
        let inH = editImg.size.height
        let inRatio = inH/inW
        
        let viewW = editImage.frame.size.width
        let viewH = editImage.frame.size.height
        let viewRatio = viewH/viewW
        
        var offsetX:CGFloat = 0.0
        var offsetY:CGFloat  = 0.0
        var outW:CGFloat  = 0.0
        var outH:CGFloat  = 0.0
        
        if  inRatio > viewRatio {
            outW = viewW
            outH = inRatio*outW
            offsetX = 0.0
            offsetY = (viewH-outH)/2.0
        } else {
            outH = viewH
            outW = outH/inRatio
            offsetY = 0.0
            offsetX = (viewW-outW)/2.0
        }
        
        UIGraphicsBeginImageContext(CGSize(width: viewW, height: viewH))
        
        editImg.draw(in: CGRect(x: offsetX, y: offsetY, width: outW, height: outH))
        editImage.image = editImg
        UIGraphicsEndImageContext()
    }
}
