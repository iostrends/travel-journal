//
//  ShowMap.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-01-29.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ShowMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var mapView = MKMapView()
    var segControl = UISegmentedControl()
    
    var lat = ""
    var long = ""
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setupMapView), name: UIDevice.orientationDidChangeNotification, object: nil)
        setupMapView()
        showPin()
        mapView.delegate = self
        
        segControl.insertSegment(withTitle: NSLocalizedString("Standard", comment: ""), at: 0, animated: true)
        segControl.insertSegment(withTitle: NSLocalizedString("Satellite", comment: ""), at: 1, animated: true)
        segControl.selectedSegmentIndex = 0
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
    }
    
    @objc func setupMapView() {
        mapView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.addSubview(mapView)
        
        segControl.frame = CGRect(x: UIScreen.main.bounds.width - 160, y: UIScreen.main.bounds.height - 50, width: 140, height: 30)
        segControl.addTarget(self, action: #selector(changeMapStyle), for: .valueChanged)
        view.addSubview(segControl)
    }
    
    func showPin(){
        let distance = 200
        
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(
            latitude: CLLocationDegrees(lat) ?? 0.0,
            longitude: CLLocationDegrees(long) ?? 0.0),
                                             latitudinalMeters: CLLocationDistance(distance),
                                             longitudinalMeters: CLLocationDistance(distance)), animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(lat) ?? 0.0,
            longitude: CLLocationDegrees(long) ?? 0.0)
        
        mapView.addAnnotation(annotation)
    }
    
    @objc func changeMapStyle() {
        switch segControl.selectedSegmentIndex {
        case 1:
            //print("case 1")
            mapView.mapType = .satellite
            segControl.tintColor = UIColor.white
        default:
            mapView.mapType = .standard
            segControl.tintColor = nil
        }
    }
    
}

