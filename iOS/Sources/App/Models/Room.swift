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
    
    init() {}

    init(id: UUID? = nil, inviteCode: String, isPrivate: Bool, adminID: UUID) {
        self.id = id
        self.inviteCode = inviteCode
        self.isPrivate = isPrivate
        self.$admin.id = adminID
    }
}
