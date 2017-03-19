//
//  Nav-CLLocationManager.swift
//  Navty
//
//  Created by Kadell on 3/18/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation


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
                self.client.publish(message, toChannel: "\(UserDefaults.standard.value(forKey: "ApplicationIdentifier")!)", compressed: false, withCompletion: { (status) in
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
