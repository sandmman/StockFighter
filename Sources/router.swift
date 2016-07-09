//
//  HTTPmanager.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

class Router: NSObject {

    let session = NSURLSession.shared();
    let request : NSMutableURLRequest = NSMutableURLRequest();

    override init() {
        request.setValue("c081a375c684d85eeb16e263bdc7e8b5574ba280", forHTTPHeaderField: "X-Starfighter-Authorization")
    }

    /*
     Method: Constructs an HTTP GET request to the destination url
     */

     func requestManager(request: NSMutableURLRequest, callback: (String?, ErrorProtocol?) -> Void) {

         let task = NSURLSession.shared().dataTask(with: request) {
                 data, response, error in

                 error != nil ? callback(nil, error) :
                                callback(String(NSString(data: data!, encoding: NSUTF8StringEncoding)!), nil)

         }

         task.resume()

     }
     /*
         Parameters
         - url:      destination URL
         - callback: return function
         Task: Executes an HTTP GET request to the destination url
     */
     func get(withUrl: String, callback: ([String: AnyObject]?, ErrorProtocol?) -> Void) {

             let request = NSMutableURLRequest(url: NSURL(string: withUrl)!)
             request.setValue("c081a375c684d85eeb16e263bdc7e8b5574ba280", forHTTPHeaderField: "X-Starfighter-Authorization")

             requestManager(request: request) {
                 data, error in

                 error != nil ? callback(nil, error) : callback(JSONToDict(string: data!), nil)

             }

         sleep(3)
     }

     func post(withUrl: String,
               jsonObj: AnyObject,
              callback: ([String: AnyObject]?, ErrorProtocol?) -> Void) {

        let request = NSMutableURLRequest(url: NSURL(string: withUrl)!)

        request.httpMethod = "POST"
        request.addValue("c081a375c684d85eeb16e263bdc7e8b5574ba280", forHTTPHeaderField: "X-Starfighter-Authorization")

        let jsonString = JSONToString(value: jsonObj)
        let data: NSData = jsonString.data(using: NSUTF8StringEncoding)!

        request.httpBody = data
        requestManager(request: request){
             data, error in

             error != nil ? callback(nil, error) : callback(JSONToDict(string: data!), nil)
        }
        sleep(3)
     }
}
