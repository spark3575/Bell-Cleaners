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
    private var userLatitude = CLLocationDegrees()
    private var userLongitude = CLLocationDegrees()
    private let alertAccessDenied = PresentAlert()
    
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
            if let userCoordinates = manager.location?.coordinate {
                userLatitude = userCoordinates.latitude
                userLongitude = userCoordinates.longitude
            }
            let userLatitudeString = String(format: Constants.Literals.DecimalPlaces, userLatitude)
            let userLongitudeString = String(format: Constants.Literals.DecimalPlaces, userLongitude)
            let userLocationString = userLatitudeString + Constants.Literals.Comma + userLongitudeString
            let appleMapsRouteToBell = URL(string: Constants.URLs.AppleMaps.BellURLPrefix + userLocationString + Constants.URLs.AppleMaps.BellURLSuffix)
            let googleMapsRouteToBell = URL(string: Constants.URLs.GoogleMaps.BellURLPrefix + userLocationString + Constants.URLs.GoogleMaps.BellURLSuffix)
            manager.stopUpdatingLocation()
            guard let appleMapsRouteURL = appleMapsRouteToBell else { return }
            guard let googleMapsRouteURL = googleMapsRouteToBell else { return }
            let mapChoiceAlert = UIAlertController(title: Constants.Alerts.Titles.MapAppsAvailable, message: nil, preferredStyle: .alert)
            let appleMapsAction = UIAlertAction(title: Constants.Alerts.Actions.AppleMaps, style: .default, handler: { action in
                UIApplication.shared.open(appleMapsRouteURL, options: [:], completionHandler: nil)
            })
            let googleMapsAction = UIAlertAction(title: Constants.Alerts.Actions.GoogleMaps, style: .default, handler: { action in
                UIApplication.shared.open(googleMapsRouteURL, options: [:], completionHandler: nil)
            })
            mapChoiceAlert.addAction(appleMapsAction)
            mapChoiceAlert.addAction(googleMapsAction)
            if (UIApplication.shared.canOpenURL(URL(string:Constants.URLs.Google)!)) {
                present(mapChoiceAlert, animated: true, completion: nil)
                return
            }            
            UIApplication.shared.open(appleMapsRouteURL, options: [:], completionHandler: nil)
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
