//
//  GoogleDirections.swift
//  Navty
//
//  Created by Kadell on 3/1/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation

class GoogleDirections {

//    let instruction: String
    let polyline: String
    
    
//    init(instruction: String , polyline: String) {
//        self.instruction = instruction
//        self.polyline = polyline
//    }
    
    init(polyline: String) {
        self.polyline = polyline
    }

    
//    convenience init?(from json: [String: Any]) {
//        let manever = json["maneuver"] as? String ?? ""
//        let polyline = json["points"] as? String ?? ""
//        
//        
//        self.init(instruction: manever, polyline: polyline)
//    }
    
    convenience init?(from route: [String:Any]) {
        let polyline = route["points"] as? String ?? ""
        
        self.init(polyline: polyline)
    }

//    static func getData(from dict: [String:Any]) -> [GoogleDirections] {
//        var data = [GoogleDirections]()
//        
//        let route = dict["routes"] as! [[String: Any]]
//        for item in route {
//            let legs = item["legs"] as! [[String: Any]]
//            
//            for info in legs {
//                let steps = info["steps"] as! [[String:Any]]
//                
//                for step in steps {
//                    if let googleData = GoogleDirections(from: step) {
//                        data.append(googleData)
//                    }
//                }
//                
//                
//            }
//        }
//
//        return data
//    }

        static func getData(from dict: [String:Any]) -> [GoogleDirections] {
            var data = [GoogleDirections]()
    
            let route = dict["routes"] as! [[String: Any]]
            for item in route {
                let overview = item["overview_polyline"] as! [String: Any]
                if let polylineData = GoogleDirections(from: overview) {
                    data.append(polylineData)
                }
                

            }
    
            return data
        }


}
