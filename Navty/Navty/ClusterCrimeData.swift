//
//  ClusterCrimeData.swift
//  Navty
//
//  Created by Edward Anchundia on 3/8/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import GoogleMaps

class ClusterCrimeData: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var crime: CrimeData
    
    init(position: CLLocationCoordinate2D, name: String, crime: CrimeData) {
        self.position = position
        self.name = name
        self.crime = crime
    }
}
