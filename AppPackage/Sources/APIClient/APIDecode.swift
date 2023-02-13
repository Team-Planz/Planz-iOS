//
//  APIDecode.swift
//
//
//  Created by junyng on 2023/02/13.
//

import Foundation

private let jsonDecoder = JSONDecoder()

public func decode<Model: Decodable>(as _: Model.Type, from data: Data) throws -> Model {
    return try jsonDecoder.decode(Model.self, from: data)
}
