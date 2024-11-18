//
//  File.swift
//  iOS
//
//  Created by Матвей on 18.11.2024.
//

import Vapor

struct LoginRequest: Content {
    let nickname: String
    let password: String
}
