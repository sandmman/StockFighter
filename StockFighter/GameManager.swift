 //
//  manager.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

 let obj = [String: AnyObject]()
 
 
 public class StockFighter {
    
    let game_url = "https://www.stockfighter.io/gm"
    let base_url = "https://api.stockfighter.io/ob/api"
    let wSkt_url = "wss://api.stockfighter.io/ob/api/ws/"
    let fileName = "Projects/StockFighter/StockFighter/storage.txt"
    let apikey   = "123456123456123456123456123456123456123456"
    
    let validLevels = ["first_steps","sell_side","chock_a_block"]
    
    var instance: Game?
    
    init() {
        instance = nil
    }
    
    // Todo: Socket Setup //
    
    // Heartbeat functions //
    
    func heartbeat() throws -> Dictionary<String, AnyObject>?  {
        
        let val = getRequest("https://api.stockfighter.io/ob/api/venues/\(venue)/heartbeat")
        
        if (val["ok"]) != nil { return val }
        
        throw StockFighterErrors.StockFighterServersAreDown
    }
    
    /* Purpose; checks to see if the venue is up, if not restarts the game to get it working again */
    func heartbeat(venue: String) throws -> Dictionary<String, AnyObject>? {

        let val = getRequest("https://api.stockfighter.io/ob/api/heartbeat")
        
        // Check to see if the venue is not up
        if (val["ok"]) == nil {
            try stop()
            try start(instance!.level)
        }
        
        return val
    }
    
    // Game setup functions //
    
    func start(level: String) throws {
        
        if !validLevels.contains(level)  {
            throw StockFighterErrors.InvalidLevel
        }
        
        let gameInfo = postRequest("\(game_url)/levels/\(level)", jsonObj: obj)
        
        let stocks   = gameInfo["tickers"]! as! [String]
        let venues   = gameInfo["venues"]! as! [String]
        let account  = String(gameInfo["account"]!)
        let instance = String(gameInfo["instanceId"]!)
        
        self.instance = Game(level: level, stock: stocks, venue: venues, account: account, instance: instance)
        
        try write(level, id: instance)
    }
    func stop() throws {
        
        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }
        
        postRequest("\(game_url)/instances/\(id)/stop", jsonObj: obj)
    
    }
    
    func resume() throws {
        
        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }
        
        let gameInfo = postRequest("\(game_url)/instances/\(id)/resume", jsonObj: obj)
        
        let account = String(gameInfo["account"]!)
        let stocks  = gameInfo["tickers"]! as! [String]
        let venues  = gameInfo["venues"]! as! [String]
        let instance = String(gameInfo["instanceId"]!)
        
        self.instance = Game(level: self.instance!.level, stock: stocks, venue: venues, account: account, instance: instance)
    }
    
    func restart() throws {
        
        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        postRequest("\(game_url)/instances/\(id)/restart", jsonObj: obj)
        
    }
    
    func gameInstances() {
        
        let url = "https://api.stockfighter.io/ui/levels"        
        print(getRequest(url))
        
    }
    
    func reset(level: String) throws {
        if let state = read() {
            let gameInfo = postRequest("\(game_url)/instances/\(state[0])/resume", jsonObj: obj)
            if let account = gameInfo["account"] {
                
                let stocks  = gameInfo["tickers"]! as! [String]
                let venues  = gameInfo["venues"]! as! [String]
                let instance = String(gameInfo["instanceId"]!)
                
                self.instance = Game(level: state[1],stock: stocks, venue: venues, account: String(account), instance: instance)
                return
            }
        }
        
        try self.start(level)

    }
    
    func getRequest(url: String) -> Dictionary<String, AnyObject> {
        
        var dict = Dictionary<String, AnyObject>()
        
        HTTPGetJSON(url) {
            (data: Dictionary<String, AnyObject>, error: String?) -> Void in
            
            error != nil ? print("Error on GET Request: \(error)") : (dict = data)
            
        }
        
        return dict
    }
    
    func postRequest(url: String, jsonObj: [String: AnyObject]) -> Dictionary<String, AnyObject> {
        
        var dict = Dictionary<String, AnyObject>()

        HTTPPostJSON(url, jsonObj: jsonObj) {
            (data: Dictionary<String, AnyObject>, error: String?) -> Void in
            
            error != nil ? print("Error on Post Request: \(error)") : (dict = data)
            
        }
        
        return dict
    }
    
    func write(level: String, id: String) throws {
        let text = "\(id) \(level)"
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
            //writing
            do {
                try text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */
                    throw StockFighterErrors.GameNotInitialized
            }
        }
    }
    
    func read() -> [String]? {
        //reading
        var ret: [String]? = nil
        
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(fileName)
            
            do {
                let str = try String(NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding))
                ret = str.characters.split(" ").map { String($0) }
            }
            catch {/* error handling here */}
        }
        
        return ret
    }
    
 }
 

 