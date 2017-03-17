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
import StringExtensionHTML
import MapKit
import GooglePlaces
import PubNub
import UserNotifications

class NavigationMapViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PNObjectEventListener,GMUClusterRendererDelegate {
    
    let messageComposer = MessageComposer()
//, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var animator = UIViewPropertyAnimator(duration: 3.0, curve: .linear , animations: nil)
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
    var polyline: GMSPolyline? = nil
    var allPolyLines = [GMSPolyline]()
    var availablePaths = [GMSPath]()

    var addressLookUp = String()
    var marker = GMSMarker()
    var markerAwayFromPoint = GMSMarker()
    var longPressMarker = GMSMarker()

    var colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.white]
    
    var transportationPicked = "walking"
    var currentlocation = CLLocationCoordinate2D()
    var newCoordinates = CLLocationCoordinate2D()
    
    var searched: Bool = false
    var adjustedPath = [GoogleDirections]()
    var availablePath = GMSPath()
    var polylineUpdated = GMSPolyline()
    var pathOf = GMSPath()
    
    var timer = Timer()
    var countDown = 0
    var eta = String()
    var timerCountingDown: Bool = false
    
    var clusterManager: GMUClusterManager!
    
    var resultsArray = [String]()
    var gestureRegonizer = UIGestureRecognizer()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
    var client: PubNub!
    //var trackingEnabled = false
    var channel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        setupViewHierarchy()
        setupToolbar()
        setupViews()

        locationManager.delegate = self
        searchDestination.delegate = self
       
        mapView.delegate = self
        locationManager.startUpdatingLocation()
        
        self.view.backgroundColor = UIColor.white
        sideMenu()
        clustering()
        
        setupNotificationForKeyboard()
        
        let configuration = PNConfiguration(publishKey: "pub-c-28163faf-5853-487e-8cc9-1d8f955ad129", subscribeKey: "sub-c-0ee17ac4-08cb-11e7-b95c-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)

        //self.client.subscribeToChannels(["map-channel"], withPresence: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.isNavigationBarHidden = true
       
        self.searchDestination.endEditing(false)
        
        transportationIndicator.backgroundColor = .white
        print("viewwillappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        transportationIndicator.backgroundColor = .clear
        print("viewwilldisappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("hello")
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        
        UITableView.animate(withDuration: 1.0, animations: { () -> Void in

            self.directionsTableView.snp.remakeConstraints({ (view) in
                view.leading.trailing.equalToSuperview()
                view.height.equalTo(0)
                view.bottom.equalTo(self.mapView.snp.bottom)
            })
        
        })
    
        GMSMapView.animate(withDuration: 1.0) {
            self.mapView.snp.remakeConstraints({ (view) in
                view.leading.trailing.top.equalToSuperview()
                view.height.equalToSuperview()
            })
        }

        
        startNavigation.isHidden = false
    }
    
    func panGesturePressed(recognizer: UIPanGestureRecognizer) {
        UITableView.animate(withDuration: 1.0, animations: { () -> Void in
            
            self.directionsTableView.snp.remakeConstraints({ (view) in
                view.leading.trailing.equalToSuperview()
                view.height.equalTo(0)
                view.bottom.equalTo(self.mapView.snp.bottom)
            })
            
        })
        
        GMSMapView.animate(withDuration: 1.0) {
            self.mapView.snp.remakeConstraints({ (view) in
                view.leading.trailing.top.equalToSuperview()
                view.height.equalToSuperview()
            })
        }
        
        startNavigation.isHidden = false
    }
    
    //MARK: VIEW HIERARCHY & VIEWS CONSTRAINTS
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)) )
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesturePressed(recognizer:)))
//        let swipe = UISwipeGestureRecognizerDirection.down
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
        view.addSubview(searchDestinationButton)
        view.addSubview(cancelNavigationButton)
        
       
        view.addSubview(directionsTableView)
        view.addSubview(startNavigation)
        
        navigationController?.toolbar.addSubview(carView)
        navigationController?.toolbar.addSubview(walkingView)
        navigationController?.toolbar.addSubview(bikeView)
        navigationController?.toolbar.addSubview(publicTransportView)
        
        navigationController?.toolbar.addSubview(transportationIndicator)
        timerLabel.addGestureRecognizer(recognizer)
    }
    
    
    func setupViews() {
        
        
        menuButton.snp.makeConstraints({ (view) in
            view.top.equalToSuperview().inset(30)
            view.leading.equalToSuperview().inset(8)
            view.width.equalTo(35)
            view.height.equalTo(42)
        })
        
        
        searchDestinationButton.snp.makeConstraints({ (view) in
            view.width.equalToSuperview().multipliedBy(0.8)
            view.leading.equalTo(menuButton.snp.trailing).offset(10)
            view.top.equalToSuperview().inset(30)
        })
        
        cancelNavigationButton.snp.makeConstraints({ (view) in
            view.width.height.equalTo(35)
            view.top.equalToSuperview().inset(30)
            view.trailing.equalToSuperview().inset(8)
            
        })
        
        startNavigation.snp.makeConstraints({ (view) in
            view.bottom.equalToSuperview()
            view.centerX.equalToSuperview()
            view.height.width.equalTo(50)
        })
        
        
        directionsTableView.snp.makeConstraints({ (view) in
            view.leading.trailing.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.5)
            view.top.equalTo(mapView.snp.bottom)
        })
        
        
        
        carView.snp.makeConstraints{(view) in
            view.top.leading.equalToSuperview()
            view.width.equalToSuperview().multipliedBy(0.25)
            
        }
        
        walkingView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.equalTo(carView.snp.trailing)
            view.width.equalToSuperview().multipliedBy(0.25)
        }
        
        bikeView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.equalTo(walkingView.snp.trailing)
            view.width.equalToSuperview().multipliedBy(0.25)
        }
        
        publicTransportView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.equalTo(bikeView.snp.trailing)
            view.width.equalToSuperview().multipliedBy(0.25)
        }
        
        transportationIndicator.snp.makeConstraints { (view) in
            view.top.equalTo(walkingView.snp.bottom)
            view.width.equalToSuperview().multipliedBy(0.25)
            view.height.equalToSuperview().multipliedBy(0.05)
            view.leading.trailing.equalTo(walkingView)
        }
        
        
        
    }
    
    //MARK: SIDE MENU
    func sideMenu() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: MenuViewController())
        
        menuLeftNavigationController.leftSide = true
        
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
//        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
//        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .menuDissolveIn
    }

    //MARK: MOVE VIEWS WITH KEYBOARD
    func setupNotificationForKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func adjustForKeyboard(notification : Notification) {
        
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
//        if notification.name == NSNotification.Name.UIKeyboardWillHide {
//            self.transportationContainer.frame.origin.y += keyboardScreenEndFrame.height
//        } else {
//            transportationContainer.frame.origin.y -= keyboardScreenEndFrame.height
//        }
        
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
                            
                            
                            
                            //new cluster code
                            let position = CLLocationCoordinate2D(latitude: latitude! , longitude:longitude!)
                            let item = ClusterCrimeData(position: position, name: eachCrime.description, crime: eachCrime)
                            self.clusterManager.add(item)
                            

                            
                        }
                    }
                }
            }
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let markerItem = marker.userData as? ClusterCrimeData {
            print("Did tap marker for cluster item \(markerItem.name)")
        } else {
            print("Did tap a normal marker")
        }
        
        return false
    }

    
    func searchBarPressed(button: UIButton) {
        
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //MARK: SEARCHBAR
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchDestination.showsCancelButton = true
//        searchDestination.resignFirstResponder()
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)

}
    

    
    func distanceTimeConversionToSeconds(time: String) {
        let times = time.components(separatedBy: " ")
        var seconds = 0
        
        print(times)
        if times.count > 2 {
            guard let hour = Int(times[0]), let min = Int(times[2]) else { return }
            print(hour)
            print(min)
            seconds = hour * 60 * 60 + min * 60
            print(seconds)
        } else {
            guard let min = Int(times[0]) else { return }
            print(min)
            seconds = min * 60
        }
        
        self.countDown = seconds
    }
    


    internal var iconView: UIImage = {
        var view = UIImage(named: "Trekking Filled-50")
        return view!
    }()


    //MARK: TRANSPORTATION CONTAINER

    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if polyline == nil{
            
            longPressMarker.map = nil
            
            longPressMarker =  GMSMarker(position: coordinate)
            longPressMarker.map = mapView
            
           
//           
//            self.marker.map = nil
//            self.allPolyLines.forEach({ $0.map = nil })
//            self.allPolyLines = []
//            self.polyline = nil
//            self.longPressMarker.map = nil
//            
//            
//            self.polylineUpdated.map = nil
//            
//            startNavigation.isHidden = false
//            
//            geocoder.geocodeAddressString(addressLookUp, completionHandler: { (placemarks, error) -> Void in
//                if error != nil {
//                    dump(error)
//                } else if placemarks?[0] != nil {
//                    let placemark: CLPlacemark = placemarks![0]
//                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
//                    
//                    let bounds = GMSCoordinateBounds(coordinate: self.currentlocation, coordinate: coordinates)
//                    self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 19.0))
//                    
//                    self.newCoordinates = coordinates
//                    
//                    if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
//                        print("Not allowed")
//                        return
//                    }
//                    
//                    if CLLocationManager.authorizationStatus() != .authorizedAlways {
//                        print("Authorize us")
//                    }
//                    
//                    let region = CLCircularRegion(center: coordinates, radius: 15, identifier: "Destination")
//                    //                region.notifyOnEntry = true
//                    //                region.notifyOnExit = true
//                    
//                    var radius = region.radius
//                    if radius > self.locationManager.maximumRegionMonitoringDistance {
//                        radius = self.locationManager.maximumRegionMonitoringDistance
//                    }
//                    
//                    
//                    self.locationManager.startMonitoring(for: region)
//                    
//                    self.marker = GMSMarker(position: coordinates)
//                    self.marker.title = "\(placemark)"
//                    self.marker.map = self.mapView
//                    self.marker.icon = GMSMarker.markerImage(with: .blue)
//                    self.markerAwayFromPoint.icon = GMSMarker.markerImage(with: .blue)
//                    self.markerAwayFromPoint.map = self.mapView
//                    self.getPolylines(coordinates: coordinates)
//                    //self.mapView.animate(toLocation: coordinates)
//                    
//                    self.getPolylines(coordinates: self.newCoordinates)
//                    
//                }
//            })
            
            
//            searchDestination.text = "\(place.name )"
            
//            self.startNavigation.isHidden = false
        } else if polyline != nil && transportationPicked != "transit" {
            
            APIRequestManager.manager.getData(endPoint: "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.userLatitude),\(self.userLongitude)&destination=\(newCoordinates.latitude),\(newCoordinates.longitude)&region=es&mode=\(self.transportationPicked)&waypoints=via:\(coordinate.latitude)%2C\(coordinate.longitude)%7C&alternatives=true&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
            { (data) in
                
                if data != nil {
                    
                    
                    if let validData = GoogleDirections.getData(from: data!) {
                        
                        self.adjustedPath = validData
                        
                        DispatchQueue.main.async {
                            
                            self.polyline?.map = nil
                            self.polylineUpdated.map = nil
                            self.allPolyLines.forEach({ $0.map = nil })
                            self.allPolyLines = []
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
    
    
    
 
    func getPolylines(coordinates: CLLocationCoordinate2D) {
        APIRequestManager.manager.getData(endPoint: "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.userLatitude),\(self.userLongitude)&destination=\(coordinates.latitude),\(coordinates.longitude)&region=es&mode=\(self.transportationPicked)&alternatives=true&key=AIzaSyCbkeAtt4S2Cfkji1Z4SBY-TliAQ6QinDc")
        { (data) in
            
            if data != nil {
                
                if let validData = GoogleDirections.getData(from: data!) {
                    
                    self.directions = validData
                    
                    DispatchQueue.main.async {
                        //self.polyline.map = nil
                        
                        for eachOne in 0 ..< self.directions.count {
                            self.path = GMSPath(fromEncodedPath: self.directions[eachOne].overallPolyline)!
                            self.availablePaths.append(self.path)
                            //self.polyline = GMSPolyline(path: self.availablePaths[eachOne])
                            self.polyline = GMSPolyline(path: self.path)
                            self.polyline?.title = self.directions[eachOne].overallTime
                            
                            //                            self.countDown = Int(self.directions[eachOne].overallTime)
                            let time = self.directions[eachOne].overallTime
                            self.distanceTimeConversionToSeconds(time: time)
                            self.eta = time
                            
                            self.polyline?.strokeWidth = 7
                            self.polyline?.strokeColor = self.colors[eachOne]
                            self.polyline?.isTappable = true
                            //self.polyline.title = "\(self.colors[eachOne])"
                            self.allPolyLines.append(self.polyline!)
                            //self.polyline.map = self.mapView
                            self.allPolyLines[eachOne].map = self.mapView
                            
                            self.directionsTableView.reloadData()
                            
                        }
                    }
                }
            }
        }
    }

  
    func setupToolbar() {
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let carButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_drive_eta"), style: .plain, target: self, action: #selector(transportationPick(sender:)))
        let walkingButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_directions_walk"), style: .plain, target: self, action: #selector(transportationPick(sender:)))
        let cyclingButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_motorcycle"), style: .plain, target: self, action: #selector(transportationPick(sender:)))
        let trainButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_train"), style: .plain, target: self, action: #selector(transportationPick(sender:)))
        
        carButton.tag = 0
        walkingButton.tag = 1
        cyclingButton.tag = 2
        trainButton.tag = 3
        
        toolbarItems = [carButton, spacer, walkingButton, spacer, cyclingButton, spacer, trainButton]
        
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = ColorPalette.lightBlue
        navigationController?.toolbar.tintColor = .white
        
    }
    
    
    func transportationPick(sender: UIButton) {
        _ = self.allPolyLines.map { $0.map = nil }
        allPolyLines = []
        self.polylineUpdated.map = nil
        
        if polyline == nil {
            
            
            print("cant select transportation")
        } else {
            switch sender.tag {
            case 0:
                print("tag 0")
                
                let animatorOf = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
                    self.transportationIndicator.snp.remakeConstraints({ (view) in
                        
                        view.top.equalTo(self.carView.snp.bottom)
                        view.height.equalToSuperview().multipliedBy(0.05)
                        view.leading.trailing.equalTo(self.carView)
                    })
                })
                
                animatorOf.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animatorOf.startAnimation()
                
                self.transportationPicked = "driving"
                self.getPolylines(coordinates: self.newCoordinates)
            case 1:
                print("tag 1")
                
                let animatorOf = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
                    self.transportationIndicator.snp.remakeConstraints({ (view) in
                        
                        view.top.equalTo(self.walkingView.snp.bottom)
                        view.height.equalToSuperview().multipliedBy(0.05)
                        view.leading.trailing.equalTo(self.walkingView)
                    })
                })
                
                animatorOf.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animatorOf.startAnimation()
                
               
                self.transportationPicked = "walking"
                self.getPolylines(coordinates: self.newCoordinates)
            case 2:
                print("tag 2")
                
                
                let animatorOf = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
                    self.transportationIndicator.snp.remakeConstraints({ (view) in
                        
                        view.top.equalTo(self.bikeView.snp.bottom)
                        view.height.equalToSuperview().multipliedBy(0.05)
                        view.leading.trailing.equalTo(self.bikeView)
                    })
                })
                
                animatorOf.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animatorOf.startAnimation()
                
               
                self.transportationPicked = "bicycling"
                self.getPolylines(coordinates: self.newCoordinates)
            case 3:
                print("tag 3")
                
                
                let animatorOf = UIViewPropertyAnimator(duration: 0.3, curve: .linear, animations: {
                    self.transportationIndicator.snp.remakeConstraints({ (view) in
                        
                        view.top.equalTo(self.publicTransportView.snp.bottom)
                        view.height.equalToSuperview().multipliedBy(0.05)
                        view.leading.trailing.equalTo(self.publicTransportView)
                    })
                })
                
                animatorOf.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animatorOf.startAnimation()
                
               
                self.transportationPicked = "transit"
                self.getPolylines(coordinates: self.newCoordinates)
            default:
                break
            }
        }
    }

    
  
    //MARK: MENU BUTTON
    func buttonPressed () {
//        searchDestination.resignFirstResponder()
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        
    }
    
    func startNavigationClicked() {
        //animate table view up
        //change format of the map
        if timerCountingDown == false {
//            let alert = UIAlertController(title: "ETA", message: "You will arrive in \(eta).", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(ok)
//            self.navigationController?.present(alert, animated: true, completion: nil)
            
            searchDestinationButton.isHidden = true
            cancelNavigationButton.isHidden = false
            
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            
            
            timerLabel.isHidden = false
            

        
        self.directionsTableView.isHidden = false
        timerCountingDown = true
        }
        startNavigation.isHidden = true
        
        
        
        UITableView.animate(withDuration: 1.0, animations: { () -> Void in
            //            self.mapView.snp.makeConstraints({ (view) in
            //                view.leading.trailing.equalToSuperview()
            //                view.height.equalToSuperview().multipliedBy(0.5)
            //                view.top.equalToSuperview()
            //            })
            
            self.directionsTableView.snp.makeConstraints({ (view) in
                view.leading.trailing.bottom.equalToSuperview()
                view.height.equalToSuperview().multipliedBy(0.5)
//                view.bottom.equalTo(self.mapView.snp.bottom)
            })
        })
        
        GMSMapView.animate(withDuration: 1.0) { 
            self.mapView.snp.remakeConstraints({ (view) in
                view.leading.trailing.top.equalToSuperview()
                view.height.equalToSuperview().multipliedBy(0.5)
            })
        }
        
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: CLLocationDegrees(userLatitude), longitude: CLLocationDegrees(userLongitude)))
        
        if Settings.shared.trackingEnabled == true {
            let alert = UIAlertController(title: "Channel Name", message: "Enter Channel:", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textfield) in
                textfield.placeholder = "Channel Here"
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                Settings.shared.channelName = (textField?.text)!
                print(Settings.shared.channelName)
                self.client.subscribeToChannels([Settings.shared.channelName], withPresence: true)
            }))
            self.present(alert, animated: true, completion: nil)
            Settings.shared.channelInput = true
        }
        
        Settings.shared.navigationStarted = true
        
    }
    
    func updateCounter() {
        
            if countDown > 0 {
                print("\(countDown) seconds")
                self.timerLabel.text = String(convertToUsableTime(seconds: countDown))
                countDown -= 1
            } else {
                //alert if needs more time to get home
            }
        
    }
    
    func convertToUsableTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let hours = minutes / 60
        let dispMinutes = minutes % 60
        let dispSeconds = seconds % 60
        
        
