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
    var currentPosts = [Post]()
    var searchBar = UISearchBar()
    var tripTitle = ""
    var currentUser = ""
    var postId = ""
    var collectionView : UICollectionView!
    var backgroundImageView = UIImageView()
    var backgroundImage = UIImage()
    var blurEffectStyle = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()
    
    var touch = UILongPressGestureRecognizer()
    
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
        setupSearchBar()
        NotificationCenter.default.addObserver(self, selector: #selector(rotationHappened), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        laddaDB()
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
        currentPosts = myTripsData.posts
        collectionView.reloadData()
    }
    
    func laddaDB() {
        myTripsData.posts.removeAll()
        myTripsData.loadPostsByTrip(user: currentUser,tripTitle: tripTitle)
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
        cell.imageView.image = post.postImg
        cell.titleLabel.text = post.postTitle
        cell.dateLabel.text = post.postDate
        postId = post.postId
        
        touch.addTarget(self, action: #selector(deleteMessage))
        touch.minimumPressDuration = 2
        cell.addGestureRecognizer(touch)
        
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
    
    @objc func deletePost() {
        let cell = touch.view as! UICollectionViewCell
        let itemIndex = self.collectionView.indexPath(for: cell)!.item
        myTripsData.removeFromDB(collection: "Posts", id: postId)
        myTripsData.posts.remove(at: itemIndex)
        currentPosts.remove(at: itemIndex)
        self.collectionView.reloadData()
    }
    
    @objc func deleteMessage(){
        let alert = UIAlertController(title: NSLocalizedString("Remove post", comment: ""), message: NSLocalizedString("Are you sure you want to remove this post?", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Back", comment: ""), style: .cancel, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .destructive, handler: { _ in
            self.deletePost()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension PostsCollectionViewController : UISearchBarDelegate {
    private func setupSearchBar(){
        
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 60, width: UIScreen.main.bounds.width, height: 30)
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
