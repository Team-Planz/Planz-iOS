//
//  File.swift
//
//
//  Created by 한상준 on 2023/02/25.
//

import CalendarFeature
import ComposableArchitecture
import TimeTableFeature

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

    var setNameAndPlace: SetNameAndPlaceState? {
        get {
            steps.compactMap { step in
                guard case let .setNameAndPlace(state) = step else {
                    return nil
                }
                return state
            }.first
        }
        set {
            guard let newState = newValue else {
                return
            }
            guard let index = steps.firstIndex(where: {
                guard case .setNameAndPlace = $0 else {
                    return false
                }
                return true
            }) else { return }
            steps[index] = .setNameAndPlace(newState)
        }
    }

    var timeSelection: TimeSelection.State? {
        get {
            steps.compactMap { step in
                guard case let .timeSelection(state) = step else {
                    return nil
                }
                return state
            }.first
        }
        set {
            guard let newState = newValue else {
                return
            }
            guard let index = steps.firstIndex(where: {
                guard case .timeSelection = $0 else {
                    return false
                }
                return true
            }) else { return }
            steps[index] = .timeSelection(newState)
        }
    }

    var calendar: CalendarCore.State? {
        get {
            steps.compactMap { step in
                guard case let .calendar(state) = step else {
                    return nil
                }
                return state
            }.first
        }
        set {
            guard let newState = newValue else {
                return
            }
            guard let index = steps.firstIndex(where: {
                guard case .calendar = $0 else {
                    return false
                }
                return true
            }) else { return }
            steps[index] = .calendar(newState)
        }
    }

    var timeTable: TimeTableState? {
        get {
            steps.compactMap { step in
                guard case let .timeTable(state) = step else {
                    return nil
                }
                return state
            }.first
        }
        set {
            guard let newState = newValue else {
                return
            }
            guard let index = steps.firstIndex(where: {
                guard case .timeTable = $0 else {
                    return false
                }
                return true
            }) else { return }
            steps[index] = .timeTable(newState)
        }
    }

    public init(
        shouldShowBackButton: Bool = false,
        steps: [Step] = [
            .selectTheme(.init()),
            .setNameAndPlace(.init()),
            .timeSelection(.init(timeRange: .init(start: 9, end: 23))),
            .calendar(.init()),
            .timeTable(.mock)
        ]
    ) {
        self.shouldShowBackButton = shouldShowBackButton
        self.steps = steps
    }

    public enum Step: Equatable {
        case selectTheme(SelectThemeState)
        case setNameAndPlace(SetNameAndPlaceState)
        case calendar(CalendarCore.State)
        case timeSelection(TimeSelection.State)
        case timeTable(TimeTableState)
    }

    var isNextButtonEnable: Bool {
        guard let currentStep else { return false }
        switch currentStep {
        case let .selectTheme(selectTheme):
            return selectTheme.selectedType != nil
        case .setNameAndPlace:
            return true
        case let .calendar(calendar):
            return calendar.selectedDates.count > 0
        case let .timeSelection(timeSelection):
            return timeSelection.isTimeRangeValid
        case let .timeTable(timeTable):
            return timeTable.isTimeSelected
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