//        let nothing = ""
        if seconds < 60 {
            return "0\(dispSeconds)"
        } else if seconds < 3600 {
            if dispSeconds < 10 {
            return "\(minutes) : 0\(dispSeconds)"
            } else {
            return "\(minutes) : \(dispSeconds)"
            }
        }
        else {
            if dispSeconds < 10 {
                return "\(hours) : \(dispMinutes) : 0\(dispSeconds)"
            } else {
        return "\(hours) : \(dispMinutes) : 0\(dispSeconds)"
            }
        }
//        return nothing
    }
    
    func cancelNavigation() {
        print("cancelled")
        //hide table view
        //stop timer
        
        directionsTableView.isHidden = true
        cancelNavigationButton.isHidden = true
        searchDestinationButton.isHidden = false
        startNavigation.isHidden = true
        
        self.marker.map = nil
        self.allPolyLines.forEach({ $0.map = nil })
        self.allPolyLines = []
        self.polylineUpdated.map = nil
        self.polyline = nil
        
//        self.searchDestination.text = ""
        
        mapView.animate(toLocation: self.currentlocation)
        
        //zoom into current location
        
        timer.invalidate()
        timerLabel.isHidden = true
        timerCountingDown = false
        
        GMSMapView.animate(withDuration: 1.0) {
            self.mapView.snp.remakeConstraints({ (view) in
                view.leading.trailing.top.equalToSuperview()
                view.height.equalToSuperview()
            })
        }

        Settings.shared.navigationStarted = false
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
        let stepDirection = direction?.directionInstruction[indexPath.row]
        let stepDistance = direction?.distanceForStep[indexPath.row]
        
        let swiftString = stepDirection?.html2AttributedString
        
        cell.directionLabel.numberOfLines = 0
        cell.directionLabel.attributedText = swiftString
        cell.directionTimeLabel.text = stepDistance
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return timerLabel
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
    
    internal var carView: UIView = {
        let view = UIView()
        return view
    }()
    
    internal var walkingView: UIView = {
        let view = UIView()
        return view
    }()
    
    internal var bikeView: UIView = {
        let view = UIView()
        return view
    }()

    internal var publicTransportView: UIView = {
        let view = UIView()
        return view
    }()
    
    internal var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isHidden = true
        view.contentSize = CGSize(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height )
        
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = true
        view.backgroundColor = .red
        return view
    }()
    
    internal var embeddedView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
    
        return view
    }()
    
   
    internal lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.backgroundColor = ColorPalette.bgColor
        return label
    }()
    
    internal lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_menu"), for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    
    internal lazy var searchDestinationButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = ColorPalette.lightBlue.cgColor
        button.layer.borderWidth = 1
        button.isUserInteractionEnabled = true
        button.setTitle(" Destination", for: .normal)
        button.setTitleColor( ColorPalette.lightGrey  , for: .normal)
        button.titleLabel?.font = UIFont(name: "ArialHebrew", size: 18)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(searchBarPressed(button:)), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        return button
    }()
    
    internal lazy var searchDestination: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = UIColor.white
        searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchBar.isTranslucent = false
        searchBar.barTintColor = .white
        searchBar.placeholder = "Destination"
        searchBar.isUserInteractionEnabled = true
        searchBar.layer.borderColor = ColorPalette.lightBlue.cgColor
        searchBar.layer.borderWidth = 1
        return searchBar
    }()
    
    internal var transportationIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 3.0
     
        return view
    }()

    
    internal lazy var startNavigation: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_navigation"), for: .normal)
        button.addTarget(self, action: #selector(self.startNavigationClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    internal lazy var cancelNavigationButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        button.addTarget(self, action: #selector(cancelNavigation), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    internal lazy var directionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DirectionsTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentSize.height = 200
        tableView.bounces = false
        tableView.rowHeight = UITableViewAutomaticDimension
        return tableView
    }()
}

