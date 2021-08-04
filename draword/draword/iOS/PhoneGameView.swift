//
//  PhoneGameView.swift
//  draword
//
//  Created by Lorenzo Sonnino on 03/08/2021.
//

import SwiftUI

struct AttemptedGuess: Hashable {
    let user: String
    let attempt: String
    var thisUser: Bool = false
    var guess: Bool = true
}

struct PhoneGameView: View {
    @Binding var displayView: DisplayView
    @ObservedObject var gameState: GameState = GameState()
    @ObservedObject var connectionManager: ConnectionManager = ConnectionManager()
    
    @State var points: Int = 0
    @State var attemptedGuesses: [AttemptedGuess] = []
    @State var word: String = ""
    @State var submitted: Bool = false
    
    var body: some View {
        VStack {
            PointsBannerView(points: $points)
            Divider()
            
            AttemptsView(attemptedGuesses: $attemptedGuesses)
            
            switch displayView {
            case .game:
                Divider()
                YourWordView(word: $word, submitted: $submitted, connectionManager: connectionManager)
            default:
                AttemptFieldView(attemptedGuesses: $attemptedGuesses, connectionManager: connectionManager)
            }
        }
        .onAppear {
            connectionManager.messageCallback = onGameMessage
        }
    }
    
    func onGameMessage(message: Message) {
        switch message.type {
        case .broadcastAttempt:
            let att = AttemptedGuess(user: message.user, attempt: message.text)
            attemptedGuesses.append(att)
        case .draw:
            submitted = false
            word = ""
            displayView = .game
        case .game:
            displayView = .guess
        case .point:
            attemptedGuesses.append(AttemptedGuess(user: message.user, attempt: message.text, thisUser: message.val > 0, guess: false))
            points += Int(message.val)
        case .endGame:
            // Todo
            print("Game ended")
        default:
            print("Unsupported type: \(message.type.rawValue)")
        }
    }
}

struct PointsBannerView: View {
    @Binding var points: Int
    
    var body: some View {
        HStack {
            Text("Your points: ")
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(.drawordAccent)
            
            Spacer()
            
            Text("\(points)")
                .font(.custom("ArialRoundedMTBold", size: 30))
                .foregroundColor(.drawordSecondary)
        }
        .padding()
    }
}

struct AttemptsView: View {
    @Binding var attemptedGuesses: [AttemptedGuess]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(Color(.secondaryLabel))
                .opacity(0.25)
            
            ScrollView(.vertical) {
                VStack (spacing: 5) {
                    Text("Attempts made:")
                        .font(.title)
                    
                    Divider()
                    
                    ForEach(attemptedGuesses, id: \.self) { attemptedGuess in
                        HStack {
                            if (attemptedGuess.guess) {
                                Text(attemptedGuess.user + ": ")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(attemptedGuess.thisUser ? .drawordSecondary : Color(.label))
                                Text(attemptedGuess.attempt)
                                    .font(.title3)
                            }
                            else {
                                Spacer()
                                
                                Text("\(attemptedGuess.user) guessed the word !")
                                    .bold()
                                    .font(.title3)
                                    .foregroundColor(.drawordSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .padding()
    }
}
struct AttemptFieldView: View {
    @State var attempt: String = ""
    @Binding var attemptedGuesses: [AttemptedGuess]
    @ObservedObject var connectionManager: ConnectionManager
    
    var body: some View {
        HStack {
            TextField("Take a guess", text: $attempt, onCommit:  {
                send()
            })
                .frame(height: 60)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button {
                send()
            } label: {
                Text("Guess")
                    .bold()
                    .frame(width: 100, height: 50)
                    .foregroundColor(.white)
                    .background(Color.drawordAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .padding()
    }
    
    func send() {
        connectionManager.sendAttempt(attempt: attempt)
        attemptedGuesses.append(AttemptedGuess(user: connectionManager.name, attempt: attempt, thisUser: true, guess: true))
    }
}
struct YourWordView: View {
    @State var shown: Bool = false
    @Binding var word: String
    @Binding var submitted: Bool
    @ObservedObject var connectionManager: ConnectionManager
    
    var body: some View {
        VStack (spacing: 10) {
            HStack {
                Text(submitted ? "Your word is: " : "Choose your word")
                    .foregroundColor(.drawordAccent)
                    .font(.custom("ArialRoundedMTBold", size: 25))
                
                Spacer()
            }
            
            if (submitted) {
                Text(shown ? word : " - tap to show - ")
                    .foregroundColor(.drawordSecondary)
                    .font(.custom("ArialRoundedMTBold", size: 30))
                    .transition(.opacity)
                    .id("ID - Your Word - " + shown.description)
            }
            else {
                HStack {
                    TextField("Your word", text: $word, onCommit:  {
                        send()
                    })
                        .frame(height: 60)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button {
                        send()
                    } label: {
                        Text("Submit")
                            .bold()
                            .frame(width: 100, height: 40)
                            .foregroundColor(.white)
                            .background(Color.drawordAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .padding()
            }
        }
        .padding()
        .contentShape(Rectangle()) // Can tap on the whole area
        .onTapGesture {
            withAnimation(Animation.easeOut(duration: 0.7)) {
                shown.toggle()
            }
        }
    }
    
    func send() {
        submitted = true
        connectionManager.submitWord(submit: word)
    }
}

struct PhoneGameView_Previews: PreviewProvider {
    private static let attemptedGuesses = [
        AttemptedGuess(user: "Alberto", attempt: "House"),
        AttemptedGuess(user: "Lorenzo", attempt: "Game", thisUser: true),
        AttemptedGuess(user: "Laura", attempt: "Draword"),
        AttemptedGuess(user: "Alberto", attempt: "Computer"),
        AttemptedGuess(user: "Alberto", attempt: "I don\'t know"),
        AttemptedGuess(user: "Laura", attempt: "Me neither"),
        AttemptedGuess(user: "Lorenzo", attempt: "Game", thisUser: true),
        AttemptedGuess(user: "Lorenzo", attempt: "House", thisUser: true),
        AttemptedGuess(user: "Laura", attempt: "Fish"),
        AttemptedGuess(user: "Laura", attempt: "Fish", thisUser: false, guess: false)
    ]
    
    static var previews: some View {
        PhoneGameView(displayView: .constant(.game), attemptedGuesses: attemptedGuesses)
    }
}
