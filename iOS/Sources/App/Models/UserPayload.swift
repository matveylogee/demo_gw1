//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor
import JWT

struct UserPayload: JWTPayload {
    var id: UUID
    var nickname: String
    var exp: ExpirationClaim

    init(id: UUID, nickname: String, expiration: TimeInterval = 3600) {
        self.id = id
        self.nickname = nickname
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(expiration))
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
