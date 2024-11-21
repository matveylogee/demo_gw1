//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import Fluent

final class Room: Model, Content {
    static let schema = "rooms"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "inviteCode")
    var inviteCode: String
    
    @Field(key: "isPrivate")
    var isPrivate: Bool
    
    @Parent(key: "adminId")
    var admin: User
    
    @Field(key: "participations")
    var participations: [UUID]
    
    @Field(key: "isStart")
    var isStart: Bool
    
    @Field(key: "isPause")
    var isPause: Bool
    
    init() {}

    init(id: UUID? = nil, inviteCode: String, isPrivate: Bool, adminID: UUID, participations: [UUID] = [], isStart: Bool = false, isPause: Bool = false) {
        self.id = id
        self.inviteCode = inviteCode
        self.isPrivate = isPrivate
        self.$admin.id = adminID
        self.participations = participations
        self.isStart = isStart
        self.isPause = isPause
    }
}
