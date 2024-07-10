//
//  Item.swift
//  Foodipedia
//
//  Created by rnara on 7/7/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
