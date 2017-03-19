//
//  TrackingViewController.swift
//  Navty
//
//  Created by Edward Anchundia on 3/15/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import GoogleMaps
import PubNub

class TrackingViewController: UIViewController, PNObjectEventListener, GMSMapViewDelegate {

    private var client: PubNub!
    private var location = [CLLocation]()
    private var path = GMSMutablePath()
    private var polyline = GMSPolyline()
    private var currentPositionMarker = GMSMarker()
    private var isFirstMessage = true
    private var channel = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        setupMap()
        
        alertForChannel()
        
        setupPubNub()
        
        
    }

    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.09024, longitude: -95.712891, zoom: 3.0)
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
    }
    
    func setupPubNub() {
        let configuration = PNConfiguration(publishKey: "pub-c-28163faf-5853-487e-8cc9-1d8f955ad129", subscribeKey: "sub-c-0ee17ac4-08cb-11e7-b95c-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        print("this is the clients channel: \(client.channels())")
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        let recievedMessage = message.data.message as! [String: Double]
        let lat: CLLocationDegrees! = recievedMessage["lat"]
        let lng: CLLocationDegrees! = recievedMessage["lng"]
        let alt: CLLocationDegrees! = recievedMessage["alt"]
        let newLocation2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let newLocation = CLLocation(coordinate: newLocation2D, altitude: alt, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date.distantFuture)
        
        if self.isFirstMessage {
            self.initializePolylineAnnotation()
            self.isFirstMessage = false
        }
        
        self.updateOverlay(currentPosition: newLocation)
        self.updateMapFrame(newLocation: newLocation, zoom: 17.0)
        self.updateCurrentPositionMarker(currentLocation: newLocation)
    }
    
    func initializePolylineAnnotation() {
        self.polyline.strokeColor = .blue
        self.polyline.strokeWidth = 5.0
        self.polyline.map = self.mapView
    }
    
    func updateOverlay(currentPosition: CLLocation) {
        self.path.add(currentPosition.coordinate)
        self.polyline.path = self.path
    }
    
    func updateMapFrame(newLocation: CLLocation, zoom: Float) {
        let camera = GMSCameraPosition.camera(withTarget: newLocation.coordinate, zoom: zoom)
        self.mapView.animate(to: camera)
    }
    
    func updateCurrentPositionMarker(currentLocation: CLLocation) {
        self.currentPositionMarker.map = nil
        self.currentPositionMarker = GMSMarker(position: currentLocation.coordinate)
        self.currentPositionMarker.icon = GMSMarker.markerImage(with: UIColor.cyan)
        self.currentPositionMarker.map = self.mapView
    }
    
    func alertForChannel() {
        let alert = UIAlertController(title: "Channel Name", message: "Enter Channel:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "Channel Here"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.channel = (textField?.text)!
            print(self.channel)
            self.client.subscribeToChannels(["\(self.channel)"], withPresence: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        return mapView
    }()

}
