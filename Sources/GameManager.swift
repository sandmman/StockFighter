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
    let fileName = "sandbox/StockFighter/Sources/storage.txt"
    let apikey   = "123456123456123456123456123456123456123456"

    let validLevels = ["first_steps","sell_side","chock_a_block"]

    var instance: Game?

    let router =  Router()

    init() {
        instance = nil
    }

    // Todo: Socket Setup //

    // Heartbeat functions //

    func heartbeat() throws -> [String: AnyObject] {
        guard let val = get(atURL: "https://api.stockfighter.io/ob/api/heartbeat")
              where val["ok"] != nil && val["ok"]! as! Int == 1 else {
            throw StockFighterErrors.StockFighterServersAreDown
        }

        return val
    }

    // Purpose; checks to see if the venue is up, if not restarts the game to get it working again
    func heartbeat(venue: String) throws -> [String: AnyObject]? {

        guard let val = get(atURL: "https://api.stockfighter.io/ob/api/venues/\(venue)/heartbeat")
                where val["ok"] != nil else {
                    throw StockFighterErrors.StockFighterServersAreDown
        }
        // Check to see if the venue is not up
        if val["ok"] as! Int == 0 {
            try stop()
            try start(level: instance!.level)
        }

        return val
    }

    // Game setup functions //

    func start(level: String) throws {
        guard validLevels.contains(level) else {
            throw StockFighterErrors.InvalidLevel
        }

        guard let gameInfo = post(atURL: "\(game_url)/levels/\(level)", jsonObj: obj) else {
            return
        }

        guard gameInfo["error"] == nil else {
            try self.start(level: level)
            return
        }

        let stocks   = gameInfo["tickers"] as! [String]
        let venues   = gameInfo["venues"]  as! [String]
        let account  = gameInfo["account"] as! String
        let instance = gameInfo["instanceId"] as! String

        self.instance = Game(level: level, stock: stocks, venue: venues, account: account, instance: instance)

        try write(level: level, id: instance)
    }

    func stop() throws {

        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        post(atURL: "\(game_url)/instances/\(id)/stop", jsonObj: obj)

    }

    func resume() throws {

        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        guard let gameInfo = post(atURL: "\(game_url)/instances/\(id)/resume", jsonObj: obj) else {
            return
        }

        let account = gameInfo["account"] as! String
        let stocks  = gameInfo["tickers"] as! [String]
        let venues  = gameInfo["venues"] as! [String]
        let instance = String(gameInfo["instanceId"])

        self.instance = Game(level: self.instance!.level, stock: stocks, venue: venues, account: account, instance: instance)
    }

    func restart() throws {

        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        post(atURL: "\(game_url)/instances/\(id)/restart", jsonObj: obj)

    }

    func gameInstances() {

        let url = "https://api.stockfighter.io/trainer/levels"
        print(get(atURL: url))

    }

    func reset(level: String) throws {
        guard let state = read() else {
            try self.start(level: level)
            return
        }

        guard let gameInfo = post(atURL: "\(game_url)/instances/\(state[0])/resume", jsonObj: obj)
                    where gameInfo.count > 0 else {
            throw StockFighterErrors.GameNotInitialized
        }

        guard gameInfo["error"] == nil else {
            try self.start(level: level)
            return
        }

        let account = gameInfo["account"] as! String
        let stocks  = gameInfo["tickers"] as! [String]
        let venues  = gameInfo["venues"] as! [String]
        let instance = String(gameInfo["instanceId"]!)

        self.instance = Game(level: state[1],stock: stocks, venue: venues, account: String(account), instance: instance)
        return
    }

    func get(atURL: String) -> [String: AnyObject]? {

        var dict: [String: AnyObject]?  = nil

        router.get(withUrl: atURL) {
            data, error in

            error != nil ? print("Get Manager", error) : (dict = data)

        }

        return dict
    }

    func post(atURL: String, jsonObj: [String: AnyObject]) -> [String: AnyObject]? {

        var dict: [String: AnyObject]? = nil
        print("---",atURL, "---")
        router.post(withUrl: atURL, jsonObj: jsonObj) {
            data, error in

            error != nil ? print("Post Manager", error) : (dict = data)

        }

        return dict
    }

    func write(level: String, id: String) throws {
        let text = "\(id) \(level)"
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.documentDirectory, NSSearchPathDomainMask.allDomainsMask, true).first {

            let path = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)

            do {
                try text.write(to: path, atomically: false, encoding: NSUTF8StringEncoding)
            } catch {/* error handling here */
                throw StockFighterErrors.GameNotInitialized
            }
        }
    }

    func read() -> [String]? {
        var ret: [String]? = nil

        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.documentDirectory, NSSearchPathDomainMask.allDomainsMask, true).first {

            let path = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)

            do {
                let str = try String(NSString(contentsOf: path, encoding: NSUTF8StringEncoding))
                ret = str.characters.split(separator: " ").map { String($0) }
            }
            catch {/* error handling here */}
        }

        return ret
    }

 }
