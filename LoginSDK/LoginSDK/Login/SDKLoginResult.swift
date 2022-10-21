//
//  SDKLoginResult.swift
//  LoginSDK
//
//  Created by coolishbee on 2022/10/18.
//

import Foundation

@objcMembers
public class SDKLoginResult: NSObject {
    let _value: LoginResult
    init(_ value: LoginResult) { _value = value }
    
    public var userID: String? { return _value.userID }
    
    public var json: String? { return toJSON(_value) }
}
