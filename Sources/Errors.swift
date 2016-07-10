//
//  Errors.swift
//  StockFighter
//
//  Created by Aaron Liberatore on 5/27/16.
//  Copyright © 2016 Aaron Liberatore. All rights reserved.
//


enum StockFighterErrors: ErrorProtocol {

    case StockFighterServersAreDown
    case ErrorReceivingData
    case InvalidInput
    case InvalidLevel
    case GameNotInitialized
    case NoResponseFound
    case ErrorStartingLevel(String)
    case ErrorFromServer(String)


}
