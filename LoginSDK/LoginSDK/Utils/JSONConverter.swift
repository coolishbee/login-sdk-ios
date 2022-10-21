//
//  JSONConverter.swift
//  LoginSDK
//
//  Created by coolishbee on 2022/10/18.
//

import Foundation

private let encoder = JSONEncoder()

func toJSON<T: Encodable>(_ value: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let data = try? encoder.encode(value) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}
