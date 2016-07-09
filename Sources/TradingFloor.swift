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

    lazy var venue : [String] = {
        return self.manager.instance!.venue
    }()

    lazy var stock : [String] = {
        return self.manager.instance!.stock
    }()

    lazy var account: String = {
        return self.manager.instance!.account
    }()

    var sharesOwned: Dictionary<String, Int>
    var profit: Double

    init(game: StockFighter){
        self.order_IDs = Dictionary<Int, Int>()
        self.manager = game
        self.sharesOwned = Dictionary<String, Int>()
        self.profit = 0.0
    }

    private func createOrder(account: String, venue: String, stock: String, price: Int, qty: Int, direction: String, orderType: String) -> [String: AnyObject] {

        let order: [String: AnyObject] = [
            "account"   : account,
            "venue"     : venue,
            "symbol"    : stock,
            "price"     : price,
            "qty"       : qty,
            "direction" : direction,
            "orderType" : orderType
        ]

        return order

    }

    /* Makes a trade request to the server */
    func requestTrade(account: String, venue: String, stock: String, price: Int, qty: Int, direction: String, orderType: String) throws {

        if verifyData(withDirection: direction, withType: orderType) == false {
            throw StockFighterErrors.InvalidInput
        }
        print(account,venue,stock,price,qty)
        let order = createOrder(account: account, venue: venue, stock: stock, price: price, qty: qty, direction: direction, orderType: orderType)

        guard let response = manager.post(atURL: "\(manager.base_url)/venues/\(venue)/stocks/\(stock)/orders", jsonObj: order) else {
            return
        }

        response["id"] != nil ? self.order_IDs[Int(response["id"]! as! NSNumber)] = 0 : print("Trade Not Made")

    }

    /* Finds the most recent quote for a given stock */
    func requestQuote(venue: String, stock: String) throws -> Int? {

        let quoteUrl = "\(manager.base_url)/venues/\(venue)/stocks/\(stock)/quote"

        guard let bid = manager.get(atURL: quoteUrl)?["bid"] else {
            return nil

        }

        return Int(bid as! NSNumber)
    }

    /*
     Queries Server for a specific Order
     If found, returns a dictionary containing said order
     */
    func getOrder(atVenue: String, withStock: String, withId: Int) -> [String: AnyObject]? {

        return manager.get(atURL: "\(manager.base_url)/venues/\(atVenue)/stocks/\(withStock)/orders/\(withId)")
    }

    /*
     Returns a dictionary of all account orders
     If stock is specified, only orders for given stock are returned
     */
    func getOrders(atVenue: String, withStock: String? = nil) -> [String: AnyObject]? {
        var orderURL = ""

        withStock != nil ? (orderURL = "https://api.stockfighter.io/ob/api/venues/\(atVenue)/accounts/\(account)/stocks/\(withStock!)/orders") :
                           (orderURL = "https://api.stockfighter.io/ob/api/venues/\(atVenue)/accounts/\(account)/orders")

        return manager.get(atURL: orderURL)

    }

    /* Returns the orderbook for a particular stock*/
    func getOrderBook(atVenue: String, withStock: String) -> [String: AnyObject]? {

        return manager.get(atURL: "https://api.stockfighter.io/ob/api/venues/\(atVenue)/stocks/\(withStock)")
    }

    /* Cancels Given Order */
    func cancelOrder(atVenue: String, withStock: String, withId: Int) {

        manager.get(atURL: "\(manager.base_url)/venues/\(atVenue)/stocks/\(withStock)/orders/\(withId)/cancel")

    }

    /*
     Polls the open order dictionary to see if they have
     been closed and updates totalFilled orders
     Todo: Make decision on whether to cancel
     */

    func checkOrderStatuses(atVenue: String, withStock: String) {
        for (id, index) in order_IDs {

            if let order = getOrder(atVenue: atVenue, withStock: withStock, withId: id) {

                if order.count == 0 { continue }

                else {

                    let fills = order["fills"]!

                    for i in index..<fills.count {

                        let shares = fills[i]["qty"]!! as! Double
                        let price  = fills[i]["price"]!! as! Double

                        if sharesOwned[order["symbol"]! as! String] == nil { sharesOwned[order["symbol"]! as! String] = 0 }

                        if String(order["direction"]!) == "buy" {
                            profit -= shares * price
                            sharesOwned[order["symbol"]! as! String]! += Int(shares)

                        } else {
                            profit += shares * price
                            sharesOwned[order["symbol"]! as! String]! += Int(shares)

                        }
                    }
                    order_IDs[id] = fills.count

                    if String(order["open"]!) == "0" { order_IDs.removeValue(forKey: id) }

                }

            }
        }
    }
    //
    /* Verifies that direction and order type comply with expected types */
    private func verifyData(withDirection: String, withType: String) -> Bool {

        let dir  = withDirection.capitalized
        let type = withType.capitalized

        if ["Buy","Sell"].index(of: dir) == nil {
            return false
        }
        if ["Market","Fill-or-kill","Immediate-or-cancel","Limit"].index(of: type) == nil {
            return false
        }

        return true
    }


}
