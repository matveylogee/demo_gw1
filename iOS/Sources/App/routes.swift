import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Группа маршрутов для пользователей
    let userController = UserController()
    app.group("users") { users in
        users.post("register", use: userController.register)
        users.post("login", use: userController.login)
    }

    // Группа маршрутов для игровых комнат
    let roomController = RoomController()
    app.group("rooms") { rooms in
        let protected = rooms.grouped(JWTMiddleware())
        protected.post("create", use: roomController.createRoom)
        protected.post("join", use: roomController.joinRoom)
        protected.post("join-private", use: roomController.joinPrivateRoom)
        
        
        protected.group(":roomID") { room in
            room.post("kick", use: roomController.kickPlayer)
            room.post("start", use: roomController.startGame)
            room.post("pause", use: roomController.pauseGame)
            room.post("close", use: roomController.closeRoom)
            room.get("status", use: roomController.roomStatus)
        }
    }

    // Группа маршрутов для игровой логики
    let gameController = GameController()
    let gameProtected = app.grouped(JWTMiddleware())
    gameProtected.group("game") { game in
        game.post(":roomID/play", use: gameController.playWord)
    }
}

