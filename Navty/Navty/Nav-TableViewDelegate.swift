//
//  Nav-TableViewDelegate.swift
//  Navty
//
//  Created by Kadell on 3/18/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation

extension NavigationMapViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for elements in 0..<directions.count {
            return directions[elements].directionInstruction.count
        }
        return directions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DirectionsTableViewCell
        
        let direction: GoogleDirections? = directions[0]
        let stepDirection = direction?.directionInstruction[indexPath.row]
        let stepDistance = direction?.distanceForStep[indexPath.row]
        
        let swiftString = stepDirection?.html2AttributedString
        let stringThatWeWantToDisplay = swiftString?.string
        //let stringThatWeReallyWantToDisplay = stringThatWeWantToDisplay
        
        self.timerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        self.timerLabel.textColor = .white
      
        
        cell.directionLabel.numberOfLines = 0
        cell.directionLabel.sizeToFit()
        cell.directionLabel.sizeToFit()
        cell.directionLabel.text = stringThatWeWantToDisplay
        cell.directionTimeLabel.text = stepDistance
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return timerLabel
    }
    
    

    
}
