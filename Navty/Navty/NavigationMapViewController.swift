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
import MapKit



class NavigationMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var userLatitude = Float()
    var userLongitude = Float()
    var zoomLevel: Float = 15.0
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
    var allPolyLines = [GMSPolyline]()
    var availablePaths = [GMSPath]()

    var addressLookUp = String()
    var marker = GMSMarker()
    var markerAwayFromPoint = GMSMarker()

    var colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.white]
    
    var transportationPicked = "walking"
    var currentlocation = CLLocationCoordinate2D()
    var newCoordinates = CLLocationCoordinate2D()
    
    var searched: Bool = false
    var adjustedPath = [GoogleDirections]()
    var availablePath = GMSPath()
    var polylineUpdated = GMSPolyline()
    var pathOf = GMSPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        setupViewHierarchy()
        setupViews()

        locationManager.delegate = self
        searchDestination.delegate = self
        mapView.delegate = self
        locationManager.startUpdatingLocation()
        
        
        self.view.backgroundColor = UIColor.white
        sideMenu()
//        getData()
//        getPolylines(coordinates: CLLocationCoordinate2D(latitude: 40.849595621347405, longitude: -73.918020075426583) )
        setupNotificationForKeyboard()
    }
    
    //MARK: SIDE MENU
    func sideMenu() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: MenuViewController())
        
        menuLeftNavigationController.leftSide = true
        
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        SideMenuManager.menuFadeStatusBar = false
    }

    //MARK: MOVE VIEWS WITH KEYBOARD
    func setupNotificationForKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func adjustForKeyboard(notification : Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            self.transportationContainer.frame.origin.y += keyboardScreenEndFrame.height
        } else {
            transportationContainer.frame.origin.y -= keyboardScreenEndFrame.height
        }
        
    }
    
    //MARK: CRIME DATA
    func getData() {
        APIRequestManager.manager.getData(endPoint: "https://data.cityofnewyork.us/resource/7x9x-zpz6.json") { (data) in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options: []),
                    let crimes = jsonData as? [[String: Any]] {
                    self.crimesNYC = CrimeData.getData(from: crimes)
                    
                    for eachCrime in self.crimesNYC {
                        guard eachCrime.latitude != "0" else {continue}
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
    
    

    //MARK: VIEW HIERARCHY & VIEWS CONSTRAINTS
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(userLatitude), longitude: CLLocationDegrees(userLongitude), zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("The style definition could not be loaded: \(error)")
        }
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        view.addSubview(menuButton)
        view.addSubview(searchDestination)
        view.addSubview(transportationContainer)
        view.addSubview(directionsTableView)
        
//        transportationContainer.addSubview(blur)
        transportationContainer.addSubview(drivingButton)
        transportationContainer.addSubview(cyclingButton)
        transportationContainer.addSubview(walkingButton)
        transportationContainer.addSubview(anotherButton)
        
        
    }
    
    func setupViews() {
        
       
        
        menuButton.snp.makeConstraints({ (view) in
            view.top.equalToSuperview().inset(30)
            view.leading.equalToSuperview().inset(8)
            view.width.equalTo(35)
            view.height.equalTo(42)
        })
        
        searchDestination.snp.makeConstraints({ (view) in
            view.width.equalToSuperview().multipliedBy(0.8)
            view.leading.equalTo(menuButton.snp.trailing).offset(10)
            view.top.equalToSuperview().inset(30)
        })
        
        transportationContainer.snp.makeConstraints({ (view) in
            view.width.equalToSuperview()
            view.centerX.equalToSuperview()
            view.trailing.leading.equalToSuperview()
            view.bottom.equalTo(self.view.snp.bottom)
            view.height.equalToSuperview().multipliedBy(0.09)
        })
        
//        blur.snp.makeConstraints({ (view) in
//            view.leading.equalTo(transportationContainer.snp.leading)
//            view.width.equalToSuperview()
//            view.height.equalTo(transportationContainer.snp.height)
//            view.bottom.equalTo(self.view.snp.bottom)
//        })
        
        drivingButton.snp.makeConstraints({ (view) in
//            view.leading.equalTo(transportationContainer.snp.leading).inset(12)
            view.leading.equalToSuperview()
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.5)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.25)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })
        
        walkingButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(drivingButton.snp.trailing)
