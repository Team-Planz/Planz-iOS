//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//

import ComposableArchitecture
import Foundation

public struct PromiseTimeDetailFeature: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public init() {}

        public var promiseName: String = ""
        public var placeAndThemeName: String = ""
        public var showAttedeeModal: Bool = false
    }

    public enum Action: Equatable {
        case profileIconTapped
        case shareTapped
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .profileIconTapped:
                state.showAttedeeModal = !state.showAttedeeModal
                return .none
            case .shareTapped:
                // TODO: 링크 공유 버튼 로직 추가
                return .none
            }
        }
    }
}
