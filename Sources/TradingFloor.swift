//
//  TradingAPI.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/26/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation


public class Floor {

    var order_IDs: [Int: Int]

    var manager: StockFighter

    lazy var venues : [String] = {
        return self.manager.instance!.venue
    }()

    lazy var stocks : [String] = {
        return self.manager.instance!.stock
    }()

    lazy var account: String = {
        return self.manager.instance!.account
    }()

    var sharesOwned: [String: Int]
    var profit: Double

    init(game: StockFighter){
        self.order_IDs = [Int: Int]()
        self.manager = game
        self.sharesOwned = [String: Int]()
        self.profit = 0.0
    }

    private func createOrder(account: String, venue: String, stock: String, price: Int, qty: Int, direction: Direction, orderType: OrderType) -> [String: AnyObject] {

        let order: [String: AnyObject] = [
            "account"   : account,
            "venue"     : venue,
            "symbol"    : stock,
            "price"     : price,
            "qty"       : qty,
            "direction" : direction.rawValue,
            "orderType" : orderType.rawValue
        ]

        return order

    }

    /* Makes a trade request to the server */
    func requestTrade(account: String, venue: String, stock: String, price: Int, qty: Int, direction: Direction, orderType: OrderType) -> Order {

        let order = createOrder(account: account, venue: venue, stock: stock, price: price, qty: qty, direction: direction, orderType: orderType)

        guard let response = manager.post(atURL: "\(manager.base_url)/venues/\(venue)/stocks/\(stock)/orders", jsonObj: order)
                    where response["error"] == nil else {
            exit(1)
        }

        return Parser.parseOrder(order: response)
    }

    /* Finds the most recent quote for a given stock */
    func requestQuote(venue: String, stock: String) throws -> Quote {

        let quoteUrl = "\(manager.base_url)/venues/\(venue)/stocks/\(stock)/quote"

        guard let quote = manager.get(atURL: quoteUrl)
                where quote["error"] == nil else {
            exit(1)
        }

        return Parser.parseQuote(response: quote)
    }


    /*
     Queries Server for a specific Order
     If found, returns a dictionary containing said order
     */
    func getOrder(atVenue: String, withStock: String, withId: Int) -> Order? {

        guard let order = manager.get(atURL: "\(manager.base_url)/venues/\(atVenue)/stocks/\(withStock)/orders/\(withId)")
                    where order["error"] == nil else {
            return nil
        }

        return Parser.parseOrder(order: order)
    }

    /*
     Returns a dictionary of all account orders
     If stock is specified, only orders for given stock are returned
     */
    func getOrders(atVenue: String, withStock: String? = nil) -> [Order] {
        var orderURL = ""

        withStock != nil ? (orderURL = "https://api.stockfighter.io/ob/api/venues/\(atVenue)/accounts/\(account)/stocks/\(withStock!)/orders") :
                           (orderURL = "https://api.stockfighter.io/ob/api/venues/\(atVenue)/accounts/\(account)/orders")

        guard let orders = manager.get(atURL: orderURL)
                where orders["error"] == nil else {
            exit(1)
        }

        return Parser.parseOrders(response: orders)

    }

    /* Returns the orderbook for a particular stock*/
    func getOrderBook(atVenue: String, withStock: String) -> OrderBook {

        guard let response = manager.get(atURL: "https://api.stockfighter.io/ob/api/venues/\(atVenue)/stocks/\(withStock)")
                where response["error"] == nil else {
            exit(1)
        }

        return Parser.parseOrderBook(orders: response)
    }

    /* Cancels Given Order */
    func cancelOrder(atVenue: String, withStock: String, withId: Int) -> Order {

        guard let response = manager.get(atURL: "\(manager.base_url)/venues/\(atVenue)/stocks/\(withStock)/orders/\(withId)/cancel")
                where response["error"] == nil else {
            exit(1)
        }

        return Parser.parseOrder(order: response)

    }
    /*
     Polls the open order dictionary to see if they have
     been closed and updates totalFilled orders
     Todo: Make decision on whether to cancel
     */

    func checkOrderStatuses(atVenue: String, withStock: String) {
        for (id, index) in order_IDs {

            if let order = getOrder(atVenue: atVenue, withStock: withStock, withId: id) {

                let fills = order.fills

                for i in index..<fills.count {

                    let shares = fills[i].qty
                    let price  = fills[i].price

                    if sharesOwned[order.symbol] == nil { sharesOwned[order.symbol] = 0 }

                    if order.direction == Direction.buy {
                        profit -= Double(shares) * Double(price)
                        sharesOwned[order.symbol]! += Int(shares)

                    } else {
                        profit += Double(shares) * Double(price)
                        sharesOwned[order.symbol]! += Int(shares)

                    }
                    order_IDs[id] = fills.count

                    if !order.open  { order_IDs.removeValue(forKey: id) }

                }

            }
        }
    }
}
