//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import Fluent

final class User: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "passwordHash")
    var passwordHash: String

    init() {}

    init(id: UUID? = nil, nickname: String, passwordHash: String) {
        self.id = id
        self.nickname = nickname
        self.passwordHash = passwordHash
    }
}
