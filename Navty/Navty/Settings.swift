//
//  Settings.swift
//  Navty
//
//  Created by Edward Anchundia on 3/16/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import Foundation

class Settings {
    static let shared = Settings()
    private init() {}
    
    var trackingEnabled = false
    var channelName = ""
    var navigationStarted = false
    var channelInput = false
}
