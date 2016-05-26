 //
//  manager.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/22/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//

import Foundation

 enum StockFighterErrors: ErrorType {
    case NotValidLevel
    case GameNotInitialized
 }
 
 public class StockFighter {
    
    let game_url = "https://www.stockfighter.io/gm"
    let base_url = "https://api.stockfighter.io/ob/api"
    let webSocket_url = "wss://api.stockfighter.io/ob/api/ws/"
    let storage_file = "Projects/StockFighter/StockFighter/storage.txt"
    let apikey  = "123456123456123456123456123456123456123456"
    
    let validLevels = ["first_steps","sell_side","chock_a_block"]
    
    var instance: Game?
    
    init() {
        instance = nil
    }
    
    // Todo: Socket Setup //
    
    // Game setup functions //
    
    func start(level: String) throws {
        
        if !validLevels.contains(level)  {
            throw StockFighterErrors.NotValidLevel
        }
        
        let gameInfo = gameManager("\(game_url)/levels/\(level)")
        
        let stocks   = gameInfo["tickers"]! as! [String]
        let venues   = gameInfo["venues"]! as! [String]
        let account  = String(gameInfo["account"]!)
        let instance = String(gameInfo["instanceId"]!)
        
        self.instance = Game(stock: stocks, venue: venues, account: account, instance: instance)
        
        write(instance)
    }
    func stop() throws {
        
        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }
        
        gameManager("\(game_url)/instances/\(id)/stop")
        
        // Clear Game data
        //self.instance!.ID = nil
    
    }
    
    func resume() throws {
        
        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }
        
        let gameInfo = gameManager("\(game_url)/instances/\(id)/resume")
        
        let account = String(gameInfo["account"]!)
        let stocks  = gameInfo["tickers"]! as! [String]
        let venues  = gameInfo["venues"]! as! [String]
        let instance = String(gameInfo["instanceId"]!)
        
        self.instance = Game(stock: stocks, venue: venues, account: account, instance: instance)
    }
    
    func restart() throws {
        
        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }
        print("\(game_url)/instances/\(id)/restart")
        gameManager("\(game_url)/instances/\(id)/restart")
        
    }
    
    func gameInstances() {
        var dict = Dictionary<String, AnyObject>()
        HTTPGetJSON("https://api.stockfighter.io/ui/levels") {
            (data: Dictionary<String, AnyObject>, error: String?) -> Void in
            
            if error != nil {
                print("Error \(error)")
            } else {
                dict = data
            }
            
        }
        print(dict)
        
    }
    
    func reset(level: String) throws {
        if let id = read() {
            let gameInfo = gameManager("\(game_url)/instances/\(id)/resume")
            if let account = gameInfo["account"] {
                
                let stocks  = gameInfo["tickers"]! as! [String]
                let venues  = gameInfo["venues"]! as! [String]
                let instance = String(gameInfo["instanceId"]!)
                
                self.instance = Game(stock: stocks, venue: venues, account: String(account), instance: instance)
                return
            }
        }
        
        try self.start(level)

    }
    private func gameManager(url: String) -> Dictionary<String, AnyObject>{
        
        var dict = Dictionary<String, AnyObject>()

        HTTPPostJSON(url, jsonObj: "null") {
            (data: Dictionary<String, AnyObject>, error: String?) -> Void in
            
            if error != nil {
                print("Error \(error)")
            } else {
                dict = data
            }
            
        }
        
        return dict
    }
    func write(text: String) {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(storage_file)
            //writing
            do {
                try text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
        }
    }
    func read() -> String? {
        //reading
        var ret: String? = nil
        
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(storage_file)
            
            do {
                ret = try String(NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding))
            }
            catch {/* error handling here */}
        }
        
        return ret
    }
 }
 

 