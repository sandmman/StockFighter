# Stock Fighter API #

This is a basic client library written in Swift for [StockFighter](https://www.stockfighter.io/ui/account) providing methods to wrap the StockFighter API to fluidly handle HTTP POST/GET requests, serialization, and authorization.

### Installation ###
1. Add to XCode

Drag and drop each file from finder into your XCode project. Ensure to check the add to target box for your target project

### Sample Usage ###
```swift
    // Initialize game manager
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


### Comments ###

I've been developing this API as a way to try and play StockFighter efficiently, while also trying to learn/practice writing libraries from scratch. The goal of the library is to make it as easy to use as possible and as such I've tried to keep things simple. Future work will broaden this with socket implementation in addition to general changes found through increased testing, especially on later levels which I haven't gotten to yet!

### License ###

This API Wrapper is released under the MIT license. See LICENSE for details.
