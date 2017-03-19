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
    let crimeDate: String
    let area: String
    
    
    init(boro: String, latitude: String, longitude: String, description: String, crimeDate: String, area: String) {
        self.boro = boro
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.crimeDate = crimeDate
        self.area = area
    }
    
    convenience init?(from dict: [String:Any]) {
        let boro = dict["boro_nm"] as? String ?? "Unkown"
        let crimeDate = dict ["cmplnt_fr_dt"] as? String ?? "No Date"
        let lat = dict["latitude"] as? String ?? "0"
        let long = dict["longitude"] as? String ?? "0"
        let description = dict["ofns_desc"] as? String ?? "Unkown"
        let area = dict["prem_typ_desc"] as? String ?? "Unkown"
        
        
        self.init(boro: boro, latitude: lat, longitude: long, description: description, crimeDate: crimeDate, area: area)
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

