//
//  TradingAPI.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/26/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation


public class Floor {
    
    var order_IDs: Dictionary<Int, Int>

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
        
        if verifyData(direction, orderType: orderType) == false {
            throw StockFighterErrors.InvalidInput
        }
        
        let order = createOrder(account,venue: venue, stock: stock, price: price, qty: qty, direction: direction, orderType: orderType)
        
        let response = manager.postRequest("\(manager.base_url)/venues/\(venue)/stocks/\(stock)/orders", jsonObj: order)

        response["id"] != nil ? self.order_IDs[Int(response["id"]! as! NSNumber)] = 0 : print("Trade Not Made")
     
    }
    
    /* Finds the most recent quote for a given stock */
    func requestQuote(venue: String, stock: String) -> Int? {
        
        let quoteUrl = "\(manager.base_url)/venues/\(venue)/stocks/\(stock)/quote"
        if let bid = manager.getRequest(quoteUrl)["bid"] {
            return Int(bid as! NSNumber)

        }
        return nil
    }
    
    /*
     Queries Server for a specific Order
     If found, returns a dictionary containing said order
     */
    func getMyOrder(venue: String, stock: String, id: Int) -> Dictionary<String, AnyObject>? {
        
        return manager.getRequest("\(manager.base_url)/venues/\(venue)/stocks/\(stock)/orders/\(id)")
    }
    
    /* 
     Returns a dictionary of all account orders
     If stock is specified, only orders for given stock are returned
     */
    func getAllOrders(venue: String, stock: String? = nil) -> Dictionary<String, AnyObject>? {
        var orderURL = ""

        stock != nil ? (orderURL = "https://api.stockfighter.io/ob/api/venues/\(venue)/accounts/\(account)/stocks/\(stock!)/orders") :
                       (orderURL = "https://api.stockfighter.io/ob/api/venues/\(venue)/accounts/\(account)/orders")

        return manager.getRequest(orderURL)
        
    }
    
    /* Returns the orderbook for a particular stock*/
    func getOrderBook(venue: String, stock: String) -> Dictionary<String,AnyObject> {
        
        return manager.getRequest("https://api.stockfighter.io/ob/api/venues/\(venue)/stocks/\(stock)")
    }
    
    /* Cancels Given Order */
    func cancelOrder(venue: String, stock: String, id: Int) {
        
        manager.getRequest("\(manager.base_url)/venues/\(venue)/stocks/\(stock)/orders/\(id)/cancel")
        
    }
    
    /*
     Polls the open order dictionary to see if they have
     been closed and updates totalFilled orders
     Todo: Make decision on whether to cancel
     */
    
    func checkOrderStatuses(venue: String, stock: String) {
        for (key, index) in order_IDs {
            
            if let order = getMyOrder(venue, stock: stock, id: key) {
                
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
                    order_IDs[key] = fills.count
                    
                    if String(order["open"]!) == "0" { order_IDs.removeValueForKey(key) }
                    
                }

            }
        }
    }
    //
    /* Verifies that direction and order type comply with expected types */
    private func verifyData(direction: String, orderType: String) -> Bool {
        
        let dir  = direction.capitalizedString
        let type = orderType.capitalizedString
        
        if ["Buy","Sell"].indexOf(dir) == nil {
            return false
        }
        if ["Market","Fill-or-kill","Immediate-or-cancel","Limit"].indexOf(type) == nil {
            return false
        }
        
        return true
    }
    
    
}