//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/01.
//

import APIClient
import ComposableArchitecture
import Foundation

public struct SharePromiseState {}

public enum SharePromiseAction {
    case viewDidAppear
    case copyLinkTapped
    case shareAsKakaoTapped
}

public struct SharePromiseEnvironment {
    public init() {}
}

public let sharePromiseReducer = AnyReducer<
    SharePromiseState,
    SharePromiseAction,
    SharePromiseEnvironment
> { _, action, _ in
    switch action {
    case .viewDidAppear:
        return .none
    case .copyLinkTapped:
        return .none
    case .shareAsKakaoTapped:
        return .none
    }
}
