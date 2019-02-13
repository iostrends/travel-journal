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
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    let myTripsData = TripData()
    var currentPosts = [Post]()
    var searchBar = UISearchBar()
    var tripTitle = ""
    var currentUser = ""
    var postId = ""
    var collectionView : UICollectionView!
    
    private var backgroundImage = UIImage(named: "background2")
    private var blurEffectStyle = UIBlurEffect(style: UIBlurEffect.Style.dark)
    lazy private var backgroundImageView = UIImageView(image: backgroundImage)
    lazy private var blurEffectView = UIVisualEffectView(effect: blurEffectStyle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationItem.rightBarButtonItem = addNewTripButton
        myTripsData.dataDel = self
        NotificationCenter.default.addObserver(self, selector: #selector(rotationHappened), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        laddaDB()
        setupCustomBackground(backgroundImageView: backgroundImageView, blurEffectView: blurEffectView)
        setupCollectionView()
        laddaTabell()
        setupSearchBar()
    }

    @objc private func goToAddNewPostPressed() {
        let newPostViewController = NewPost()
        newPostViewController.currentUser = currentUser
        newPostViewController.tripTitle = tripTitle
        self.navigationController?.pushViewController(newPostViewController, animated: true)
    }
    
    func setupCollectionView() {
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let y = navbarHeight + statusbarHeight + 35
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - y), collectionViewLayout: UltravisualLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        if orientation != .portrait {
            collectionView.frame = CGRect(x: 10, y: y, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - y)
        }
    }
    
    @objc func rotationHappened() {
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let y = navbarHeight + statusbarHeight + 35
        
        collectionView.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - y)
        setupCustomBackground(backgroundImageView: backgroundImageView, blurEffectView: blurEffectView)
        view.addSubview(collectionView)
        setupSearchBar()
        if orientation != .portrait {
            collectionView.frame = CGRect(x: 10, y: y, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - y)
        }
        
    }
    
    func laddaTabell() {
        currentPosts = myTripsData.posts
        collectionView.reloadData()
    }
    
    func laddaDB() {
        myTripsData.posts.removeAll()
        myTripsData.loadPostsByTrip(user: currentUser,tripTitle: tripTitle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Hide keyboard on hitting return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension PostsCollectionViewController {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPosts.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PostCell", for: indexPath)
            as? PostCollectionViewCell else {
                return UICollectionViewCell()
        }
        let post = currentPosts[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let date = formatter.string(from: post.postDate)
        
        cell.imageView.image = post.postImg
        cell.titleLabel.text = post.postTitle
        cell.dateLabel.text = date
        postId = post.postId
        
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
            viewPost.postId = currentPosts[indexPath.row].postId
            self.navigationController?.pushViewController(viewPost, animated: true)
        }
    }
}

extension PostsCollectionViewController : UISearchBarDelegate {
    private func setupSearchBar(){
        searchBar.delegate = self
        guard let navbarHeight = self.navigationController?.navigationBar.bounds.size.height else {return}
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        
        let y = navbarHeight + statusbarHeight
        searchBar.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: 30)
        searchBar.searchBarStyle = .minimal
        view.addSubview(searchBar)
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentPosts = myTripsData.posts
            collectionView.reloadData()
            return
            
        }
        currentPosts = myTripsData.posts.filter({ post -> Bool in
            
            return post.postTitle.lowercased().contains(searchText.lowercased())
        })
        collectionView.reloadData()
    }
    
}
