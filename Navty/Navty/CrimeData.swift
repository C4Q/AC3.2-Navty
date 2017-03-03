//
//  CrimeData.swift
//  Navty
//
//  Created by Kadell on 2/28/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation

class CrimeData {
    
    let boro: String
    let latitude: String
    let longitude: String
    let description: String
    
    init(boro: String, latitude: String, longitude: String, description: String) {
        self.boro = boro
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
    }
    
    convenience init?(from dict: [String:Any]) {
        let boro = dict["boro_nm"] as? String ?? "Unkown"
        let lat = dict["latitude"] as? String ?? "0"
        let long = dict["longitude"] as? String ?? "0"
        let description = dict["pd_desc"] as? String ?? "Unkown"
        
        self.init(boro: boro, latitude: lat, longitude: long, description: description)
    }
    
    static func getData(from arr: [[String:Any]]) -> [CrimeData] {
        var data = [CrimeData]()
        for info in arr {
            if let crimeData = CrimeData(from: info) {
                data.append(crimeData)
            }
        }
        return data
    }
    
}

