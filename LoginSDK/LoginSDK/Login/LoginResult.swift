//
//  LoginResult.swift
//  LoginSDK
//
//  Created by coolishbee on 2022/10/18.
//

import Foundation

public struct LoginResult: Encodable {
    let userID: String?
    let name: String?
    let email: String?
    let imageURL: URL?
    let idToken: String?
}
