//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor

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
                // Проверяем слово, обновляем доску и лидерборд
                let isValidWord = self.validateWord(playRequest.word)
                guard isValidWord else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Invalid word"))
                }
                
                // Обновляем состояние игры (доску, буквы игрока, очки)
                // ...
                
                return req.eventLoop.makeSucceededFuture(.ok)
            }
    }
    
    // Валидация слова (простая заглушка, можно подключить словарь)
    private func validateWord(_ word: String) -> Bool {
        // Здесь можно подключить проверку с внешним API или словарем
        return word.count >= 2
    }
}

// Запросы для маршрутов
struct PlayWordRequest: Content {
    let word: String
    let tiles: [String]
}

