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
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation!
    private var userLatitude = 0.0
    private var userLongitude = 0.0
    let alertAccessDenied = PresentAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBellCleanersMap()
    }
    
    private func setupBellCleanersMap() {
        mapView.delegate = self
        mapView.showsScale = true        
        let bellCoordinates = CLLocationCoordinate2DMake(Constants.Coordinates.BellLatitude, Constants.Coordinates.BellLongitude)
        let bellSpan: MKCoordinateSpan = MKCoordinateSpanMake(Constants.Coordinates.SpanLatitudeDelta, Constants.Coordinates.SpanLongitudeDelta)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(bellCoordinates, bellSpan)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = bellCoordinates
        annotation.title = Constants.Literals.BellCleaners
        annotation.subtitle = Constants.Literals.ExpertGarmentCare
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
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
                let userLatitudeString = String(format: Constants.Literals.DecimalPlaces, userLatitude)
                let userLongitudeString = String(format: Constants.Literals.DecimalPlaces, userLongitude)
                let userLocationString = userLatitudeString + Constants.Literals.Comma + userLongitudeString
                let routeToBell = URL(string: Constants.Literals.URLPrefix + userLocationString + Constants.Literals.URLSuffix)
                manager.stopUpdatingLocation()
                guard let routeURL = routeToBell else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(routeURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(routeURL)
                }
            }
        }
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            setupAuthorizeWhenInUse()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            alertAccessDenied.presentSettingsActionAlert(fromController: self, title: Constants.Alerts.Titles.Location,
                         message: Constants.Alerts.Messages.Location,
                         actionTitle: Constants.Alerts.Actions.OK)
        }
    }
    
    @IBAction func didTapDirections(_ sender: DirectionsButton) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    @IBAction func didTapCallBell(_ sender: CallBellButton) {
        callBellButton.callBell()
    }    
}