//            .offset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.5)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.25)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })

        cyclingButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(walkingButton.snp.trailing)
//            .offset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.5)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.25)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })

        anotherButton.snp.makeConstraints({ (view) in
            view.leading.equalTo(cyclingButton.snp.trailing)
//            .offset(12)
            view.height.equalTo(transportationContainer.snp.height).multipliedBy(0.5)
            view.width.equalTo(transportationContainer.snp.width).multipliedBy(0.25)
            view.centerY.equalTo(transportationContainer.snp.centerY)
        })
        
        directionsTableView.snp.makeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.5)
            view.top.equalTo(mapView.snp.bottom)
        })
    }
    
    //MARK: CLLOCATION
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
        guard let locationValue: CLLocationCoordinate2D = (manager.location?.coordinate) else { return }
        
        userLatitude =  Float(locationValue.latitude)
        userLongitude = Float(locationValue.longitude)
        
        self.currentlocation = locationValue
        
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
    
    //MARK: SEARCHBAR
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchDestination.showsCancelButton = true
        
        mapView.settings.myLocationButton = false
//        fadeInView(view: transportationContainer, blur: blur, hidden: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        mapView.settings.myLocationButton = true
        searchDestination.resignFirstResponder()
//        fadeOutView(view: transportationContainer, blur: blur, hidden: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.addressLookUp = searchDestination.text!
        print("\(searchBar.text)")
        self.marker.map = nil
        self.allPolyLines.forEach({ $0.map = nil })
        self.allPolyLines = []
        searchDestination.resignFirstResponder()
        
        geocoder.geocodeAddressString(addressLookUp, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                dump(error)
            } else if placemarks?[0] != nil {
                let placemark: CLPlacemark = placemarks![0]
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                let bounds = GMSCoordinateBounds(coordinate: self.currentlocation, coordinate: coordinates)
                //let camera = self.mapView.camera(for: bounds, insets: .zero)
//                self.mapView.camera = camera!
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
                
                self.newCoordinates = coordinates
                
                
                if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                    print("Not allowed")
                    return
                }
                
                if CLLocationManager.authorizationStatus() != .authorizedAlways {
                    print("Authorize us")
                }
                
                let region = CLCircularRegion(center: coordinates, radius: 15, identifier: "Destination")
//                region.notifyOnEntry = true
//                region.notifyOnExit = true
                
                var radius = region.radius
                if radius > self.locationManager.maximumRegionMonitoringDistance {
                    radius = self.locationManager.maximumRegionMonitoringDistance
                }
                
                
               self.locationManager.startMonitoring(for: region)
               
                
                
                let alert = UIAlertController(title: "\(region)", message: "It worked?", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.navigationController?.present(alert, animated: true, completion: nil)


                self.marker = GMSMarker(position: coordinates)
                self.marker.title = "\(placemark)"
                self.marker.map = self.mapView
                self.marker.icon = GMSMarker.markerImage(with: .blue)

                self.mapView.animate(toLocation: coordinates)
//                
//                print("old coor: \(coordinates)")
//                self.markerAwayFromPoint = GMSMarker(position: self.locationWithBearing(bearing: 270, distanceMeters: 150, origin: coordinates))
//                self.markerAwayFromPoint.icon = GMSMarker.markerImage(with: .blue)
//                self.markerAwayFromPoint.map = self.mapView

                
                self.getPolylines(coordinates: self.newCoordinates)
                
            }
        })
        
    }
    

    //MARK: -Location Bearing
