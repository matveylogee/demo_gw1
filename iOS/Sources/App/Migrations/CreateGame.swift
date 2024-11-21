//
//  CreateGame.swift
//  iOS
//
//  Created by br3nd4nt on 21.11.2024.
//

import Fluent

struct CreateGame: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("games")
            .id()
            .field("roomId", .uuid, .required, .references("rooms", "id"))
            .field("boardStatus", .string, .required) // contains JSON
            .field("currentTurnUserId", .uuid, .required, .references("users", "id"))
            .field("isCompleted", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("games").delete()
    }
}
