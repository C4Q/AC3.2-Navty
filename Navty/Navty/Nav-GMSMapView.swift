//
//  Nav-GMSMapView.swift
//  Navty
//
//  Created by Kadell on 3/18/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation
import GoogleMaps

extension NavigationMapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let markerItem = marker.userData as? ClusterCrimeData {
            
            print("Did tap marker for cluster item \(markerItem.name)")
        } else {
            print("Did tap a normal marker")
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if polyline == nil{
            
            longPressMarker.map = nil
            
            longPressMarker =  GMSMarker(position: coordinate)
            longPressMarker.map = mapView
            
            
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

    
}
