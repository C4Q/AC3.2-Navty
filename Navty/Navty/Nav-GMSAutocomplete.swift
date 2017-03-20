//
//  Nav-GMSAutocomplete.swift
//  Navty
//
//  Created by Kadell on 3/18/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation
import GooglePlaces

extension NavigationMapViewController: GMSAutocompleteViewControllerDelegate {
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressLookUp = place.formattedAddress!
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
                
                var radius = region.radius
                if radius > self.locationManager.maximumRegionMonitoringDistance {
                    radius = self.locationManager.maximumRegionMonitoringDistance
                }
                
                
                self.locationManager.startMonitoring(for: region)
                self.region = region
                
                self.marker = GMSMarker(position: coordinates)
                self.marker.title = "\(placemark)"
                self.marker.map = self.mapView
                self.marker.icon = GMSMarker.markerImage(with: .blue)
                self.markerAwayFromPoint.icon = GMSMarker.markerImage(with: .blue)
                self.markerAwayFromPoint.map = self.mapView
                self.getPolylines(coordinates: coordinates)
                
                self.getPolylines(coordinates: self.newCoordinates)
                
            }
        })
        
        
        searchDestinationButton.setTitle("\(place.name)", for: .normal)
        searchDestinationButton.setTitleColor(.black, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.locationManager.stopMonitoring(for: region)
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        searchDestination.text = nil
        
        self.marker.map = nil
        self.allPolyLines.forEach({ $0.map = nil })
        self.allPolyLines = []
        self.polyline = nil
        //self.locationManager.stopMonitoring(for: region)
        
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

