//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import Fluent
import JWT

struct UserController: RouteCollection {
    
    // Устанавливаем JWT секрет
    // app.jwt.signers.use(.hs256(key: "your-secret-key"))
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("register", use: register)
        users.post("login", use: login)
    }

    // Метод для логина с JWT
    func login(req: Request) throws -> EventLoopFuture<TokenResponse> {
        // Декодируем данные из запроса
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        // Проверяем наличие пользователя с указанным никнеймом
        return User.query(on: req.db)
            .filter(\.$nickname == loginRequest.nickname)
            .first()
            .unwrap(or: Abort(.unauthorized, reason: "Invalid nickname or password."))
            .flatMap { user in
                // Сравниваем хеш пароля
                do {
                    if try Bcrypt.verify(loginRequest.password, created: user.passwordHash) {
                        // Генерация JWT
                        let payload = UserPayload(id: user.id!, nickname: user.nickname)
                        let token = try req.jwt.sign(payload)
                        return req.eventLoop.future(TokenResponse(token: token))
                    } else {
                        return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid nickname or password."))
                    }
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
    }

    func register(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        user.passwordHash = try Bcrypt.hash(user.passwordHash)
        return user.save(on: req.db).map { user }
    }
    
}