//            "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.userLatitude),\(self.userLongitude)&destination=\(coordinates.latitude),\(coordinates.longitude)&region=es&mode=\(self.transportationPicked)&alternatives=true&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
    func getPolylines(coordinates: CLLocationCoordinate2D) {
        APIRequestManager.manager.getData(endPoint: "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.userLatitude),\(self.userLongitude)&destination=\(coordinates.latitude),\(coordinates.longitude)&region=es&mode=\(self.transportationPicked)&alternatives=true&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
            { (data) in
            
        if data != nil {
                    
                    
            if let validData = GoogleDirections.getData(from: data!) {

                    self.directions = validData
                    
                    DispatchQueue.main.async {
                        
                        for eachOne in 0 ..< self.directions.count {
                            self.path = GMSPath(fromEncodedPath: self.directions[eachOne].overallPolyline)!
                            self.availablePaths.append(self.path)
                            self.polyline = GMSPolyline(path: self.availablePaths[eachOne])
                            self.polyline.strokeWidth = 7
                            self.polyline.strokeColor = self.colors[eachOne]
                            self.polyline.isTappable = true
                            self.polyline.title = "\(self.directions[eachOne].overallTime)"
                            self.allPolyLines.append(self.polyline)
                            self.allPolyLines[eachOne].map = self.mapView
  
                            
                            
                            self.directionsTableView.reloadData()

                        }
                    }
                }
            }
        }
    }
    

    internal var iconView: UIImage = {
        var view = UIImage(named: "Trekking Filled-50")
        return view!
    }()
//
//    internal var iconLabel: UILabel = {
//        var view = UILabel()
//        view.text = "TEST TEST"
//        return view
//    }()
//    
    
   //MARK -CLLManagerDelegates
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
         print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        let alert = UIAlertController(title: "In the Geo", message: "It worked?", preferredStyle: UIAlertControllerStyle.alert)
//                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
//                alert.addAction(ok)
//               self.present(alert, animated: true, completion: nil)
//
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        let alert = UIAlertController(title: "Out the Geo", message: "It worked?", preferredStyle: UIAlertControllerStyle.alert)
//        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
//        alert.addAction(ok)
//        self.present(alert, animated: true, completion: nil)
//    }
//    


    //MARK: TRANSPORTATION CONTAINER

    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if true {
            
            APIRequestManager.manager.getData(endPoint: "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.userLatitude),\(self.userLongitude)&destination=\(newCoordinates.latitude),\(newCoordinates.longitude)&region=es&mode=\(self.transportationPicked)&waypoints=via:\(coordinate.latitude)%2C\(coordinate.longitude)%7C&alternatives=true&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
            { (data) in
                
                if data != nil {
                    
                    
                    if let validData = GoogleDirections.getData(from: data!) {
                        
                        self.adjustedPath = validData
                        
                        DispatchQueue.main.async {
                            
                            self.polyline.map = nil
                            self.polylineUpdated.map = nil
                            for eachOne in 0 ..< self.adjustedPath.count {
                                
                                self.pathOf = GMSPath(fromEncodedPath: self.adjustedPath[eachOne].overallPolyline)!
                                self.availablePath = self.pathOf
                                
                                self.polylineUpdated = GMSPolyline(path: self.availablePath)
                                self.polylineUpdated.strokeWidth = 7
                                self.polylineUpdated.strokeColor = self.colors[eachOne]
                                
                                self.polylineUpdated.title = "\(self.colors[eachOne])"

                                self.polylineUpdated.map = self.mapView
                            }
                        }
                    }
                }
            }

            
        }
    }
    
    
    
    
    
    func transportationPick(sender: UIButton) {
        _ = self.allPolyLines.map { $0.map = nil }
        allPolyLines = []
        
        switch sender.tag {
        case 0:
            print("tag 0")
            self.transportationPicked = "driving"
            self.getPolylines(coordinates: self.newCoordinates)
        case 1:
            print("tag 1")
            self.transportationPicked = "walking"
            self.getPolylines(coordinates: self.newCoordinates)
        case 2:
            print("tag 2")
            self.transportationPicked = "bicycling"
            self.getPolylines(coordinates: self.newCoordinates)
        case 3:
            print("tag 3")
            self.transportationPicked = "transit"
            self.getPolylines(coordinates: self.newCoordinates)
        default:
            break
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print("\(overlay.title)")
        for polylines in allPolyLines {
//            polylines.strokeColor = UIColor.blue
            if overlay.title! == polylines.title {
                
//                polylines.strokeColor = UIColor.white
                print("changed")
            }
        }
    }
    
    //MARK: GETTING POINT AWAY FROM INITIAL POINT
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        //
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        
        //M_PI is constant of Pi, 3.1415.....
        let lat1 = origin.latitude * M_PI / 180
        let lon1 = origin.longitude * M_PI / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        let newCoordinate = CLLocationCoordinate2D(latitude: lat2 * 180 / M_PI, longitude: lon2 * 180 / M_PI)
        
        print("newCoordinate \(newCoordinate)")
        
        return newCoordinate
    }
    
    
  
    //MARK: MENU BUTTON
    func buttonPressed () {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        
    }
    
    //MARK: SETUP TABLE VIEW FOR DIRECTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for elements in 0..<directions.count {
            return directions[elements].directionInstruction.count
        }
        return directions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DirectionsTableViewCell
        
        let direction: GoogleDirections? = directions[0]
        
