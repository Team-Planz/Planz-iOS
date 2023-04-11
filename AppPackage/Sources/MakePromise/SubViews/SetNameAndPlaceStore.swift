//
//  SetNameAndPlaceStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/18.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import APIClient
import APIClientLive
import ComposableArchitecture
import Foundation

public struct SetNameAndPlace: ReducerProtocol {
    public struct State: Equatable {
        public var id: Int
        var maxCharacter: Int
        var promiseNamePlaceholder: String
        var promiseName: String
        var promisePlace: String

        public init(
            id: Int = .init(),
            maxCharacter: Int = 10,
            promiseNamePlaceholder: String = .init(),
            promiseName: String = .init(),
            promisePlace: String = .init()
        ) {
            self.id = id
            self.maxCharacter = maxCharacter
            self.promiseNamePlaceholder = promiseNamePlaceholder
            self.promiseName = promiseName
            self.promisePlace = promisePlace
        }

        var numberOfCharacterInNameText: Int {
            if promiseName.count <= maxCharacter {
                return promiseName.count
            } else {
                return maxCharacter
            }
        }

        var numberOfCharacterInPlaceText: Int {
            if promisePlace.count <= maxCharacter {
                return promisePlace.count
            } else {
                return maxCharacter
            }
        }

        var shouldShowNameTextCountWarning: Bool {
            promiseName.count > maxCharacter
        }

        var shouldShowPlaceTextCountWarning: Bool {
            promisePlace.count > maxCharacter
        }

        var isNextButtonEnable: Bool {
            (numberOfCharacterInNameText > 0 && !shouldShowNameTextCountWarning) && (numberOfCharacterInPlaceText > 0 && !shouldShowPlaceTextCountWarning)
        }
    }

    public enum Action: Equatable {
        case task
        case placeHintResponse(TaskResult<SharedModels.CategoryName>)
        case filledPromiseName(String)
        case filledPromisePlace(String)
    }

    @Dependency(\.apiClient) var apiClient

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .task { [id = state.id] in
                    await .placeHintResponse(
                        TaskResult {
                            try await apiClient.request(
                                route: .promising(.randomName(id)),
                                as: SharedModels.CategoryName.self
                            )
                        }
                    )
                }
            case let .placeHintResponse(.success(placeHint)):
                state.promiseNamePlaceholder = placeHint.name
                return .none
            case .placeHintResponse(.failure):
                return .none
            case let .filledPromiseName(name):
                state.promiseName = name
                return .none
            case let .filledPromisePlace(place):
                state.promisePlace = place
                return .none
            }
        }
    }
}

extension SharedModels.CategoryName: Equatable {
    public static func == (lhs: SharedModels.CategoryName, rhs: SharedModels.CategoryName) -> Bool {
        lhs.name == rhs.name
    }
}
