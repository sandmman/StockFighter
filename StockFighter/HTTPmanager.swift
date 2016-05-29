//
//  HTTPmanager.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

/*
    Parameters
    - request:  destination URL
    - callback: return function
    Task: Sends the given HTTP Request 'whooosh'
    and returns response
*/

func HTTPsendRequest(request: NSMutableURLRequest,callback: (String, String?) -> Void) {
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request,completionHandler :
        {
            data, response, error in
            
            error != nil ? callback("", (error!.localizedDescription) as String) :
                           callback(NSString(data: data!, encoding: NSUTF8StringEncoding) as! String,nil)

    })
    
    task.resume()
    
}
/*
    Parameters
    - url:      destination URL
    - callback: return function
    Task: Executes an HTTP GET request to the destination url
*/
func HTTPGetJSON(url: String, callback: (Dictionary<String, AnyObject>, String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.setValue("c081a375c684d85eeb16e263bdc7e8b5574ba280", forHTTPHeaderField: "X-Starfighter-Authorization")
    
        HTTPsendRequest(request) {
            (data: String, error: String?) -> Void in
            
            error != nil ? callback(Dictionary<String, AnyObject>(), error) : callback(JSONToDict(data), nil)

        }
    
    sleep(2)
}

/*
    Parameters 
    - url:      destination URL
    - jsonObj:  json compliant object
    - callback: return function
    Task: Executes an HTTP POST request to the destination url
    containing the given json serializable object
*/
func HTTPPostJSON(url: String,
                  jsonObj: AnyObject,
                  callback: (Dictionary<String, AnyObject>, String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.addValue("c081a375c684d85eeb16e263bdc7e8b5574ba280", forHTTPHeaderField: "X-Starfighter-Authorization")
    
        let jsonString = JSONToString(jsonObj)
        let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        
        request.HTTPBody = data
                    HTTPsendRequest(request){
                        (data: String, error: String?) -> Void in
                        
                        error != nil ? callback(Dictionary<String, AnyObject>(), error) : callback(JSONToDict(data), nil)

                    }
       sleep(2)
}


