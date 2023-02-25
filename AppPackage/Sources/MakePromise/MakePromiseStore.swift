//
//  MakePromiseStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import Foundation

public enum MakePromiseStep: Int, Comparable {
    case error = 0
    case selectTheme = 1
    case fillNAndPlace

    public static func < (lhs: MakePromiseStep, rhs: MakePromiseStep) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct MakePromiseState: Equatable {
    var shouldShowBackButton = false
    var currentStep: MakePromiseStep = .selectTheme
    var setNameAndPlaceState: SetNameAndPlaceState = .init()

    var selectTheme: SelectThemeState? {
        get {
            steps
                .compactMap {
                    guard case let .selectTheme(state) = $0 else {
                        return nil
                    }
                    return state
                }
                .first
        }
        set {
            guard let newState = newValue else {
                return
            }
            let index = steps.firstIndex {
                guard case .selectTheme = $0 else {
                    return false
                }
                return true
            }
            steps[index!] = Step.selectTheme(newState)
        }
    }

    var steps: [Step]

    public init(
        shouldShowBackButton: Bool = false,
        currentStep: MakePromiseStep = .selectTheme,
        setNameAndPlaceState: SetNameAndPlaceState = .init(),
        steps: [Step] = [.selectTheme(.init())]
    ) {
        self.shouldShowBackButton = shouldShowBackButton
        self.currentStep = currentStep
        self.setNameAndPlaceState = setNameAndPlaceState
        self.steps = steps
    }

    public enum Step: Equatable {
        case selectTheme(SelectThemeState)
        case setNameAndPlace(SetNameAndPlaceState)
    }

    func isPossibleToNextContents() -> Bool {
        switch currentStep {
        case .selectTheme:
            return selectTheme?.selectedType != nil
        case .error:
            return false
        case .fillNAndPlace:
            return true
        }
    }
}

public enum MakePromiseAction: Equatable {
    case nextButtonTapped
    case backButtonTapped

    case selectTheme(SelectThemeAction)
    case setNameAndPlace(SetNameAndPlaceAction)
}

public struct MakePromiseEnvironment {
    public init() {}
}

typealias Step = MakePromiseStep

public let makePromiseReducer = Reducer<MakePromiseState, MakePromiseAction, MakePromiseEnvironment>.combine(
    makePromiseSelectThemeReducer
        .optional()
        .pullback(
            state: \.selectTheme,
            action: /MakePromiseAction.selectTheme,
            environment: { _ in SelectThemeEnvironment() }
        ),
    Reducer { state, action, _ in
        switch action {
        case .nextButtonTapped:
            if state.isPossibleToNextContents() {
                state.currentStep = Step(rawValue: state.currentStep.rawValue + 1) ?? .error
                state.shouldShowBackButton = state.currentStep > Step.selectTheme
            }
            return .none

        case .backButtonTapped:
            var step = state.currentStep
            var initialStep = Step.selectTheme
            state.currentStep = step > initialStep ? Step(rawValue: step.rawValue - 1) ?? initialStep : initialStep
            state.shouldShowBackButton = state.currentStep > initialStep
            return .none
        case let .selectTheme(.promiseTypeListItemTapped(promiseType)):
            state.selectTheme = .init(selectedType: promiseType)
            return .none
        case let .setNameAndPlace(.filledPromiseName(name)):
            return .none
        case let .setNameAndPlace(.filledPromisePlace(place)):
            return .none
        }
    }
)
