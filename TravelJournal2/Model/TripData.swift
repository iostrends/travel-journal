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
    var userEmail = ""
    var tripId = ""
    var tripTitle = ""
    var tripDate = Date()
    var tripImgURL = ""
    var tripImg: UIImage?
}

struct Post {
    var userEmail = ""
    var postId = ""
    var tripTitle = ""
    var postTitle = ""
    var postImg : UIImage?
    var postImgURL = ""
    var postText = ""
    var postDate = Date()
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
    var oldPostTitle = ""
    
    func uploadData(completion: @escaping (Bool) -> ()) {
        SVProgressHUD.show()
        var imgName = "\(oneTrip.tripTitle)_\(oneTrip.userEmail)"
        imgName = imgName.replacingOccurrences(of: " ", with: "")
        imgName = imgName.replacingOccurrences(of: "&", with: "")
        imgName = imgName.replacingOccurrences(of: ",", with: "")
        imgName = imgName.lowercased()
        
        let db = Firestore.firestore()
        var dataDict = [
            "userEmail": oneTrip.userEmail,
            "tripTitle": oneTrip.tripTitle,
            "tripDate": oneTrip.tripDate,
            ] as [String : Any]
        
        if oneTrip.tripImg != nil {
            dataDict["tripImg"] = imgName + ".jpg"
        }
        
        db.collection("Trips").document().setData(dataDict) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("Dokument sparat")
                if self.oneTrip.tripImg != nil { self.uploadImage(imgName: imgName) {(result) in
                     completion(true)
                    }}
            }
        }
    }
    
    func uploadImage(imgName:String, completion: @escaping (Bool) -> ()) {
        if let image = oneTrip.tripImg {
            if image.size.height < image.size.width {
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 320, height: 480), false, 0.0)
                let ratio = image.size.width/image.size.height
                let scaleWidth = ratio*320
                let offsetX = (scaleWidth-320)/2
                image.draw(in: CGRect(x: -offsetX, y: 0, width: scaleWidth, height: 480))
            } else {
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: 320, height: 260), false, 0.0)
                let ratio = image.size.width/image.size.height
                let scaleWidth = ratio*320
                let offsetX = (scaleWidth-320)/2
                image.draw(in: CGRect(x: -offsetX, y: 0, width: scaleWidth, height: 260))
            }
            
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
                    completion(true)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func loadTrips(user: String) {
        SVProgressHUD.show()
        let db = Firestore.firestore()
        var trip = Trip()
        
        db.collection("Trips").whereField("userEmail", isEqualTo: user).order(by: "tripDate", descending: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    guard let qSnapshot = querySnapshot else {return}
                    for document in qSnapshot.documents {
                        trip.userEmail = document.data()["userEmail"] as? String ?? ""
                        trip.tripId = document.documentID
                        trip.tripTitle = document.data()["tripTitle"] as? String ?? ""
                        trip.tripDate = document.data()["tripDate"] as! Date
                        trip.tripImgURL = document.data()["tripImg"] as? String ?? ""
                        
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
        if(trips.isEmpty) {
            SVProgressHUD.dismiss()
        }
    }
    
    func loadPostImage(imgUrl: String) {
        let storageRef = Storage.storage().reference()
        
        let imgRef = storageRef.child(imgUrl)
        imgRef.getData(maxSize: 1024*1024) { (data, error) in
            if let error = error {
                print(error)
                SVProgressHUD.dismiss()
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
                    self.oldPostTitle = dataDescription["postTitle"] as? String ?? ""

                    if let imgUrl = dataDescription["postImg"] as? String {
                        self.loadPostImage(imgUrl: imgUrl)
                    }
                }
            } else {
                print("No document")
            }
        }
    }
    
    func loadPostImages() {
        let storageRef = Storage.storage().reference()
        var i = 0
        for (index, post) in posts.enumerated() {
            let imgRef = storageRef.child(post.postImgURL)
            imgRef.getData(maxSize: 1024*1024) { (data, error) in
                if let error = error {
                    print(error)
                } else {
                    if let imgData = data {
                        let postImg = UIImage(data: imgData)
                        self.posts[index].postImg = postImg
                        i+=1
                    }
                }
                if (i == self.posts.count) {
                    self.dataDel?.laddaTabell()
                    SVProgressHUD.dismiss()
                }
            }
        }
        if(posts.isEmpty) {
            SVProgressHUD.dismiss()
        }
    }
    
    func loadPostsByTrip(user: String, tripTitle: String){
        SVProgressHUD.show()
        let db = Firestore.firestore()
        var post = Post()
        
        db.collection("Posts").whereField("tripTitle", isEqualTo: tripTitle).whereField("userEmail", isEqualTo: user).order(by: "postDate", descending: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    SVProgressHUD.dismiss()
                } else {
                    guard let qSnapshot = querySnapshot else {return}
                    for document in qSnapshot.documents {
                        post.userEmail = document.data()["userEmail"]as? String ?? ""
                        post.postId = document.documentID
                        post.tripTitle = document.data()["tripTitle"]as? String ?? ""
                        post.postTitle = document.data()["postTitle"]as? String ?? ""
                        post.postDate = document.data()["postDate"]as! Date
                        post.postText = document.data()["postText"]as? String ?? ""
                        post.postImgURL = document.data()["postImg"]as? String ?? ""
                        post.lat = document.data()["postLat"]as? String ?? ""
                        post.long = document.data()["postLong"]as? String ?? ""
                        
                        self.posts.append(post)
                    }
                    self.loadPostImages()
                }
        }

    }
    
    func uploadPost(completion: @escaping (Bool) -> ()) {
        SVProgressHUD.show()
        var imgName = "\(onePost.postTitle)_\(onePost.userEmail)"
        imgName = imgName.replacingOccurrences(of: " ", with: "")
        imgName = imgName.replacingOccurrences(of: "&", with: "")
        imgName = imgName.replacingOccurrences(of: ",", with: "")
        imgName = imgName.lowercased()
        
        let db = Firestore.firestore()
        var dataDict = [
            "userEmail": onePost.userEmail,
            "tripTitle": onePost.tripTitle,
            "postTitle": onePost.postTitle,
            "postText": onePost.postText,
            "postDate": onePost.postDate,
            "postLat": onePost.lat,
            "postLong": onePost.long
            ] as [String : Any]
        
        if onePost.postImg != nil {
            dataDict["postImg"] = imgName + ".jpg"
        }
        
        db.collection("Posts").document().setData(dataDict) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("Dokument sparat")
                if self.onePost.postImg != nil {
                    self.uploadPostImage(imgName: imgName, completion: { (result) in
                        completion(true)
                    })
                }
            }
        }
    }
    
    func uploadPostImage(imgName:String, completion: @escaping (Bool) -> ()) {
        if let image = onePost.postImg {
            let width = image.size.width/8
            let height = image.size.height/8
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            let postImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let jpegData = postImg?.jpegData(compressionQuality: 0.9) {
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
                    completion(true)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }

    func updatePost(postId: String, newImage: Bool, completion: @escaping (Bool) -> ()){
        var imgName = "\(onePost.postTitle)_\(onePost.userEmail)"
        imgName = imgName.replacingOccurrences(of: " ", with: "")
        imgName = imgName.replacingOccurrences(of: "&", with: "")
        imgName = imgName.replacingOccurrences(of: ",", with: "")
        imgName = imgName.lowercased()

        let db = Firestore.firestore()
        
        var dataDict = [
            "postTitle": onePost.postTitle,
            "postText": onePost.postText,
            "postDate": onePost.postDate
            ] as [String : Any]

        if onePost.postImg != nil {
            dataDict["postImg"] = imgName + ".jpg"
        }
        
        db.collection("Posts").document(postId).updateData(dataDict) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("Dokument sparat")
                if self.onePost.postImg != nil {
                    newImage ? self.uploadPostImage(imgName: imgName, completion: { (result) in
                        completion(true)
                    })
                    : self.updateImage(imgName: imgName, completion: { (result) in
                        completion(true)
                    })
                }
                if self.onePost.postTitle != self.oldPostTitle { self.deleteOldImage(oldPostTitle: self.oldPostTitle) }
            }
        }
    }
    
    func updateImage(imgName: String, completion: @escaping (Bool) -> ()) {
        if let image = onePost.postImg {
            if let jpegData = image.jpegData(compressionQuality: 0.7) {
                let storageRef = Storage.storage().reference()
                let imgRef = storageRef.child(imgName+".jpg")
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                
                imgRef.putData(jpegData, metadata: metaData) { (metaData, error) in
                    guard metaData != nil else{
                        print(error!)
                        return
                    }
                    print("image updated")
                    completion(true)
                }
            }
        }
    }
    
    func deleteOldImage(oldPostTitle: String) {
        var imgName = "\(self.oldPostTitle)_\(onePost.userEmail)"
        imgName = imgName.replacingOccurrences(of: " ", with: "")
        imgName = imgName.replacingOccurrences(of: "&", with: "")
        imgName = imgName.replacingOccurrences(of: ",", with: "")
        imgName = imgName.lowercased()
        
        let storageRef = Storage.storage().reference()
        let deleteImg = storageRef.child("\(imgName).jpg")
        
        deleteImg.delete { error in if let error = error {
            print(error)
        } else {
            print("old image deleted", deleteImg)
            }
            
        }
    }
    
    func removeFromDB(collection: String, id: String) {
        let db = Firestore.firestore()
        
        db.collection(collection).document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}

