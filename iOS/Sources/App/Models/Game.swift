//
//  Game.swift
//  iOS
//
//  Created by br3nd4nt on 21.11.2024.
//


import Vapor
import Fluent

final class Game: Model, Content {
    static let schema = "games"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "roomId")
    var room: Room
    
    @Field(key: "boardStatus")
    var boardStatus: String // JSON
    
    
    @Parent(key: "currentTurnUserId")
    var currentTurnUser: User
    
    @Field(key: "isCompleted")
    var isCompleted: Bool
    
    init() {}

    init(id: UUID? = nil, roomId: UUID, boardStatus: String, currentTurnUserId: UUID, isCompleted: Bool) {
        self.id = id
        self.$room.id = roomId
        self.boardStatus = boardStatus
        self.$currentTurnUser.id = currentTurnUserId
        self.isCompleted = isCompleted
    }
}
