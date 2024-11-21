//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import Fluent

struct RoomController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Указываем маршруты в routes.swift, метод boot здесь оставляем пустым.
    }

    // Создание игровой комнаты
    func createRoom(req: Request) throws -> EventLoopFuture<Room> {
        let createRequest = try req.content.decode(CreateRoomRequest.self)
        guard let user = try? req.auth.require(User.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated")
        }

        let room = Room(
            inviteCode: UUID().uuidString.prefix(6).uppercased(),
            isPrivate: createRequest.isPrivate,
            adminID: try user.requireID()
        )
        return room.save(on: req.db).map { room }
    }

    // Присоединение к открытой комнате
    func joinRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let joinRequest = try req.content.decode(JoinRoomRequest.self)
        return Room.find(joinRequest.roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                // Добавить пользователя в комнату
                // Тут можно добавить реализацию добавления участника
                req.eventLoop.makeSucceededFuture(.ok)
            }
    }

    // Присоединение к закрытой комнате через код
    func joinPrivateRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let privateJoinRequest = try req.content.decode(JoinPrivateRoomRequest.self)
        return Room.query(on: req.db)
            .filter(\.$inviteCode == privateJoinRequest.inviteCode)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                // Логика добавления игрока в комнату
                req.eventLoop.makeSucceededFuture(.ok)
            }
    }

    // Удаление игрока из комнаты
    func kickPlayer(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let user = try? req.auth.require(User.self) else {
            throw Abort(.unauthorized)
        }

        let roomID = try req.parameters.require("roomID", as: UUID.self)
        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                do {
                    guard room.$admin.id == user.id else {
                        throw Abort(.forbidden, reason: "Only the admin can kick players")
                    }
                    
                    // Логика удаления игрока
                    return req.eventLoop.makeSucceededFuture(.ok)
                } catch {
                    //MARK: TODO error handling
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ""))
                }
            }
    }

    // Запуск раунда
    func startGame(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        // Логика запуска раунда
        //MARK: TODO - create game
        
        // {
        //  board: [
        //      [' ', ' ', ' ', ... ' '],
        //      ...
        //      
        //  ]
        // }
        
        return req.eventLoop.makeSucceededFuture(.ok)
    }

    // Пауза игры
    func pauseGame(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        // Логика паузы раунда
        return req.eventLoop.makeSucceededFuture(.ok)
    }

    // Закрытие комнаты
    func closeRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                room.delete(on: req.db).transform(to: .ok)
            }
    }

    // Получение статуса комнаты
    func roomStatus(req: Request) throws -> EventLoopFuture<RoomStatusResponse> {
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                // Здесь возвращаем информацию о комнате
                do {
                    return req.eventLoop.makeSucceededFuture(RoomStatusResponse(
                        roomID: try room.requireID(),
                        leaderboard: [],
                        tilesLeft: 100,
                        currentWords: []
                    ))
                } catch {
                    //MARK: TODO error handling
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: ""))
                }
            }
    }
}

// Запросы для маршрутов
struct CreateRoomRequest: Content {
    let isPrivate: Bool
}

struct JoinRoomRequest: Content {
    let roomID: UUID
}

struct JoinPrivateRoomRequest: Content {
    let inviteCode: String
}

struct RoomStatusResponse: Content {
    let roomID: UUID
    let leaderboard: [LeaderboardEntry]
    let tilesLeft: Int
    let currentWords: [String]
}

struct LeaderboardEntry: Content {
    let nickname: String
    let points: Int
}
