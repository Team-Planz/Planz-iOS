//
//  Extensions.swift
//
//
//  Created by Sujin Jin on 2023/03/15.
//

import Foundation

extension Array where Element == String {
    func joinedNames(separator: String) -> String {
        var result = ""
        for index in 0 ..< count {
            let separator = (index == count - 1) ? "" : separator
            let name = self[index]
            if index % 4 == 3 {
                result += "\(name)\n"
            } else {
                result += "\(name)\(separator)"
            }
        }
        return result
    }
}