extension String {
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue, NSDefaultAttributesDocumentAttribute: [NSFontAttributeName: UIFont.italicSystemFont(ofSize: 32)]], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}



extension NavigationMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized")
//            manager.stopUpdatingLocation()
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
        
        //MARK: - Should apply breaking point to Nav for the moment
        guard let locationValue: CLLocationCoordinate2D = (manager.location?.coordinate) else { return }
        
        userLatitude =  Float(locationValue.latitude)
        userLongitude = Float(locationValue.longitude)
        
        self.currentlocation = locationValue
        
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude))
        if Settings.shared.navigationStarted != false {
            if Settings.shared.trackingEnabled != false {
                let message = "{\"lat\":\(validLocation.coordinate.latitude),\"lng\":\(validLocation.coordinate.longitude), \"alt\": \(validLocation.altitude)}"
                print(message)
                self.client.publish(message, toChannel: Settings.shared.channelName, compressed: false, withCompletion: { (status) in
                    if !status.isError {
                        print("Sucess")
                    } else {
                        print("Error: \(status)")
                    }
                })
            }
        }
        
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


}

extension NavigationMapViewController: GMSAutocompleteViewControllerDelegate {
    

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressLookUp = place.name
        print(addressLookUp)
        self.marker.map = nil
        self.allPolyLines.forEach({ $0.map = nil })
        self.allPolyLines = []
        self.polyline = nil
        self.longPressMarker.map = nil

        
        self.polylineUpdated.map = nil
        
