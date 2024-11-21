import Fluent
import Vapor

func routes(_ app: Application) throws {
    return
    // Группа маршрутов для пользователей
    let userController = UserController()
    app.group("users") { users in
        users.post("register", use: userController.register)
        users.post("login", use: userController.login)
    }

    // Группа маршрутов для игровых комнат
    let roomController = RoomController()
    app.group("rooms") { rooms in
        rooms.post("create", use: roomController.createRoom)
        rooms.post("join", use: roomController.joinRoom)
        rooms.post("join-private", use: roomController.joinPrivateRoom)
        
        // Защищенные маршруты (требуют авторизации)
        let protected = rooms.grouped(JWTMiddleware())
        protected.post(":roomID/kick", use: roomController.kickPlayer)
        protected.post(":roomID/start", use: roomController.startGame)
        protected.post(":roomID/pause", use: roomController.pauseGame)
        protected.post(":roomID/close", use: roomController.closeRoom)
        protected.get(":roomID/status", use: roomController.roomStatus)
    }

    // Группа маршрутов для игровой логики
    let gameController = GameController()
    let gameProtected = app.grouped(JWTMiddleware())
    gameProtected.group("game") { game in
        game.post(":roomID/play", use: gameController.playWord)
    }
}

