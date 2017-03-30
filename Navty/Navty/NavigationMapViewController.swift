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

class NavigationMapViewController: UIViewController, PNObjectEventListener {
    
    let messageComposer = MessageComposer()
    var animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear , animations: nil)
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
    var uuid = ""
    
    var region = CLCircularRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor.white
        
        setupViewHierarchy()
        setupToolbar()
        setupViews()
        
        locationManager.delegate = self
        searchDestination.delegate = self
        
        mapView.delegate = self
        locationManager.startUpdatingLocation()
        
        sideMenu()
        clustering()
        
        setupNotificationForKeyboard()
        
        let configuration = PNConfiguration(publishKey: "pub-c-28163faf-5853-487e-8cc9-1d8f955ad129", subscribeKey: "sub-c-0ee17ac4-08cb-11e7-b95c-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.isNavigationBarHidden = true
        
        self.searchDestination.endEditing(false)
        
        transportationIndicator.backgroundColor = .white
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        transportationIndicator.backgroundColor = .clear
        
    }
    
    
    
    //MARK: VIEW HIERARCHY & VIEWS CONSTRAINTS
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)) )
        
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
        view.addSubview(navigationContainer)
        
        navigationContainer.addSubview(startNavigation)
        
        navigationController?.toolbar.addSubview(carView)
        navigationController?.toolbar.addSubview(walkingView)
        navigationController?.toolbar.addSubview(bikeView)
        navigationController?.toolbar.addSubview(publicTransportView)
        navigationController?.toolbar.addSubview(transportationIndicator)
        
        timerContainer.addGestureRecognizer(recognizer)
        timerContainer.addSubview(timerLabel)
    }
    
    
    func setupViews() {
        
        
        menuButton.snp.makeConstraints({ (view) in
            view.centerY.equalTo(searchDestinationButton)
            view.leading.equalToSuperview().inset(8)
            view.width.equalTo(37)
            view.height.equalTo(45)
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
        

        navigationContainer.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview().multipliedBy(1.65)
            view.height.width.equalTo(50)
            view.trailing.equalToSuperview().offset(-12)

        }
        
        startNavigation.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        
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
            view.height.equalTo(0)
        }
        
        bikeView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.equalTo(walkingView.snp.trailing)
            view.width.equalToSuperview().multipliedBy(0.25)
            view.height.equalTo(0)
            
        }
        
        publicTransportView.snp.makeConstraints { (view) in
            view.top.equalToSuperview()
            view.leading.equalTo(bikeView.snp.trailing)
            view.width.equalToSuperview().multipliedBy(0.25)
            view.height.equalTo(0)
            
        }
        
        transportationIndicator.snp.makeConstraints { (view) in
            view.top.equalTo(walkingView.snp.bottom)
            view.width.equalToSuperview().multipliedBy(0.25)
            view.height.equalToSuperview().multipliedBy(0.05)
            view.leading.trailing.equalTo(walkingView)
            view.height.equalTo(0)
        }
        
        timerLabel.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        
    }
    
    //MARK: SIDE MENU
    func sideMenu() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: MenuViewController())
        
        menuLeftNavigationController.leftSide = true
        
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
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
        
                navigationContainer.isHidden = false
    }
    
    func searchBarPressed(button: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    
    
    
    func distanceTimeConversionToSeconds(time: String) {
        let times = time.components(separatedBy: " ")
        var seconds = 0
        
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
                            
                            self.polyline = GMSPolyline(path: self.path)
                            self.polyline?.title = self.directions[eachOne].overallTime
                            
                            
                            let time = self.directions[eachOne].overallTime
                            self.distanceTimeConversionToSeconds(time: time)
                            self.eta = time
                            
                            self.polyline?.strokeWidth = 5
                            self.polyline?.strokeColor = self.colors[eachOne]
                            self.polyline?.isTappable = true
                            self.polyline?.geodesic = true
                            
                            self.allPolyLines.append(self.polyline!)
                            
                            self.allPolyLines[eachOne].map = self.mapView
                            
                            self.directionsTableView.reloadData()
                            
                        }
                    }
                }
            }
        }
    }
    
    //MARK: -Setup Toolbar
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
        navigationController?.toolbar.barTintColor = ColorPalette.bgColor
        navigationController?.toolbar.tintColor = .white
        
    }
    
    //MARK: -Transportation Picker
    func transportationPick(sender: UIButton) {
        _ = self.allPolyLines.map { $0.map = nil }
        allPolyLines = []
        self.polylineUpdated.map = nil
        
        if polyline == nil {
            
            
            print("cant select transportation")
        } else {
            switch sender.tag {
            case 0:
                
                self.transportationIndicator.snp.remakeConstraints({ (view) in
                    
                    view.top.equalTo(self.carView.snp.bottom)
                    view.height.equalToSuperview().multipliedBy(0.05)
                    view.leading.trailing.equalTo(self.carView)
                })
                
                
                animator.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animator.startAnimation()
                
                self.transportationPicked = "driving"
                self.getPolylines(coordinates: self.newCoordinates)
            case 1:
                
                self.transportationIndicator.snp.remakeConstraints({ (view) in
                    
                    view.top.equalTo(self.walkingView.snp.bottom)
                    view.height.equalToSuperview().multipliedBy(0.05)
                    view.leading.trailing.equalTo(self.walkingView)
                })
                
                
                animator.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animator.startAnimation()
                
                
                self.transportationPicked = "walking"
                self.getPolylines(coordinates: self.newCoordinates)
            case 2:
                
                
                self.transportationIndicator.snp.remakeConstraints({ (view) in
                    
                    view.top.equalTo(self.bikeView.snp.bottom)
                    view.height.equalToSuperview().multipliedBy(0.05)
                    view.leading.trailing.equalTo(self.bikeView)
                })
                
                
                animator.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animator.startAnimation()
                
                
                self.transportationPicked = "bicycling"
                self.getPolylines(coordinates: self.newCoordinates)
            case 3:
                
                self.transportationIndicator.snp.remakeConstraints({ (view) in
                    
                    view.top.equalTo(self.publicTransportView.snp.bottom)
                    view.height.equalToSuperview().multipliedBy(0.05)
                    view.leading.trailing.equalTo(self.publicTransportView)
                })
                
                
                animator.addAnimations {
                    self.navigationController?.toolbar.layoutIfNeeded()
                }
                
                animator.startAnimation()
                
                
                self.transportationPicked = "transit"
                self.getPolylines(coordinates: self.newCoordinates)
            default:
                break
            }
        }
    }
    
    
    
    //MARK: MENU BUTTON
    func buttonPressed () {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        
        
    }
    

    
    func startNavigationClicked() {
        //animate table view up
        //change format of the map
        let uuid = NSUUID().uuidString
        print(uuid)
        self.uuid = uuid
        //demo channel name 
        //CA9570E1-80E3-4090-B622-C93E07312434
        
        if timerCountingDown == false {
            
           
            
            
            
            searchDestinationButton.isHidden = true
            cancelNavigationButton.isHidden = false
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            
            timerLabel.isHidden = false
            
            
            
            self.directionsTableView.isHidden = false
            timerCountingDown = true
        }
                navigationContainer.isHidden = true
//        startNavigation.isHidden = true

        UITableView.animate(withDuration: 1.0, animations: { () -> Void in
            
            self.directionsTableView.snp.makeConstraints({ (view) in
                view.leading.trailing.bottom.equalToSuperview()
                view.height.equalToSuperview().multipliedBy(0.5)
                
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
            
            //MARK:DEMO CODE
            self.client.subscribeToChannels(["CA9570E1-80E3-4090-B622-C93E07312434"], withPresence: true)
                
                if self.messageComposer.canSendText() {
                    let messageComposerVC = self.messageComposer.configuredMessageComposeViewController()
                    _ = NSMutableAttributedString(string: "\(uuid)")
                    
                    //Change to demo channel
                    messageComposerVC.body = "Track me at navtyapp.com/?id=CA9570E1-80E3-4090-B622-C93E07312434."
                    //"Track me using channel name: \(Settings.shared.channelName), on the  Navty app or at navtyapp.com"
                    
                    self.navigationController?.present(messageComposerVC, animated: true, completion: nil)
                } else {
                    print("Cant present")
                }

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
        
        if seconds < 60 {
            if dispSeconds < 10 {
                return "\(minutes) : 0\(dispSeconds)"
            }else {
                return "\(dispSeconds)"
            }
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
                return "\(hours) : \(dispMinutes) : \(dispSeconds)"
            }
        }
        
    }
    
    func cancelNavigation() {
        print("cancelled")
        //hide table view
        //stop timer
        
        directionsTableView.isHidden = true
        cancelNavigationButton.isHidden = true
        searchDestinationButton.isHidden = false
        searchDestinationButton.setTitle("Enter Destination", for: .normal)
        searchDestinationButton.setTitleColor(ColorPalette.lightGrey, for: .normal)
        
                navigationContainer.isHidden = true
        
        self.marker.map = nil
        self.allPolyLines.forEach({ $0.map = nil })
        self.allPolyLines = []
        self.polylineUpdated.map = nil
        self.polyline = nil
        
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
    
    
    internal lazy var timerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.bgColor
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    internal lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.backgroundColor = ColorPalette.bgColor
        label.textColor = .white
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
        button.layer.borderColor = ColorPalette.bgColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.setTitle("Enter Destination", for: .normal)
        button.setTitleColor(ColorPalette.lightGrey, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(searchBarPressed(button:)), for: .touchUpInside)
        button.backgroundColor = .white
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
        searchBar.layer.borderColor = ColorPalette.bgColor.cgColor
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
//        button.isHidden = true
        return button
    }()
    
    internal lazy var navigationContainer: UIButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.alpha = 0.8
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        view.layer.cornerRadius = 0.5 * view.bounds.size.width
        view.clipsToBounds = true
        view.isHidden = true
        return view
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

