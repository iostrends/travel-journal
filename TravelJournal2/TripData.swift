//
//  TripData.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-24.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD

protocol TripDelegate {
    func SetTripData(description:[String: Any])
    func setTripImg(img:UIImage)
}

protocol PostDelegate {
    func SetPostData(description:[String: Any])
    func setPostImg(img:UIImage)
}

protocol DataDelegate {
    func laddaTabell()
}

struct Trip {
    var tripId = ""
    var tripTitle = ""
    var tripDate = ""
    var tripImgURL = ""
    var tripImg: UIImage?
}

struct Post {
    var postId = ""
    var tripTitle = ""
    var postTitle = ""
    var postImg : UIImage?
    var postImgURL = ""
    var postText = ""
    var postDate = ""
    var lat = ""
    var long = ""
}

class TripData {
    var tripDel: TripDelegate?
    var postDel: PostDelegate?
    var dataDel: DataDelegate?
    
    var trips:[Trip] = []
    var posts:[Post] = []
    
    var oneTrip = Trip()
    var onePost = Post()
    
    var filteredPosts : [Post] = []
    
    func uploadData() {
        var imgName = oneTrip.tripTitle.replacingOccurrences(of: " ", with: "_")
        imgName = oneTrip.tripTitle.replacingOccurrences(of: "&", with: "")
        imgName = imgName.lowercased()
        
        let db = Firestore.firestore()
        var dataDict = [
            "tripTitle": oneTrip.tripTitle,
            "tripDate": oneTrip.tripDate,
            ]
        
        if oneTrip.tripImg != nil {
            dataDict["tripImg"] = imgName + ".jpg"
        }
        
        db.collection("Trips").document().setData(dataDict) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("Dokument sparat")
                if self.oneTrip.tripImg != nil { self.uploadImage(imgName: imgName) }
            }
        }
    }
    
    func uploadImage(imgName:String) {
        if let image = oneTrip.tripImg {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 375, height: 180), false, 0.0)
            let ratio = image.size.width/image.size.height
            let scaleWidth = ratio*375
            let offsetX = (scaleWidth-375)/2
            image.draw(in: CGRect(x: -offsetX, y: 0, width: scaleWidth, height: 180))
            let tripImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let jpegData = tripImg?.jpegData(compressionQuality: 0.7) {
                let storageRef = Storage.storage().reference()
                let imgRef = storageRef.child(imgName+".jpg")
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                
                imgRef.putData(jpegData, metadata: metaData) { (metaData, error) in
                    guard metaData != nil else{
                        print(error!)
                        return
                    }
                    print("image uploaded")
                    self.uploadImage(imgName: imgName)
                }
            }
        }
    }
    
    func loadTrips() {
        SVProgressHUD.show()
        let db = Firestore.firestore()
        var trip = Trip()
        
        db.collection("Trips").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else {
                guard let qSnapshot = querySnapshot else {return}
                for document in qSnapshot.documents {
                    trip.tripId = document.documentID
                    trip.tripTitle = document.data()["tripTitle"]as? String ?? ""
                    trip.tripDate = document.data()["tripDate"]as? String ?? ""
                    trip.tripImgURL = document.data()["tripImg"]as? String ?? ""
                    
                    self.trips.append(trip)
                    print("TripDB \(trip)")
                }
                self.loadImage()
            }
        }
    }
    
    func loadImage() {
        let storageRef = Storage.storage().reference()
        var i = 0
        for (index, trip) in trips.enumerated() {
            let imgRef = storageRef.child(trip.tripImgURL)
            imgRef.getData(maxSize: 1024*1024) { (data, error) in
                if let error = error {
                    print(error)
                } else {
                    if let imgData = data {
                        let tripImg = UIImage(data: imgData)
                        self.trips[index].tripImg = tripImg
                        i+=1
                    }
                }
                SVProgressHUD.dismiss()
                if (i == self.trips.count) {
                    self.dataDel?.laddaTabell()
                }
            }
        }
    }
    
    func loadPostImage(imgUrl: String) {
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child(imgUrl)
        imgRef.getData(maxSize: 1024*1024) { (data, error) in
            if let error = error {
                print(error)
            } else {
                if let imgData = data {
                    if let postImg = UIImage(data: imgData) {
                        self.postDel?.setPostImg(img:postImg)
                    }
                }
            }
            SVProgressHUD.dismiss()
            
        }
    }
    
    func loadOnePost(postId : String){
        SVProgressHUD.show()
        let db = Firestore.firestore()
        let docRef = db.collection("Posts").document(postId)
        docRef.getDocument { (document,error) in
            if let document = document, document.exists {
                if let dataDescription = document.data() {
                    self.postDel?.SetPostData(description: dataDescription)
                    print("datadesc", dataDescription)
                    if let imgUrl = dataDescription["postImg"] as? String {
                        print("imgUrl")
                        self.loadPostImage(imgUrl: imgUrl)
                    } else {
                        SVProgressHUD.dismiss()
                    }
                }
            } else {
                print("No document")
            }
        }
    }
    
    func loadPostsByTrip(tripTitle: String){
        
    }
    
    func uploadPost() {
        var imgName = onePost.postTitle.replacingOccurrences(of: " ", with: "_")
        imgName = onePost.postTitle.replacingOccurrences(of: "&", with: "")
        imgName = imgName.lowercased()
        
        let db = Firestore.firestore()
        var dataDict = [
            "tripTitle": onePost.tripTitle,
            "postTitle": onePost.postTitle,
            "postText": onePost.postText,
            "postDate": onePost.postDate
            ]
        
        if onePost.postImg != nil {
            dataDict["postImg"] = imgName + ".jpg"
        }
        
        db.collection("Posts").document().setData(dataDict) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("Dokument sparat")
                if self.onePost.postImg != nil { self.uploadPostImage(imgName: imgName) }
            }
        }
    }
    
    func uploadPostImage(imgName:String) {
        if let image = onePost.postImg {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 375, height: 180), false, 0.0)
            let ratio = image.size.width/image.size.height
            let scaleWidth = ratio*375
            let offsetX = (scaleWidth-375)/2
            image.draw(in: CGRect(x: -offsetX, y: 0, width: scaleWidth, height: 180))
            let postImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let jpegData = postImg?.jpegData(compressionQuality: 0.7) {
                let storageRef = Storage.storage().reference()
                let imgRef = storageRef.child(imgName+".jpg")
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                
                imgRef.putData(jpegData, metadata: metaData) { (metaData, error) in
                    guard metaData != nil else{
                        print(error!)
                        return
                    }
                    print("image uploaded")
                    self.uploadImage(imgName: imgName)
                }
            }
        }
    }

    func updatePost(id: String){
        
    }
}

