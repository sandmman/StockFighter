 //
//  manager.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

/* Verifies that direction and order type comply with expected types */
func verifyData(direction: String, orderType: String) -> Bool {
    let dir  = direction.capitalizedString
    let type = orderType.capitalizedString
    
    if ["Buy","Sell"].indexOf(dir) == nil {
        return false
    }
    if ["Market","fill-or-kill","immediate-or-cancel","limit"].indexOf(type) == nil {
        return false
    }
    
    return true
}

func createOrder(account: String, venue: String, stock: String, price: Int, qty: Int, direction: String, orderType: String) -> [String: AnyObject] {
    
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
func requestTrade(account: String, venue: String, stock: String, price: Int, qty: Int, direction: String, orderType: String){
    
    if verifyData(direction, orderType: orderType) == false {
        return
    }
    
    let order = createOrder(account,venue: venue, stock: stock, price: price, qty: qty, direction: direction, orderType: orderType)
    
    HTTPPostJSON("\(base_url)/venues/\(venue)/stocks/\(stock)/orders", jsonObj: order) {
        (data: Dictionary<String, AnyObject>, error: String?) -> Void in
        if error != nil {
            print("Error Making Transaction \(error)")
        }
        else {
            if let _ = data["totalFilled"] {
                totalFilled += Int(data["totalFilled"]! as! NSNumber)
                order_IDs[Int(data["id"]! as! NSNumber)] = true
                print("Request: \(direction) \(qty) shares of \(venue) \(stock) at \(price)")
            }
        }
    }
}
/* Finds the most recent quote for a given stock */
func requestQuote(venue: String, stock: String) -> Int{
    
    let quoteUrl = "https://api.stockfighter.io/ob/api/venues/\(venue)/stocks/\(stock)/quote"
    
    var quote = -1
    
    HTTPGetJSON(quoteUrl) {
        (data: Dictionary<String, AnyObject>, error:String?) -> Void in
        if error != nil {
            print(error)
        } else {
            if let q = data["bid"] {
                quote = Int(q as! NSNumber)
            }
        }
    }
    return quote
}
/* 
    Queries Server for a specific Order
    If found, returns a dictionary containing said order
*/
func getMyOrder(venue: String, stock: String, id: Int) -> Dictionary<String, AnyObject>? {
    
    let orderURL = "https://api.stockfighter.io/ob/api/venues/\(venue)/stocks/\(stock)/orders/\(id)"
    
    var order: Dictionary<String, AnyObject>? = nil
    
    HTTPGetJSON(orderURL) {
        (data: Dictionary<String, AnyObject>, error:String?) -> Void in
        if error != nil {
            print(error)
        } else {
            order = data
        }
    }
    return order
}

/* Cancels Given orders */
func cancelOrder(venue: String, stock: String, id: Int) {
    
    let cancelUrl = "https://api.stockfighter.io/ob/api/venues/\(venue)/stocks/\(stock)/orders/\(id)/cancel"
    
    HTTPGetJSON(cancelUrl) {
        (data: Dictionary<String, AnyObject>, error:String?) -> Void in
        if error != nil {
            print(error)
        } else {
            print("Successfully Cancelled Order: \(id)")
        }
    }
    
}
/* 
    Polls the open order dictionary to see if they have
    been closed and updates totalFilled orders
    Todo: Make decision on whether to cancel
*/
func checkOrderStatuses(venue: String, stock: String) {
    for (key, _) in order_IDs {
        
        let order = getMyOrder(venue, stock: stock, id: key)
        
        if order == nil {
            return
        }
        
        if String(order!["open"]) == "false" {
            order_IDs.removeValueForKey(key)
        } else {
            totalFilled += Int(String(order!["totalFilled"]))!
        }
    }
}