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

let TIMER_LENGTH = 60

let MIN_NUM_OF_ROUNDS = 2
let MAX_NUM_OF_ROUNDS = 5
let DEFAULT_NUM_OF_ROUNDS = 3
var numOfRounds = DEFAULT_NUM_OF_ROUNDS

/*
 The messages sent between peers
 {MESSAGE_TYPE} - {sender} - {description}
    - {arg_1} - {description}
    - {arg_2} - {description}
 
 GAME - iPad - The game starts or the player has to get back to game state
 
 SUBMIT - iPhone - The user who has to choose a word submit his words
    - text - The word
 
 ATTEMPT - iPhone - An user tried to guess the word
    - text - The attempted guess the user made
    - userIndex - The index of the user who made the attempt as in the iPad's connectionManager
            It is sent automatically by the connectionManager on message reception, iPad side
 
 BROADCAST_ATTEMPT - iPad - Another user tried to guess the word
    - var - The number of characters that constitute the username
    - text - The attempted guess
    - user - The username of the user
 
 POINT - iPad - Someone guessed the word
    - text - The username of the user who got the point
    - val - 1 if the user is the one who guessed it, 0 otherwise
 
 DRAW - iPad - The user is the one who has to draw
 
 END_GAME - iPad - The game ended
    - text - The username of the player who won
    - val - The number of points the user has
 */
enum MessageType: UInt8 {
    case game = 1
    case attempt = 2
    case broadcastAttempt = 3
    case point = 4
    case submit = 5
    case draw = 6
    case endGame = 7
}
struct Message {
    var type: MessageType = .game
    var val: UInt8 = 0
    var text: String = ""
    var user: String = ""
    var userIndex: Int = 0 // Filled by ConnectionManager on reception
    
    static func encode(message: Message) -> Data {
        let textData = message.text.data(using: .utf8)
        
        switch message.type {
        case .game, .draw:
            var data = Data(count: 1)
            data[0] = message.type.rawValue
            return data
        case .attempt, .submit:
            var data = Data(count: 1 + textData!.count)
            data[0] = message.type.rawValue
            data.replaceSubrange((1...textData!.count + 0), with: textData!)
            return data
        case .broadcastAttempt:
            let userData = message.user.data(using: .utf8)
            
            var data = Data(count: 2 + textData!.count + userData!.count)
            data[0] = message.type.rawValue
            data[1] = UInt8(userData!.count)
            data.replaceSubrange((2...userData!.count + 1), with: userData!)
            data.replaceSubrange((userData!.count + 2...textData!.count + userData!.count + 1), with: textData!)
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
        case .attempt, .submit:
            message.text = String(data: data.suffix(from: 1), encoding: .utf8)!
        case .broadcastAttempt:
            message.val = data[1]
            message.user = String(data: data.subdata(in: (2..<Int(message.val) + 2)), encoding: .utf8)!
            message.text = String(data: data.suffix(from: Int(message.val) + 2), encoding: .utf8)!
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
    @Published var usernames: [String] = []
    @Published var points: [Int] = []
    
    func set(connectionManager: ConnectionManager) {
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
