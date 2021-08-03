//
//  GamePlay.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import Foundation

let MIN_NUM_OF_PLAYERS = 2
let MAX_NUM_OF_PLAYERS = 4
let DEFAULT_NUM_OF_PLAYERS = 3

let CODE_LENGTH = 4

/*
 The messages sent between peers
 {MESSAGE_TYPE} - {sender} - {description}
    - {arg_1} - {description}
    - {arg_2} - {description}
 
 GAME_START - iPad - The game starts
 
 ATTEMPT - iPhone - An user
    - text - The attempted guess the user made
 
 POINT - iPad - Someone guessed the word
    - text - The username of the user who got the point
    - val - 1 if the user is the one who guessed it, 0 otherwise
 
 DRAW - iPad - The user is the one who has to draw
    - text - The word he has to draw
 
 END_GAME - iPad - The game ended
    - text - The username of the player who won
    - val - The number of points the user has
 */
enum MessageType: UInt8 {
    case gameStart = 1
    case attempt = 2
    case point = 3
    case draw = 4
    case endGame = 5
}
struct Message {
    var type: MessageType = .gameStart
    var val: UInt8 = 0
    var text: String = ""
    
    static func encode(message: Message) -> Data {
        let textData = message.text.data(using: .utf8)
        
        switch message.type {
        case .gameStart:
            var data = Data(count: 1)
            data[0] = message.type.rawValue
            return data
        case .attempt, .draw:
            var data = Data(count: 1 + textData!.count)
            data[0] = message.type.rawValue
            data.replaceSubrange((1...textData!.count + 0), with: textData!)
            return data
        case .point, .endGame:
            var data = Data(count: 2 + textData!.count)
            data[0] = message.type.rawValue
            data[1] = message.val
            data.replaceSubrange((2...textData!.count + 1), with: textData!)
            return data
        }
    }
    static func decode(from data: Data) -> Message {
        var message = Message()
        
        guard let type = MessageType(rawValue: data[0]) else { return message }
        message.type = type
        
        switch message.type {
        case .attempt, .draw:
            message.text = String(data: data.suffix(from: 1), encoding: .utf8)!
        case .point, .endGame:
            message.val = data[1]
            message.text = String(data: data.suffix(from: 2), encoding: .utf8)!
        default:
            break
        }
        
        return message
    }
}

class GameState: ObservableObject {
    @Published var usernames: [String]
    @Published var points: [Int]
    
    init(connectionManager: ConnectionManager) {
        self.usernames = connectionManager.usernames
        self.points = [Int](repeating: 0, count: connectionManager.usernames.count)
    }
    
    func getWinner() -> [Int] {
        let maxScore = self.points.max()
        return self.points.indices.filter({
            self.points[$0] == maxScore
        })
    }
}
