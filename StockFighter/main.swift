//
//  main.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

let account = "BPS10435488"
let apikey  = "123456123456123456123456123456123456123456"
let venue   = "TMBEX"
let stock   = "PPL"
let base_url = "https://api.stockfighter.io/ob/api"

var totalFilled = 0
var goal        = 100000
var goalPrice = 2260.0


var myBroker = Broker(account: account, venue: venue, stock: stock)

while goal != totalFilled {
    
    let newQty = Int(arc4random_uniform(UInt32(155)) + 1)
    
    let currentPrice = myBroker.requestQuote(venue, stock: stock)
    let diff = Int(goalPrice * 0.95) - currentPrice
   
    if diff > 0 && currentPrice != -1 {
        let mod = Int(arc4random_uniform(UInt32(diff)) + 1)
        print("Making Market Trade")
        myBroker.requestTrade(account, venue: venue, stock: stock, price: currentPrice + mod, qty: newQty, direction: "Buy", orderType: "Market")
    } else if diff < -100 {
        continue
    } else {
        print("Making Limit Trade at \(currentPrice)")
        myBroker.requestTrade(account, venue: venue, stock: stock, price: currentPrice, qty: newQty, direction: "buy", orderType: "limit")
    }
    
    //checkOrderStatuses(venue, stock: stock)
    
    print("\(totalFilled)/\(goal)")
    
    //sleep(5)
}