        startNavigation.isHidden = false
        
        geocoder.geocodeAddressString(addressLookUp, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                dump(error)
            } else if placemarks?[0] != nil {
                let placemark: CLPlacemark = placemarks![0]
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                let bounds = GMSCoordinateBounds(coordinate: self.currentlocation, coordinate: coordinates)
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 19.0))
                
                self.newCoordinates = coordinates
                
                if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                    print("Not allowed")
                    return
                }
                
                if CLLocationManager.authorizationStatus() != .authorizedAlways {
                    print("Authorize us")
                }
                
                let region = CLCircularRegion(center: coordinates, radius: 5, identifier: "Destination")
                //                region.notifyOnEntry = true
                //                region.notifyOnExit = true
                
                var radius = region.radius
                if radius > self.locationManager.maximumRegionMonitoringDistance {
                    radius = self.locationManager.maximumRegionMonitoringDistance
                }
                
                
                self.locationManager.startMonitoring(for: region)
        
                self.marker = GMSMarker(position: coordinates)
                self.marker.title = "\(placemark)"
                self.marker.map = self.mapView
                self.marker.icon = GMSMarker.markerImage(with: .blue)
                self.markerAwayFromPoint.icon = GMSMarker.markerImage(with: .blue)
                self.markerAwayFromPoint.map = self.mapView
                self.getPolylines(coordinates: coordinates)
                //self.mapView.animate(toLocation: coordinates)
                
                self.getPolylines(coordinates: self.newCoordinates)
                
            }
        })

        
        searchDestinationButton.setTitle("\(place.name )", for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        searchDestination.text = nil
        
        self.marker.map = nil
        self.allPolyLines.forEach({ $0.map = nil })
        self.allPolyLines = []
        self.polyline = nil
//        self.locationManager.stopMonitoring(for: region)
        
      self.searchDestination.endEditing(true)
       
        self.polylineUpdated.map = nil
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension NavigationMapViewController: GMUClusterManagerDelegate {
    
    func clustering() {
        var image: [UIImage] = []
        for _ in 0...4 {
            image.append(#imageLiteral(resourceName: "ic_warning"))
        }
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        getData()
        clusterManager.cluster()
        clusterManager.setDelegate(self, mapDelegate: self)
        
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
//        if let crimeData = marker.userData as? ClusterCrimeData {
//            
//            var dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            dateFormatter.dateStyle = .full
//            let d = TimeInterval(1467345600)
//            
//            
//                var cDate = crimeData.crime.crimeDate
//                var sDate = dateFormatter.date(from: cDate)
//                if (sDate?.timeIntervalSince1970)! >= d {
//                    marker.icon = UIImage(named: "Map Pin-20")
//                } else {
//                    marker.icon = UIImage(named: "Map BPin-20")
//            }
//        }
    }
    
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if true {
            let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
            let update = GMSCameraUpdate.setCamera(newCamera)
            mapView.moveCamera(update)
        }
        
        return false
    }
}

extension NavigationMapViewController: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // some other way of handling notification
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        switch response.actionIdentifier {
        case "agree":
            
            //
            if (self.messageComposer.canSendText()) {
                
                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController()
                
                self.present(messageComposeVC, animated: true, completion: nil)
                
                
            }else{
                print("Can not present the View Controller")
            }
            
            //present(DetailViewController(), animated: true, completion: nil)
        //imageView.image = UIImage(named: "firstGuy")
        case "disagree":
            print("I disagree")
        default:
            break
        }
        
        completionHandler()
        
    }
}
