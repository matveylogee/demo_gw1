//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import Fluent

final class Leaderboard: Model, Content {
    static let schema = "leaderboards"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "roomId")
    var room: Room
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "points")
    var points: Int
    
    init() {}

    init(id: UUID? = nil, roomId: UUID, nickname: String, points: Int) {
        self.id = id
        self.$room.id = roomId
        self.nickname = nickname
        self.points = points
    }
}

