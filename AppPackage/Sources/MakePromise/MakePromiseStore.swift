//
//  MakePromiseStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import APIClient
import CalendarFeature
import ComposableArchitecture
import Foundation
import TimeTableFeature

public struct MakePromise: ReducerProtocol {
    public struct State: Equatable {
        var shouldShowBackButton: Bool
        var steps: [Step]
        var currentStep: Step? {
            if index < steps.count {
                return steps[index]
            }
            return nil
        }

        var index: Int = 0

        var selectTheme: SelectTheme.State? {
            get {
                getSelectThemeState()
            }
            set {
                setSelectThemeState(newValue)
            }
        }

        var setNameAndPlace: SetNameAndPlace.State? {
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

        var timeTable: TimeTable.State? {
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
            case selectTheme(SelectTheme.State)
            case setNameAndPlace(SetNameAndPlace.State)
            case calendar(CalendarCore.State)
            case timeSelection(TimeSelection.State)
            case timeTable(TimeTable.State)
        }

        var isNextButtonEnable: Bool {
            guard let currentStep else { return false }
            switch currentStep {
            case let .selectTheme(selectTheme):
                return selectTheme.selectThemeItems.contains(where: { $0.isSelected })
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

        func getSelectThemeState() -> SelectTheme.State? {
            steps
                .compactMap {
                    guard case let .selectTheme(state) = $0 else {
                        return nil
                    }
                    return state
                }
                .first
        }

        mutating func setSelectThemeState(_ newState: SelectTheme.State?) {
            guard let newState else {
                return
            }
            steps[index] = Step.selectTheme(newState)
        }

        mutating func fetchCurrentStep() {}
    }

    public enum Action: Equatable {
        case dismiss
        case nextButtonTapped
        case backButtonTapped

        case selectTheme(SelectTheme.Action)
        case setNameAndPlace(SetNameAndPlace.Action)
        case calendar(CalendarCore.Action)
        case timeSelection(TimeSelection.Action)
        case timeTable(TimeTable.Action)
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .none

            case .nextButtonTapped:
                if case let .selectTheme(selectTheme) = state.currentStep {
                    state.setNameAndPlace?.id = selectTheme.selectThemeItems
                        .filter { $0.isSelected }
                        .first?.id ?? 0
                }

                if case let .timeSelection(timeSelection) = state.currentStep,
                   let startTime = timeSelection.startTime,
                   let endTime = timeSelection.endTime
                {
                    state.timeTable?.startTime = TimeInterval(startTime * 3600)
                    state.timeTable?.endTime = TimeInterval(endTime * 3600)
                    state.timeTable?.reload()
                }

                if case let .calendar(calendarState) = state.currentStep {
                    let days: [TimeTable.State.Day] = calendarState.selectedDates.map {
                        .init(date: $0)
                    }
                    state.timeTable?.days = days
                }

                if state.isNextButtonEnable {
                    state.moveNextStep()
                    state.updateBackButtonVisibleState()
                }
                return .none
            case .backButtonTapped:
                state.movePastStep()
                state.updateBackButtonVisibleState()
                return .none
            case .selectTheme:
                return .none
            case .setNameAndPlace:
                return .none
            case .calendar:
                return .none
            case .timeSelection:
                return .none
            case .timeTable:
                return .none
            }
        }
        .ifLet(
            \.selectTheme,
            action: /MakePromise.Action.selectTheme
        ) {
            SelectTheme()
        }
        .ifLet(
            \.setNameAndPlace,
            action: /MakePromise.Action.setNameAndPlace
        ) {
            SetNameAndPlace()
        }
        .ifLet(
            \.calendar,
            action: /MakePromise.Action.calendar
        ) {
            CalendarCore()
        }
        .ifLet(
            \.timeSelection,
            action: /MakePromise.Action.timeSelection
        ) {
            TimeSelection()
        }
        .ifLet(
            \.timeTable,
            action: /MakePromise.Action.timeTable
        ) {
            TimeTable()
        }
    }

    public init() {}
}
