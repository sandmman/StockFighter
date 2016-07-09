//
//  JSON.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//
import Foundation

/*
    Purpose: Converts an AnyObject to a serialized
    json string either pretty printed or standard
*/
func JSONToString(value: AnyObject, prettyPrinted:Bool = false) -> String {

    let options = prettyPrinted ? NSJSONWritingOptions.prettyPrinted : NSJSONWritingOptions(rawValue: 0)

    if NSJSONSerialization.isValidJSONObject(value) {

        do {
            let data = try NSJSONSerialization.data(withJSONObject: value, options: options)
            if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return string as String
            }
        }
        catch {
            print("JSONToString", error)
        }

    }

    return ""

}

/* Purpose: Converts a serialized json string to a dictionary! */

func JSONToDict(string: String) -> [String: AnyObject]{


    if let data = string.data(using: NSUTF8StringEncoding){
        do {
            if let dictionary = try NSJSONSerialization.jsonObject(with: data, options: NSJSONReadingOptions.mutableContainers) as? [String: AnyObject]{
                return dictionary
            }

        } catch {
            print("JSONToDict", error)

        }
    }
    return [String: AnyObject]()
}
