//
//  File.swift
//
//
//  Created by Sujin Jin on 2023/03/29.
//
import SwiftUI
import UIKit

public struct ScreenSize: EnvironmentKey {
    public static let defaultValue: CGSize = UIScreen.main.bounds.size
}

public extension EnvironmentValues {
    var screenSize: CGSize {
        self[ScreenSize.self]
    }
}
