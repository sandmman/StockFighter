# Stock Fighter API #

![Build Status](https://travis-ci.org/sandmman/StockFighter.svg?branch=master)

This is a basic client library written in Swift for [StockFighter](https://www.stockfighter.io/ui/account) providing methods to wrap the StockFighter API to fluidly handle HTTP POST/GET requests, serialization, and authorization.

### Installation ###

> Requires the [swift-DEVELOPMENT-06-06 SNAPSHOT](https://swift.org/download/).

1. Download the [Swift DEVELOPMENT 06-06 snapshot](https://swift.org/download/#snapshots)

2. Add to XCode

Drag and drop each file from finder into your XCode project. Ensure to check the add to target box for your target project


### Sample Usage ###
```swift
    // Initialize game manager
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
```
#### Note on state ####

In order to save state between runs, the API reads and writes to a .txt to save game instance ID variables, which will allow the code to reset to the previous state. Calling reset() as opposed to start() provides this functionality

### Features ###
- [x] Authorization
- [x] JSON Serialization
- [x] HTTP Post/Get Request
- [ ] Implement Sockets
- [x] Save State
- [ ] Asynchronous Threading

### API ###

#### Constructors/Methods ####

| Call        | Description        
| ------------- |:-------------|
|StockFighter()| Initializes game manager |
|.start(level: String)| Instantiates new game on the given level |
|.stop()| Ends the current game mode |
|.resume()| resumes current game mode|
|.restart()| Restarts StockFighter level|
|.reset(level: String)| Attempts to continue from current game mode / otherwise instantiates a new game on the given level|
|||
|Floor()| Initializes the trading floor  |
| .requestTrade(account: String, venue: String, stock: String, price: Int, qty: Int, direction: String, orderType: String) | Makes Trade request for given parameters|
|.requestQuote(venue: String, stock: String) -> Int | Returns current quote for given stocks|
|.cancelOrder(venue: String, stock: String, id: Int | Cancels given order|
|.checkOrderStatuses(venue: String, stock: String) | Checks open orders to see if they have been closed and updates sharesOwned and profit variables |
|.getMyOrder(venue: String, stock: String, id: Int) | Returns status of given order|

#### Return Objects ####
```swift
struct Heartbeat {
    let ok: Bool
    let venue: String
    let error: ErrorProtocol?
}

struct Quote {
    let ok: Bool
    let symbol: String
    let venue: String
    let bid: Int?
    let ask: Int?
    let bidSize: Int
    let askSize: Int
    let bidDepth: Int
    let askDepth: Int
    let last: Int?
    let lastSize: Int?
    let lastTrade: Int?
    let quoteTime: NSDate?
}

struct Order {
    let ok: Bool
    let symbol: String
    let venue: String
    let direction: Direction
    let originalQty: Int
    let qty: Int
    let price: Int
    let orderType: OrderType
    let id: Int
    let account: String
    let timestamp: NSDate
    let fills: [Fill]
    let totalFilled: Int
    let open: Bool
    let error: ErrorProtocol?
}

struct OrderBook {
    let ok: Bool
    let venue: String
    let symbol: String
    let bids: [BidsAsks]?
    let asks: [BidsAsks]?
    let timestamp: NSDate
    let error: ErrorProtocol?
}

struct Ask {
    let price: Int
    let qty: Int
    let isBuy: Bool
}

struct Bid {
    let price: Int
    let qty: Int
    let isBuy: Bool
}

struct Fill {
    let price: Int
    let qty: Int
    let timestamp: NSDate
}
```

### Comments ###

I've been developing this API as a way to try and play StockFighter efficiently, while also trying to learn/practice writing libraries from scratch. The goal of the library is to make it as easy to use as possible and as such I've tried to keep things simple. Future work will broaden this with socket implementation in addition to general changes found through increased testing, especially on later levels which I haven't gotten to yet!

### License ###

This API Wrapper is released under the MIT license. See LICENSE for details.
