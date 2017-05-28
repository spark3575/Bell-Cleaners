//
//  MapVC.swift
//  Bell Cleaners
//
//  Created by Shin Park on 5/24/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callBellButton: CallBellButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBellCleanersMap()
    }
    
    private func setupBellCleanersMap() {
        mapView.delegate = self
        mapView.showsScale = true
        
        let bellCoordinates = CLLocationCoordinate2DMake(bellLatitude, bellLongitude)
        let bellSpan: MKCoordinateSpan = MKCoordinateSpanMake(bellSpanLatitudeDelta, bellSpanLongitudeDelta)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(bellCoordinates, bellSpan)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = bellCoordinates
        annotation.title = bellAnnotationTitle
        annotation.subtitle = bellAnnotationSubtitle
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation!
    private var userLatitude = userLat
    private var userLongitude = userLon
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {        
        func setupAuthorizeWhenInUse() {
            manager.startUpdatingLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            let userCoordinates = (manager.location?.coordinate)!
            
            if userCoordinates.latitude != 0 && userCoordinates.longitude != 0 {
                userLatitude = userCoordinates.latitude
                userLongitude = userCoordinates.longitude
            }
            
            if userCoordinates.latitude != 0 && userCoordinates.longitude != 0 {
                let userLatitudeString = String(format: decimalPlacesFormat, userLatitude)
                let userLongitudeString = String(format: decimalPlacesFormat, userLongitude)
                
                let userLocationString = userLatitudeString + separatingComma + userLongitudeString
                let routeToBell = URL(string: routeToBellURLPrefix + userLocationString + routeToBellURLSuffix)
                
                manager.stopUpdatingLocation()
                
                guard let routeURL = routeToBell else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(routeURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(routeURL)
                }
            }
        }
        
        let alertDeniedAccess = PresentAlert()
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            setupAuthorizeWhenInUse()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            alertDeniedAccess.presentAlert(fromController: self, title: locationServiceAlertTitle,
                         message: locationServiceAlertMessage,
                         actionTitle: okAlertActionTitle)
        }
    }
    
    @IBAction func directionsPressed(_ sender: DirectionsButton) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    @IBAction func callBellPressed(_ sender: CallBellButton) {
        callBellButton.callBell()
    }
}
