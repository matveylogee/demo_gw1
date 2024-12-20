//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Fluent

struct CreateRoom: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms")
            .id()
            .field("inviteCode", .string, .required)
            .field("isPrivate", .bool, .required)
            .field("adminId", .uuid, .required, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms").delete()
    }
}
