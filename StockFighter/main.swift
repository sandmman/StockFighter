//
//  main.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

var gm = StockFighter()

try gm.reset("chock_a_block")

var floor = Floor(game: gm)

var goal = 1000
var totalFilled = 0

let stock = floor.stock[0]
let venue = floor.venue[0]
let account = floor.account

print("Account Number: \(account)")
print("Stock: \(stock) Venue: \(venue)")

let currentPrice = floor.requestQuote(venue, stock: stock)


while goal != floor.sharesOwned[stock] {
    
    try floor.requestTrade(account, venue: venue, stock: stock, price: currentPrice!, qty: 250, direction: "Buy", orderType: "Market")
    
    floor.checkOrderStatuses(venue, stock: stock)
    
    print("I currently own \(floor.sharesOwned[stock]!) shares of \(stock)")
   
}


var position    = 0
var goalProfit  = 100000.0
