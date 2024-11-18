//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Fluent

struct CreateLeaderboard: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("leaderboards")
            .id()
            .field("roomId", .uuid, .required, .references("rooms", "id"))
            .field("nickname", .string, .required)
            .field("points", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("leaderboards").delete()
    }
}
