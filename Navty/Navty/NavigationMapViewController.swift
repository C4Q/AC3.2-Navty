//
//  NavigationMapViewController.swift
//  Navty
//
//  Created by Edward Anchundia on 2/28/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import SideMenu

class NavigationMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    
    
    var userLatitude = Float()
    var userLongitude = Float()
    var zoomLevel: Float = 5.0
    let locationManager: CLLocationManager = {
        let locMan: CLLocationManager = CLLocationManager()
        locMan.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locMan.distanceFilter = 50.0
        return locMan
    }()
    let geocoder: CLGeocoder = CLGeocoder()

    
    var crimesNYC = [CrimeData]()
    var directions = [GoogleDirections]()
    
    var path = GMSPath()
    var polyline = GMSPolyline()


    var addressLookUp = String()
    var marker = GMSMarker()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        setupViews()

        locationManager.delegate = self
        searchDestination.delegate = self
        locationManager.startUpdatingLocation()
        
        
        self.view.backgroundColor = UIColor.white
        sideMenu()
//        getData()
    }
    
    func sideMenu() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: MenuViewController())
        menuLeftNavigationController.leftSide = true
        
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
//        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
//        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        SideMenuManager.menuFadeStatusBar = false
    }

    
    func getPolyline() {
        APIRequestManager.manager.getData(endPoint: "https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood4&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc") { (data) in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options: []),
                    let google = jsonData as? [String: Any] {
                    self.directions = GoogleDirections.getData(from: google)
                    dump(self.directions)
                    
                    DispatchQueue.main.async {
                        self.path = GMSPath(fromEncodedPath: self.directions[0].polyline)!
                        self.polyline = GMSPolyline(path: self.path)
                        self.polyline.strokeWidth = 7
                        self.polyline.strokeColor = .blue
                        self.polyline.map = self.mapView
                        
                    }
                }
            }
        }
    }
    
    func getData() {
        APIRequestManager.manager.getData(endPoint: "https://data.cityofnewyork.us/resource/7x9x-zpz6.json") { (data) in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options: []),
                    let crimes = jsonData as? [[String: Any]] {
                    self.crimesNYC = CrimeData.getData(from: crimes)
                    
                    for eachCrime in self.crimesNYC {
                        DispatchQueue.main.async {
                            let latitude = CLLocationDegrees(eachCrime.latitude)
                            let longitude = CLLocationDegrees(eachCrime.longitude )
                            let position = CLLocationCoordinate2D(latitude: latitude! , longitude:longitude! )
                            
                            let marker = GMSMarker(position: position)
                            marker.title = eachCrime.description
                            marker.map = self.mapView
                            }

                    }
                }
            }
        }
    }


    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(userLatitude), longitude: CLLocationDegrees(userLongitude), zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        view.addSubview(searchDestination)
        view.addSubview(transportationContainer)
        
        transportationContainer.addSubview(blur)
        transportationContainer.addSubview(drivingButton)
        transportationContainer.addSubview(cyclingButton)
        transportationContainer.addSubview(walkingButton)
        transportationContainer.addSubview(anotherButton)
    }
    
    func setupViews() {
        blur.snp.makeConstraints({ (view) in
            view.leading.trailing.width.height.equalTo(transportationContainer)
        })
        
        searchDestination.snp.makeConstraints({ (view) in
            view.width.equalToSuperview().multipliedBy(0.8)
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().inset(30)
        })
        
        transportationContainer.snp.makeConstraints({ (view) in
            view.width.equalToSuperview().multipliedBy(0.9)
            view.centerX.equalToSuperview()
            view.bottom.equalTo(self.view.snp.bottom)
            view.height.equalTo(75)
        })
        
        drivingButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(transportationContainer.snp.leading).inset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.8)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.2)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })
        
        walkingButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(drivingButton.snp.trailing).offset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.8)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.2)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })

        cyclingButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(walkingButton.snp.trailing).offset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.8)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.2)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })

        anotherButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(cyclingButton.snp.trailing).offset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.8)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.2)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized")
            manager.stopUpdatingLocation()
        case .denied, .restricted:
            print("Authorization denied or restricted")
        case .notDetermined:
            print("Authorization undetermined")
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        userLatitude = Float(coordinateRegion.latitude)
        userLongitude = Float(coordinateRegion.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let validLocation: CLLocation = locations.last else { return }
        let locationValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        userLatitude =  Float(locationValue.latitude)
        userLongitude = Float(locationValue.longitude)
        
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude))
        
        geocoder.reverseGeocodeLocation(validLocation) { (placemarks: [CLPlacemark]?, error: Error?) in
            //error handling
            if error != nil {
                dump(error!)
            }
            
            guard let validPlaceMarks: [CLPlacemark] = placemarks,
                let validPlace: CLPlacemark = validPlaceMarks.last else { return }
            print(validPlace)
        }
       
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchDestination.showsCancelButton = true
        
        mapView.settings.myLocationButton = false
        fadeInView(view: transportationContainer, hidden: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        mapView.settings.myLocationButton = true
        fadeOutView(view: transportationContainer, hidden: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.addressLookUp = searchDestination.text!
        print("\(searchBar.text)")
        self.marker.map = nil
        self.polyline.map = nil
        searchDestination.resignFirstResponder()
        
        geocoder.geocodeAddressString(addressLookUp, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                dump(error)
            } else if placemarks?[0] != nil {
                let placemark: CLPlacemark = placemarks![0]
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                self.marker = GMSMarker(position: coordinates)
                self.marker.title = "\(placemark)"
                self.marker.map = self.mapView
                self.marker.icon = GMSMarker.markerImage(with: .blue)
                self.mapView.animate(toLocation: coordinates)
                
                APIRequestManager.manager.getData(endPoint: "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.userLatitude),\(self.userLongitude)&destination=\(coordinates.latitude),\(coordinates.longitude)&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc") { (data) in
                    if let validData = data {
                        if let jsonData = try? JSONSerialization.jsonObject(with: validData, options: []),
                            let google = jsonData as? [String: Any] {
                            self.directions = GoogleDirections.getData(from: google)
                            dump(self.directions)
                            
                            DispatchQueue.main.async {
                                self.path = GMSPath(fromEncodedPath: self.directions[0].polyline)!
                                self.polyline = GMSPolyline(path: self.path)
                                self.polyline.strokeWidth = 7
                                self.polyline.strokeColor = .blue
                                self.polyline.map = self.mapView
                                
                            }
                        }
                    }
                }
                
            }
        })
        
    }
    
    func fadeOutView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 1.0, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = true
        }, completion: { _ in })
    }
    
    func fadeInView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 1.0, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = false
        }, completion: { _ in })
    }
    
    internal lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        return mapView
    }()
    
    internal lazy var searchDestination: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = UIColor.white
        searchBar.searchBarStyle = UISearchBarStyle.default
        searchBar.placeholder = "Desination"
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    internal lazy var transportationContainer: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.blue
        view.isHidden = true
        return view
    }()
    
    internal lazy var drivingButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Transportation Filled-50"), for: .normal)
        return button
    }()
    
    internal lazy var walkingButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Trekking Filled-50"), for: .normal)
        return button
    }()
    
    internal lazy var cyclingButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Cycling Road Filled-50"), for: .normal)
        return button
    }()
    
    internal lazy var anotherButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Railway Station Filled-50"), for: .normal)
        return button
    }()
    
    internal lazy var blur: UIVisualEffectView = {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
        var blurEffectView = UIVisualEffectView(effect: blur)
        return blurEffectView
    }()

}
