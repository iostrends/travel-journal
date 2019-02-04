//
//  ViewController.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-09.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UPCarouselFlowLayout
import FirebaseAuth

class MyTrips: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DataDelegate {
    
    let myTripsData = TripData()
    var collectionView : UICollectionView!
    fileprivate var currentPage: Int = 0 {
        didSet {
            print("Currentpage:\(currentPage)")
        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var currentUser = ""
    
    @objc fileprivate func rotationDidChange() {
        guard !orientation.isFlat else { return }
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let direction: UICollectionView.ScrollDirection = orientation.isPortrait ? .horizontal : .vertical
        layout.scrollDirection = .horizontal
        layout.itemSize = direction == .horizontal ? CGSize(width: 350, height: 500) : CGSize(width: 320, height: 320)
        collectionView.frame = UIScreen.main.bounds
        backgroundImage()
        if currentPage > 0 {
            let indexPath = IndexPath(item: currentPage, section: 0)
            let scrollPosition: UICollectionView.ScrollPosition = orientation.isPortrait ? .centeredHorizontally : .centeredVertically
            self.collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
        }
        collectionView.flashScrollIndicators()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    func backgroundImage() {
        let backgroundImage = UIImage(named: "planeCloud2")
        let imageView = UIImageView(image: backgroundImage)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        imageView.addSubview(blurEffectView)
        
        self.collectionView.backgroundView = imageView
        
    }
    
    var addNewTripButton : UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTripPressed))
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.clear
        self.title = "My Trips"
        navigationItem.rightBarButtonItem = addNewTripButton
        let backItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutUser))
        navigationItem.leftBarButtonItem = backItem
        
        currentUser = Auth.auth().currentUser?.email ?? "User not found"
        myTripsData.dataDel = self
        setupCarousel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyTrips.rotationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func logOutUser() {
        do{
            
            try Auth.auth().signOut()
            uploadSuccessMessage()
            
        } catch {
            print("Error")
        }
    }
    
    func uploadSuccessMessage(){
        let alert = UIAlertController(title: "Logga ut", message: "Du är nu utloggad", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            
            // Returns to root viewcontroller
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupCarousel() {
        let layout = UPCarouselFlowLayout()
        let direction: UICollectionView.ScrollDirection = orientation.isPortrait ? .horizontal : .vertical
        layout.scrollDirection = direction
        layout.itemSize = direction == .horizontal ? CGSize(width: 320, height: 480) : CGSize(width: 320, height: 320)
        layout.sideItemScale = 0.8
        layout.sideItemAlpha = 1
        layout.spacingMode = .fixed(spacing: 20)
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.flashScrollIndicators()
        collectionView.register(UINib(nibName: "TripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyTripCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.currentPage = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        laddaDB()
        laddaTabell()
        backgroundImage()
    }
    
    @objc func addNewTripPressed() {
        let newTripViewController = NewTrip()
        self.navigationController?.pushViewController(newTripViewController, animated: true)
    }
    
    func laddaTabell() {
        collectionView.reloadData()
    }
    
    func laddaDB() {
        myTripsData.trips.removeAll()
        myTripsData.loadTrips(user: currentUser)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let postsVC = PostsCollectionViewController()
        
        postsVC.tripTitle = myTripsData.trips[indexPath.row].tripTitle
        postsVC.currentUser = currentUser
        
        self.navigationController?.pushViewController(postsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myTripsData.trips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyTripCell", for: indexPath) as! TripCollectionViewCell
        
        cell.tripImage.image = self.myTripsData.trips[indexPath.row].tripImg
        cell.tripTitle.text = self.myTripsData.trips[indexPath.row].tripTitle
        cell.tripDate.text = self.myTripsData.trips[indexPath.row].tripDate
        
        return cell
    }
    
    
}

