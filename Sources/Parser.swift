
import Foundation

struct Parser {

    static func parseGameInfo(level: String, gameInfo: [String: AnyObject]) -> Game {

        let stocks   = gameInfo["tickers"] as! [String]
        let venues   = gameInfo["venues"]  as! [String]
        let account  = String(gameInfo["account"]!)
        let instance = String(gameInfo["instanceId"]!)

        print("\n------------------------------",
              "\nAccount Number  : \(account)",
              "\nStock\t\t: \(stocks)",
              "\nVenue\t\t: \(venues)",
              "\n------------------------------\n")

        return Game(level: level, stock: stocks, venue: venues, account: String(account), instance: instance)

    }

    static func parseQuote(response: [String: AnyObject]) -> Quote {

        let ok: Bool            = response["ok"]! as! Bool
        let symbol: String      = response["symbol"]! as! String
        let venue: String       = response["venue"]! as! String
        let bid: Int? = response["bid"]?.integerValue
        let ask: Int? = response["ask"]?.integerValue
        let bidSize: Int        = response["bidSize"]!.integerValue
        let askSize: Int        = response["askSize"]!.integerValue
        let bidDepth: Int       = response["bidDepth"]!.integerValue
        let askDepth: Int       = response["askDepth"]!.integerValue
        let last: Int?          = response["last"]?.integerValue
        let lastSize: Int?       = response["lastSize"]?.integerValue
        let lastTrade: Int?      = response["lastTrade"]?.integerValue
        let quoteTime: NSDate?   = parseTimestamp(stamp: response["quoteTime"] as? String)

        return Quote(ok: ok, symbol: symbol, venue: venue, bid: bid, ask: ask, bidSize: bidSize, askSize: askSize,
             bidDepth: bidDepth, askDepth: askDepth, last: last, lastSize: lastSize, lastTrade: lastTrade, quoteTime: quoteTime)
    }

    static func parseFills(fills: NSArray) -> [Fill] {
        let array: [Fill] = fills.flatMap {
            doc in

            let price = doc["price"]!!.integerValue
            let qty = doc["qty"]!!.integerValue
            let timestamp = parseTimestamp(stamp: doc["ts"]! as? String)!

            return Fill(price: price!, qty: qty!, timestamp: timestamp)
        }

        return array
    }

    static func parseOrder(order: [String: AnyObject]) -> Order {
        let ok          : Bool      = true
        let open        : Bool      = order["open"]!       as! Bool
        let venue       : String    = order["venue"]!      as! String
        let timestamp   : NSDate    = parseTimestamp(stamp: order["ts"] as? String)!
        let symbol      : String    = order["symbol"]!     as! String
        let account     : String    = order["account"]!    as! String
        let id          : Int       = order["id"]!         .integerValue
        let qty         : Int       = order["qty"]!        .integerValue
        let price       : Int    = order["price"]!      .integerValue
        let totalFilled : Int       = order["totalFilled"]!.integerValue
        let originalQty : Int       = order["originalQty"]!.integerValue
        let fills       : [Fill]    = parseFills(fills: order["fills"]! as! NSArray)
        let direction   : Direction = Direction(rawValue: order["direction"]! as! String)!
        let orderType   : OrderType = OrderType(rawValue: order["orderType"]! as! String)!
        let error       : ErrorProtocol? = nil

        return Order(ok: ok, symbol: symbol, venue: venue, direction: direction, originalQty: originalQty,
                    qty: qty, price: price, orderType: orderType, id: id, account: account, timestamp: timestamp,
                  fills: fills, totalFilled: totalFilled, open: open, error: error )
    }
    static func parseOrders(response: [String: AnyObject]) -> [Order] {

        let orders: [Order] = (response["orders"]! as! NSArray).flatMap {
            order in

            parseOrder(order: order as! [String: AnyObject])

        }

        return orders
    }

    static func parseBidsAsks(object: AnyObject?) -> [BidsAsks]? {
        guard let object = object as? NSArray else {
            return nil
        }
        let bids_asks: [BidsAsks] = object.flatMap {
            item in

            let price = item["price"]!!.integerValue
            let qty = item["qty"]!!.integerValue
            let isBuy = item["isBuy"]! as! Bool

            return BidsAsks(price: price!, qty: qty!, isBuy: isBuy)
        }

        return bids_asks
    }

    static func parseOrderBook(orders: [String: AnyObject]) -> OrderBook {
        let ok = orders["ok"]! as! Bool
        let venue    : String = orders["venue"]!      as! String
        let timestamp: NSDate = parseTimestamp(stamp: orders["ts"]! as? String)!
        let symbol   : String = orders["symbol"]!     as! String
        let bids = parseBidsAsks(object: orders["bids"])
        let asks = parseBidsAsks(object: orders["asks"])

        return OrderBook(ok: ok, venue: venue, symbol: symbol, bids: bids, asks: asks, timestamp: timestamp, error: nil)

    }

    static func parseTimestamp(stamp: String?) -> NSDate? {
        guard let stamp = stamp else {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSSZ"
        return dateFormatter.date(from: stamp)!
    }
}
