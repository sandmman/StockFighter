//
//  main.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

var gm = StockFighter()

try gm.reset(level: "chock_a_block")

var floor = Floor(game: gm)

let goal = 1000
let totalFilled = 0

let stock = floor.stocks[0]
let venue = floor.venues[0]
let account = floor.account

let currentPrice = try floor.requestQuote(venue: venue, stock: stock).ask ?? 50

while goal != floor.sharesOwned[stock] {

    let result = floor.requestTrade(account: account, venue: venue, stock: stock, price: currentPrice, qty: 250, direction: Direction.buy, orderType: OrderType.market)

    floor.order_IDs[result.id] = 0

    floor.checkOrderStatuses(atVenue: venue, withStock: stock)

    print("I currently own \(floor.sharesOwned[stock]!) shares of \(stock)")

}
