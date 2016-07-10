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
    let apikey   = "123456123456123456123456123456123456123456"

    let validLevels = ["first_steps","sell_side","chock_a_block"]

    var instance: Game? = nil

    let router =  Router()


    // Todo: Socket Setup //

    // Heartbeat functions //

    func heartbeat() -> Heartbeat {
        guard let val = get(atURL: "\(base_url)/heartbeat") else {
            return Heartbeat(ok: false, error: StockFighterErrors.NoResponseFound)
        }

        return val["ok"] as! String == "1" ? Heartbeat(ok: true) :
                                             Heartbeat(ok: false,
                                                    error: StockFighterErrors.ErrorFromServer(val["error"] as! String))
    }

    // Purpose; checks to see if the venue is up, if not restarts the game to get it working again
    func heartbeat(venue: String) throws -> Heartbeat {

        guard let val = get(atURL: "\(base_url)/venues/\(venue)/heartbeat") else {
            return Heartbeat(ok: false, error: StockFighterErrors.NoResponseFound)
        }

        return val["ok"] as! String == "1" ? Heartbeat(ok: true, venue: venue) :
                                             Heartbeat(ok: false, venue: venue,
                                                    error: StockFighterErrors.ErrorFromServer(val["error"] as! String))
    }

    // Game setup functions //

    func start(level: String, count: Int = 0) throws {
        if count == 0 { print("Trying to Connect to level: \(level)") }
        else if count == 1 { print("Trying Again...") }
        else if count == 2 { print("Trying One More Time...") }
        else {
            print(StockFighterErrors.ErrorStartingLevel(level))
            exit(1)
        }

        guard validLevels.contains(level) else {
            throw StockFighterErrors.InvalidLevel
        }

        guard let gameInfo = post(atURL: "\(game_url)/levels/\(level)", jsonObj: obj)
                  where gameInfo["error"] == nil else {

            try self.start(level: level, count: count + 1)
            return
        }

        self.instance = Parser.parseGameInfo(level: level, gameInfo: gameInfo)

        try Utilities.write(level: level, id: self.instance!.ID)
    }

    func stop() throws {

        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        let _ = post(atURL: "\(game_url)/instances/\(id)/stop", jsonObj: obj)

    }

    func resume() throws {

        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        guard let gameInfo = post(atURL: "\(game_url)/instances/\(id)/resume", jsonObj: obj)
                where gameInfo.count > 2 else {
            return
        }

        self.instance = Parser.parseGameInfo(level: self.instance!.level, gameInfo: gameInfo)
    }

    func restart() throws {

        guard let id = self.instance?.ID else { throw StockFighterErrors.GameNotInitialized }

        let _ = post(atURL: "\(game_url)/instances/\(id)/restart", jsonObj: obj)

    }

    func gameInstances() {

        let url = "https://api.stockfighter.io/trainer/levels"
        print(get(atURL: url))

    }

    func reset(level: String) throws -> Void {
        print("////////////////////////////////////////")
        print("////////     Resetting Game     ////////")
        print("////////////////////////////////////////")

        guard let state = Utilities.read() else {
            try self.start(level: level)
            return
        }

        guard let gameInfo = post(atURL: "\(game_url)/instances/\(state[0])/resume", jsonObj: obj)
                where gameInfo["error"] == nil else {
            return try self.start(level: level)
        }

        self.instance = Parser.parseGameInfo(level: state[1], gameInfo: gameInfo)
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

        router.post(withUrl: atURL, jsonObj: jsonObj) {
            data, error in

            error != nil ? print("Post Manager", error) : (dict = data)

        }

        return dict
    }
 }
