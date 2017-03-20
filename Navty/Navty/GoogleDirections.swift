//
//  GoogleDirections.swift
//  Navty
//
//  Created by Kadell on 3/1/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation

enum errorEnum: Error {
    case test, other, new, next
}

class GoogleDirections {

    let directionInstruction: [String]
    let overallPolyline: String
    let overallDistance: String
    let overallTime: String
    let distanceForStep: [String]
    let timeForStep: [String]
    let endLocationForStepLat: [Float]
    let endLocationForStepLong: [Float]
    let eachStepPolyline: [String]
    let startLocationForStepLat: [Float]
    let startLocationForStepLong: [Float]
    let startLat: Float
    let startLong: Float

    init(directionInstruction:[String], overallPolyline: String, overallDistance: String, overallTime: String, distanceForStep: [String], timeForStep: [String], endLocationForStepLat: [Float], endLocationForStepLong: [Float], eachStepPolyline: [String], startLocationForStepLat: [Float], startLocationForStepLong: [Float], startLat: Float, startLong: Float) {
        self.directionInstruction = directionInstruction
        self.overallPolyline = overallPolyline
        self.overallDistance = overallDistance
        self.overallTime = overallTime
        self.distanceForStep = distanceForStep
        self.timeForStep = timeForStep
        self.endLocationForStepLat = endLocationForStepLat
        self.endLocationForStepLong = endLocationForStepLong
        self.eachStepPolyline = eachStepPolyline
        self.startLocationForStepLat = startLocationForStepLat
        self.startLocationForStepLong = startLocationForStepLong
        self.startLat = startLat
        self.startLong = startLong
    }

    static func getData(from data: Data) -> [GoogleDirections]? {
        do {
            var legsInfo = [[String:Any]]()
            var stepsInfo = [[String:Any]]()
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            
             guard let dict = jsonData as? [String: Any] else {return nil}
            guard let routes = dict["routes"] as? [[String: Any]] else { throw errorEnum.test}
           
            var overallPoly: String!
            var fullDistance: String!
            var fullTime: String!
            var directionInstruction = [String]()
            var distanceForStep = [String]()
            var timeForStep = [String]()
            var endLocationForStepLat = [Float]()
            var endLocationForStepLong = [Float]()
            var eachStepPolyline = [String]()
            var startLocationForStepLat = [Float]()
            var startLocationForStepLong = [Float]()
            
            var startLat: Float!
            var startLong: Float!
            
            var allGoogleData = [GoogleDirections]()
            
            for info in routes {
                guard let legs = info["legs"] as? [[String:Any]] else { throw errorEnum.test}
                guard let totalPoly = info["overview_polyline"] as? [String:Any] else {throw errorEnum.test}
                let polyline = totalPoly["points"] as? String ?? ""
                overallPoly = polyline
                legsInfo = legs
            }
            
            
            for leg in legsInfo {
                guard let totalDistance = leg["distance"] as? [String:Any] else { throw errorEnum.test}
                guard let totalDuration = leg["duration"] as? [String:Any] else {throw errorEnum.test}
                guard let overallStartLocation = leg["start_location"] as? [String: Any] else {throw errorEnum.test}
                guard let steps = leg["steps"] as? [[String: Any]] else {throw errorEnum.test}
                let distanceOf = totalDistance["text"] as? String ?? ""
                let timeOf = totalDuration["text"] as? String ?? ""
                let startLatOf = overallStartLocation["lat"] as? Float ?? 0
                let startLongOf = overallStartLocation["lng"] as? Float ?? 0
                fullDistance = distanceOf
                fullTime = timeOf
                stepsInfo = steps
                startLat = startLatOf
                startLong = startLongOf
                
            }
            
            for step in stepsInfo {
                guard let stepDistance = step["distance"] as? [String: Any] else {throw errorEnum.test}
                guard let stepTime = step["duration"] as? [String: Any] else {throw errorEnum.test}
                guard let endLocation = step["end_location"] as? [String: Any] else {throw errorEnum.test}
                guard let polyline = step["polyline"] as? [String: Any] else {throw errorEnum.test}
                guard let startLocation = step["start_location"] as? [String: Any] else {throw errorEnum.test}
                guard let instructions = step["html_instructions"] as? String else {throw errorEnum.test}
                let distance = stepDistance["text"] as? String ?? ""
                let time = stepTime["text"] as? String ?? ""
                let endLatitude = endLocation["lat"] as? Float ?? 0
                let endLongitude = endLocation["lng"] as? Float ?? 0
                let poly = polyline["points"] as? String ?? ""
                let startLatitude = startLocation["lat"] as? Float ?? 0
                let startLongitude = startLocation["lng"] as? Float ?? 0
                
                directionInstruction.append(instructions)
                distanceForStep.append(distance)
                timeForStep.append(time)
                endLocationForStepLat.append(endLatitude)
                endLocationForStepLong.append(endLongitude)
                eachStepPolyline.append(poly)
                startLocationForStepLat.append(startLatitude)
                startLocationForStepLong.append(startLongitude)
                
            }
            
            let googleData = GoogleDirections(directionInstruction: directionInstruction, overallPolyline: overallPoly, overallDistance: fullDistance, overallTime: fullTime, distanceForStep: distanceForStep, timeForStep: timeForStep, endLocationForStepLat: endLocationForStepLat, endLocationForStepLong: endLocationForStepLong, eachStepPolyline: eachStepPolyline, startLocationForStepLat: startLocationForStepLat, startLocationForStepLong: startLocationForStepLong, startLat: startLat, startLong: startLong)
            allGoogleData.append(googleData)
            return allGoogleData
        }
        catch {
            print("I dont see it ")
        }
        return nil
    }


}
