//
//  main.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation


var totalFilled = 88057
var goal        = 100000
var goalPrice   = 7856.0


let game = StockFighter()
game.start("first_steps")
print(game.broker!.account,game.broker!.venue,game.broker!.stock)

print(game.broker?.requestQuote((game.broker?.venue)!, stock: (game.broker?.stock)!))

/*while goal != totalFilled {

    var newQty = Int(arc4random_uniform(UInt32(2000)) + 1)
    if goal - totalFilled < 5000 {
        newQty = goal - totalFilled
    }
    
    
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
    totalFilled += newQty
    
    //checkOrderStatuses(venue, stock: stock)
    
    print("\(totalFilled)/\(goal)")
    
    //sleep(5)
}*/