//        dump(self.directions[indexPath.row].directionInstruction[indexPath.row])
        
        cell.directionLabel.numberOfLines = 0
        cell.directionLabel.text = direction?.directionInstruction[indexPath.row]
        .trimmingCharacters(in: .init(charactersIn: "<>"))
        
        return cell
    }

    //MARK: ANIMATIONS
    func fadeOutView(view: UIView, blur: UIVisualEffectView, hidden: Bool) {
        UIView.transition(with: view, duration: 1.0, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = true
        }, completion: { _ in })
        
        UIVisualEffectView.transition(with: blur, duration: 1.0, options: .transitionCrossDissolve, animations: { () -> Void in
            blur.isHidden = true
        }, completion: { _ in })
    }
    
    func fadeInView(view: UIView, blur: UIVisualEffectView, hidden: Bool) {
        UIView.transition(with: view, duration: 1.0, options: .transitionCrossDissolve, animations: {() -> Void in
            view.isHidden = false
        }, completion: { _ in })
        
        UIVisualEffectView.transition(with: blur, duration: 1.0, options: .transitionCrossDissolve, animations: { () -> Void in
            blur.isHidden = false
        }, completion: { _ in })
    }
    
   //MARK: -Initalize Views

    
    lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        return mapView
    }()
    
    internal lazy var menuButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    
    internal lazy var searchDestination: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = UIColor.white
        searchBar.searchBarStyle = UISearchBarStyle.default
        searchBar.placeholder = "Desination"
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    internal lazy var drivingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.bgColor
        return view
    }()
    
    internal lazy var transportationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.bgColor
//        view.isHidden = true
        return view
    }()
    
    internal lazy var drivingButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
//        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Transportation Filled-50"), for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(transportationPick(sender:)), for: .touchUpInside)
        return button
    }()
    
    internal lazy var walkingButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
//        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Trekking Filled-50"), for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(transportationPick(sender:)), for: .touchUpInside)
        return button
    }()
    
    internal lazy var cyclingButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
//        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Cycling Road Filled-50"), for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(transportationPick(sender:)), for: .touchUpInside)
        return button
    }()
    
    internal lazy var anotherButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.white
//        button.layer.cornerRadius = 30
        button.setImage(#imageLiteral(resourceName: "Railway Station Filled-50"), for: .normal)
        button.tag = 3
        button.addTarget(self, action: #selector(transportationPick(sender:)), for: .touchUpInside)
        return button
    }()

    internal lazy var blur: UIVisualEffectView = {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
        var blurEffectView = UIVisualEffectView(effect: blur)
//        blurEffectView.isHidden = true
        return blurEffectView
    }()

    internal lazy var directionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DirectionsTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        return tableView
    }()
}
