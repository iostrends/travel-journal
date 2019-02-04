//
//  PostsCollectionViewController.swift
//  TravelJournal2
//
//  Created by Samuel Lavasani on 2019-01-28.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

class PostsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DataDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    var addNewTripButton : UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddNewPostPressed))
        return button
    }
    
    let myTripsData = TripData()
    var tripTitle = ""
    var currentUser = ""
    var collectionView : UICollectionView!
    var backgroundImageView = UIImageView()
    var backgroundImage = UIImage()
    var blurEffectStyle = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationItem.rightBarButtonItem = addNewTripButton
        myTripsData.dataDel = self
        backgroundImage = UIImage(named: "background2")!
        blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
        setupBackground()
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(rotationHappened), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        laddaDB()
        laddaTabell()
    }

    @objc private func goToAddNewPostPressed() {
        let newPostViewController = NewPost()
        newPostViewController.currentUser = currentUser
        newPostViewController.tripTitle = tripTitle
        self.navigationController?.pushViewController(newPostViewController, animated: true)
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UltravisualLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    func setupBackground() {
        //backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.frame = UIScreen.main.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.image = backgroundImage
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        view.addSubview(backgroundImageView)
    }
    
    @objc func rotationHappened() {
        collectionView.frame = UIScreen.main.bounds
        setupBackground()
        view.addSubview(collectionView)
        
    }
    
    func laddaTabell() {
        collectionView.reloadData()
    }
    
    func laddaDB() {
        myTripsData.posts.removeAll()
        myTripsData.loadPostsByTrip(user: currentUser,tripTitle: tripTitle)
    }
    
    
}

extension PostsCollectionViewController {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myTripsData.posts.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PostCell", for: indexPath)
            as? PostCollectionViewCell else {
                return UICollectionViewCell()
        }
        cell.imageView.image = myTripsData.posts[indexPath.row].postImg
        cell.titleLabel.text = myTripsData.posts[indexPath.row].postTitle
        cell.dateLabel.text = myTripsData.posts[indexPath.row].postDate
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        guard let layout = collectionView.collectionViewLayout
            as? UltravisualLayout else {
                return
        }
        let offset = layout.dragOffset * CGFloat(indexPath.item)
        
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(
                CGPoint(x: 0, y: offset), animated: true
            )
        } else {
            let viewPost = ViewPost()
            viewPost.postId = myTripsData.posts[indexPath.row].postId
            self.navigationController?.pushViewController(viewPost, animated: true)
        }
    }
}
