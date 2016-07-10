
import Foundation

enum OrderType: String {
    case market = "market", immediate_or_cancel = "immediate-or-cancel", fill_or_kill = "fill-or-kill", limit = "limit"
}
enum Direction: String {
    case buy = "buy", sell = "sell"
}

struct Heartbeat {
    let ok: Bool
    let venue: String
    let error: ErrorProtocol?

    init(ok: Bool, venue: String = "", error: ErrorProtocol? = nil) {
        self.ok = ok
        self.venue = venue
        self.error = error
    }
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

    init(ok: Bool, symbol: String, venue: String, bid: Int?, ask: Int?, bidSize: Int, askSize: Int, bidDepth: Int, askDepth: Int,
         last: Int?, lastSize: Int?, lastTrade: Int?, quoteTime: NSDate?) {
             self.ok = ok
             self.symbol = symbol
             self.venue = venue
             self.bid = bid
             self.ask = ask
             self.bidSize = bidSize
             self.askSize = askSize
             self.bidDepth = bidDepth
             self.askDepth = askDepth
             self.last = last
             self.lastSize = lastSize
             self.lastTrade = lastTrade
             self.quoteTime = quoteTime
         }
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

    init(ok: Bool, symbol: String, venue: String, direction: Direction, originalQty: Int,
        qty: Int, price: Int, orderType: OrderType, id: Int, account: String, timestamp: NSDate,
      fills: [Fill], totalFilled: Int, open: Bool, error: ErrorProtocol? = nil ) {

            self.ok = ok
            self.symbol = symbol
            self.venue = venue
            self.direction = direction
            self.originalQty = originalQty
            self.qty = qty
            self.price = price
            self.orderType = orderType
            self.id = id
            self.account = account
            self.timestamp = timestamp
            self.fills = fills
            self.totalFilled = totalFilled
            self.open = open
            self.error = error
    }
}

struct OrderBook {
    let ok: Bool
    let venue: String
    let symbol: String
    let bids: [Bid]?
    let asks: [Ask]?
    let timestamp: NSDate
    let error: ErrorProtocol?

    init(ok: Bool, venue: String, symbol: String, bids: [Bid]?, asks: [Ask]?, timestamp: NSDate, error: ErrorProtocol? = nil) {
        self.ok = ok
        self.venue = venue
        self.symbol = symbol
        self.bids = bids
        self.asks = asks
        self.timestamp = timestamp
        self.error = error
    }
}

struct Ask {
    let price: Int
    let qty: Int
    let isBuy: Bool

    init(price: Int, qty: Int, isBuy: Bool) {
        self.price = price
        self.qty = qty
        self.isBuy = isBuy
    }
}

struct Bid {
    let price: Int
    let qty: Int
    let isBuy: Bool

    init(price: Int, qty: Int, isBuy: Bool) {
        self.price = price
        self.qty = qty
        self.isBuy = isBuy
    }
}

struct Fill {
    let price: Int
    let qty: Int
    let timestamp: NSDate

    init(price: Int, qty: Int, timestamp: NSDate) {
        self.price = price
        self.qty = qty
        self.timestamp = timestamp
    }
}
