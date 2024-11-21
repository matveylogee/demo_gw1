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
        
        guard let user = try? req.jwt.verify(as: UserPayload.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated")
        }

        let room = Room(
            inviteCode: UUID().uuidString.prefix(6).uppercased(),
            isPrivate: createRequest.isPrivate,
            adminID: user.id,
            participations: [user.id],
            isStart: false,
            isPause: false
        )
        return room.save(on: req.db).map { room }
    }

    // Присоединение к открытой комнате
    func joinRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let user = try? req.jwt.verify(as: UserPayload.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated")
        }
        
        let joinRequest = try req.content.decode(JoinRoomRequest.self)
        let userID = user.id
        
        return Room.find(joinRequest.roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                
                room.participations.append(userID)
                return room.save(on: req.db).map { .ok }
            }
    }

    // Присоединение к закрытой комнате через код
    func joinPrivateRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let user = try? req.jwt.verify(as: UserPayload.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated")
        }
        
        let userID = user.id
        let privateJoinRequest = try req.content.decode(JoinPrivateRoomRequest.self)
        
        return Room.query(on: req.db)
            .filter(\.$inviteCode == privateJoinRequest.inviteCode)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMap { room in
                
                room.participations.append(userID)
                return room.save(on: req.db).map { .ok }
            }
    }

    // Удаление игрока из комнаты
    func kickPlayer(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Получаем текущего пользователя из авторизации
        guard let user = try? req.jwt.verify(as: UserPayload.self) else {
            throw Abort(.unauthorized)
        }

        let roomID = try req.parameters.require("roomID", as: UUID.self)
        let playerID = try req.content.decode(KickPlayerRequest.self).playerID
        let userID = user.id

        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMapThrowing { (room: Room) in
                
                guard room.$admin.id == userID else {
                    throw Abort(.forbidden, reason: "Only the admin can kick players")
                }

                guard let playerIndex = room.participations.firstIndex(of: playerID) else {
                    throw Abort(.notFound, reason: "Player not found in the room")
                }


                room.participations.remove(at: playerIndex)
                return room
            }
            .flatMap { room in
                room.save(on: req.db).transform(to: .ok) // Возвращаем статус 200 OK
            }
    }

    // Запуск раунда
    func startGame(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        
        guard let user = try? req.jwt.verify(as: UserPayload.self) else {
            throw Abort(.unauthorized)
        }
        
        let userID = user.id
        
        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMapThrowing { room in
                
                guard room.$admin.id == userID else {
                    throw Abort(.forbidden, reason: "Only the admin can kick players")
                }

                room.isStart = true
                return room
            }
            .flatMap { room in
                return room.save(on: req.db).transform(to: .ok) // Возвращаем статус 200 OK
            }
    }

    // Пауза игры
    func pauseGame(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let roomID = try req.parameters.require("roomID", as: UUID.self)
        
        guard let user = try? req.jwt.verify(as: UserPayload.self) else {
            throw Abort(.unauthorized)
        }
        
        let userID = user.id
        
        return Room.find(roomID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Room not found"))
            .flatMapThrowing { room in
                
                guard room.$admin.id == userID else {
                    throw Abort(.forbidden, reason: "Only the admin can kick players")
                }

                room.isPause = true
                return room
            }
            .flatMap { room in
                return room.save(on: req.db).transform(to: .ok) // Возвращаем статус 200 OK
            }
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
            .flatMapThrowing { room in
                // Здесь возвращаем информацию о комнате
                return RoomStatusResponse(
                    roomID: try room.requireID(),
                    leaderboard: [],
                    tilesLeft: 100,
                    currentWords: []
                )
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

struct KickPlayerRequest: Content {
    let playerID: UUID
}
