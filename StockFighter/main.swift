//
//  main.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation





var gm = StockFighter()

try gm.reset("first_steps")

var floor = Floor(game: gm)

print(floor.venue,floor.stock,floor.account)

let stock = floor.stock
let venue = floor.venue
let account = floor.account

var totalFilled = 0
var goal        = 100000
var goalPrice   = 100.0

/*while goal != totalFilled {

    var newQty = Int(arc4random_uniform(UInt32(2000)) + 1)
    if goal - totalFilled < 5000 {
        newQty = goal - totalFilled
    }
    
    
    let currentPrice = floor.requestQuote(venue, stock: stock)
    floor.requestTrade(account, venue: venue, stock: stock, price: currentPrice, qty: newQty, direction: "Buy", orderType: "Market")

    //let diff = Int(goalPrice * 0.95) - currentPrice
    //print(currentPrice)
    /*if diff > 0 && currentPrice != -1 {
        let mod = Int(arc4random_uniform(UInt32(diff)) + 1)
        print("Making Market Trade")
        floor.requestTrade(account, venue: venue, stock: stock, price: currentPrice + mod, qty: newQty, direction: "Buy", orderType: "Market")
    } else if diff < -100 {
        continue
    } else {
        print("Making Limit Trade at \(currentPrice)")
        floor.requestTrade(account, venue: venue, stock: stock, price: currentPrice, qty: newQty, direction: "buy", orderType: "limit")
    }
    totalFilled += newQty
    
    //checkOrderStatuses(venue, stock: stock)
    
    print("\(totalFilled)/\(goal)")
    
}*/
