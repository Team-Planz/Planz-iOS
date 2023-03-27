//
//  File.swift
//
//
//  Created by 한상준 on 2023/02/25.
//

import ComposableArchitecture

public struct MakePromiseState: Equatable {
    var shouldShowBackButton: Bool
    var steps: [Step]
    var currentStep: Step? {
        if index < steps.count {
            return steps[index]
        }
        return nil
    }

    var index: Int = 0

    var selectTheme: SelectThemeState? {
        get {
            getSelectThemeState()
        }
        set {
            setSelectThemeState(newValue)
        }
    }

    var setNameAndPlace = SetNameAndPlaceState()

    public init(
        shouldShowBackButton: Bool = false,
        steps: [Step] = [.selectTheme(.init()), .setNameAndPlace(.init())]
    ) {
        self.shouldShowBackButton = shouldShowBackButton
        self.steps = steps
    }

    public enum Step: Equatable {
        case selectTheme(SelectThemeState)
        case setNameAndPlace(SetNameAndPlaceState)
    }

    func isNextButtonEnable() -> Bool {
        guard let currentStep else { return false }
        switch currentStep {
        case let .selectTheme(subState):
            return subState.selectedType != nil
        case let .setNameAndPlace(subState):
            return subState.promisePlace != nil && subState.promiseName != nil
        }
    }

    mutating func moveNextStep() {
        guard index + 1 < steps.count else { return }
        index += 1
    }

    mutating func movePastStep() {
        let newIndex = index - 1
        guard newIndex >= 0, newIndex < steps.count else { return }
        index = newIndex
    }

    mutating func updateBackButtonVisibleState() {
        shouldShowBackButton = index > 0
    }

    func getSelectThemeState() -> SelectThemeState? {
        steps
            .compactMap {
                guard case let .selectTheme(state) = $0 else {
                    return nil
                }
                return state
            }
            .first
    }

    mutating func setSelectThemeState(_ newState: SelectThemeState?) {
        guard let newState else {
            return
        }
        steps[index] = Step.selectTheme(newState)
    }

    mutating func fetchCurrentStep() {}
}
