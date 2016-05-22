//
//  main.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

let account = "TRB82084559"
let apikey  = "123456123456123456123456123456123456123456"
let venue   = "CFTEX"
let stock   = "UYBO"
let base_url = "https://api.stockfighter.io/ob/api"


var totalFilled = 0
var goal        = 100000
var order_IDs: Dictionary<Int, Bool>   = Dictionary<Int, Bool>()
var goalPrice = 3267.0

print(requestQuote(venue, stock: stock))
requestTrade(account, venue: venue, stock: stock, price: 10000, qty: 100, direction: "Buy", orderType: "market")
//print(getMyOrder(venue, stock: stock, id: 1826))

/*while goal != totalFilled {
    
    let newQty = Int(arc4random_uniform(UInt32(155)) + 1)
    
    let currentPrice = requestQuote(venue, stock: stock)
    let diff = Int(goalPrice * 0.8) - currentPrice
    
    if diff > 0 {
        let mod = Int(arc4random_uniform(UInt32(diff)) + 1)
        requestTrade(account, venue: venue, stock: stock, price: currentPrice + mod, qty: newQty, direction: "Buy", orderType: "Market")
    } else if diff < 0 {
        continue
    } else {
        
        requestTrade(account, venue: venue, stock: stock, price: , qty: newQty, direction: "Buy", orderType: "Limit")
    }
    
    print("\(totalFilled)/\(goal)")
    
    sleep(10)
}*/
