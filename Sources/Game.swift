//
//  Game.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/26/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

public class Game {
    
    var level: String
    var stock: [String]
    var venue: [String]
    var account: String
    var ID: String
    
    init(level: String, stock: [String], venue: [String], account: String, instance: String) {
        self.level = level
        self.stock = stock
        self.venue = venue
        self.account = account
        self.ID = instance
    }
    func printData(){
        print(ID,stock,venue,account)
    }
}