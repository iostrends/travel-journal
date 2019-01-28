//
//  ViewPost.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-25.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class ViewPost: UIViewController, PostDelegate {

    let screenHeight = UIScreen.main.bounds.size.height
    let screenWidth = UIScreen.main.bounds.size.width

    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    var postContentView = UIView()
    var postImage = UIImageView()
    var postTitle = UILabel()
    var postDate = UILabel()
    var postText = UITextView()
    var shareBtn = UIButton()
    var locationBtn = UIButton()
    var savePostBtn = UIBarButtonItem()
    var buttonView = UIView()

    let data = TripData()
    var postArray : [String] = []
    
    var currentPost = 0
    var postId = "btbNMLaXB2wQu86kkKfn"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(setupUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        data.loadOnePost(postId: postId)
        setupUI()
        data.postDel = self
        postArray = data.posts.map { $0.tripTitle.lowercased() }
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

    func addViewPostUI() {

        postContentView.frame = (CGRect(x: 10, y: 80, width: screenWidth - 20, height: screenHeight - 100))
        postContentView.backgroundColor = UIColor.clear
        postContentView.clipsToBounds = true
        view.addSubview(postContentView)

        savePostBtn.style = .plain
        savePostBtn.title = "Edit"
        savePostBtn.action = #selector(editPost)

        self.navigationItem.rightBarButtonItem = savePostBtn

        postImage.frame = (CGRect(x: 10, y: 0, width: postContentView.frame.width - 20, height: postContentView.frame.height*0.40))
        postImage.contentMode = .scaleAspectFill
        postImage.layer.cornerRadius = 10.0
        postImage.clipsToBounds = true

        postContentView.addSubview(postImage)

        //        var x : CGFloat = 10
        //        var width : CGFloat = 20
        //
        if orientation != .portrait {
            //            x *= 4
            //            width *= 4
            postContentView.frame = (CGRect(x: 10, y: 44, width: screenWidth - 20, height: screenHeight - 60))
            postImage.frame = (CGRect(x: 0, y: 0, width: postContentView.frame.width, height: (postContentView.frame.height*0.75)))
        }

        postTitle.frame = (CGRect(x: 10, y: postContentView.frame.height*0.41, width: postContentView.frame.width - 20, height: postContentView.frame.height*0.06))
        postTitle.textColor = UIColor.white
        postTitle.font = UIFont(name: "AvenirNext-Medium", size: 25.0)
        postContentView.addSubview(postTitle)
        
        postDate.frame = (CGRect(x: 10, y: postContentView.frame.height*0.46, width: postContentView.frame.width - 20, height: postContentView.frame.height*0.03))
        postDate.textColor = UIColor.white
        postDate.font = UIFont(name: "AvenirNext-MediumItalic", size: 12.0)
        postContentView.addSubview(postDate)
        
        postText.frame = (CGRect(x: 10, y: postContentView.frame.height*0.50, width: postContentView.frame.width - 20, height: postContentView.frame.height*0.40))
        postText.isEditable = false
        postText.isSelectable = true
        postText.textColor = UIColor.white
        postText.backgroundColor = UIColor.clear
        postContentView.addSubview(postText)
        
        buttonView.frame = CGRect(x: 10, y: postContentView.frame.height*0.90, width: postContentView.frame.width - 20, height: postContentView.frame.height*0.10)
        buttonView.clipsToBounds = true
        postContentView.addSubview(buttonView)
        
        shareBtn.setImage(UIImage(named: "share"), for: .normal)
        shareBtn.addTarget(self, action: #selector(sharePost), for: .touchUpInside)
        shareBtn.frame = CGRect(x: 0, y: 15, width: 32, height: 32)
        buttonView.addSubview(shareBtn)

        locationBtn.setImage(UIImage(named: "location"), for: .normal)
        locationBtn.addTarget(self, action: #selector(postLocation), for: .touchUpInside)
        locationBtn.frame = CGRect(x: buttonView.frame.width - 32, y: 15, width: 32, height: 32)
        buttonView.addSubview(locationBtn)
    }

    @objc func setupUI() {
        guard !orientation.isFlat else { return }
        setupBackground()
        addViewPostUI()
    }

    @objc func sharePost() {
        
    }

    @objc func postLocation() {
        
    }
    
    @objc func editPost() {
        
    }
    
    func SetPostData(description:[String:Any]) {
        postTitle.text = description["postTitle"] as? String
        postDate.text = description["postDate"] as? String
        postText.text = description["postText"] as? String
        print("SetPostData")
    }
    
    func setPostImg(img:UIImage) {
        postImage.image = img
        print("SetPostImg")
    }
}
