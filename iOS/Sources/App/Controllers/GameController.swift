//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import Foundation

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Указываем маршруты в routes.swift, метод boot здесь оставляем пустым.
    }

    // Логика хода игрока
    func playWord(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let playRequest = try req.content.decode(PlayWordRequest.self)
        
        // Проверяем наличие комнаты
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                // Ensure the room has a current game ID
                guard let currentGameId = room.currentGameId else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "No current game found for this room"))
                }

                // Find the current game using the currentGameId from the room
                return Game.find(currentGameId, on: req.db)
                    .unwrap(or: Abort(.notFound, reason: "Game not found"))
                    .flatMap { game in
                        // Check if the word is valid
                        let isValidWord = self.validateWord(playRequest.word)
                        guard isValidWord else {
                            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Invalid word"))
                        }

                        var board: Board
                        var updatedBoard: String
                        var x: Int = playRequest.firstLetterX
                        var y: Int = playRequest.firstLetterY
                        do {
                            board = try Board.fromJSON(game.boardStatus)
                        } catch {
                            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Error parsing from JSON"))
                        }
                        
                        for letter in playRequest.word {
                            if board.isValidMove(at: y, col: x, letter: letter.uppercased()) {
                                continue
                            } else {
                                return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Invalid word"))
                            }
                        }
                        
                        //TODO: check other words that can be created
                        
                        for letter in playRequest.word {
                            _ = board.placeLetter(at: y, col: x, letter: letter.uppercased())
                        }
                        do {
                            updatedBoard = try board.toJSON()
                        } catch {
                            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Error parsing to JSON"))
                        }
                        

                        
                        game.boardStatus = updatedBoard
                        
                        return game.save(on: req.db).map {
                            .ok
                        }
                    }
            }
     
    }
    
    // Валидация слова (простая заглушка, можно подключить словарь)
    private func validateWord(_ word: String) -> Bool {
        // Здесь можно подключить проверку с внешним API или словарем
        // https://developer.wordnik.com/pricing (100 reqests per hour)
        return word.count >= 2
    }
    
    private func evaluateMove() {
        
    }
}

// Запросы для маршрутов
struct PlayWordRequest: Content {
    let word: String
    let tiles: [String]
    let isHorizontal: Bool
    let firstLetterX: Int
    let firstLetterY: Int
}

struct Board: Codable {
    var board: [[String]]
    
    init(rows: Int, cols: Int) {
        self.board = Array(repeating: Array(repeating: " ", count: cols), count: rows)
    }
    
    func isValidMove(at row: Int, col: Int, letter: String) -> Bool {
        return row >= 0 && row < board.count && col >= 0 && col < board[row].count && (board[row][col] == " " || board[row][col] == letter)
    }
    
    mutating func placeLetter(at row: Int, col: Int, letter: String) -> Bool {
        if isValidMove(at: row, col: col, letter: letter) {
            board[row][col] = letter
            return true
        }
        return false
    }
}

extension Board {
    func toJSON() throws -> String {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return jsonString
    }
    
    static func fromJSON(_ jsonString: String) throws -> Board {
            let decoder = JSONDecoder()
            let jsonData = Data(jsonString.utf8)
            let board = try decoder.decode(Board.self, from: jsonData)
            return board
    }
}
