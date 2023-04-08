//
//  MakePromiseStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import CalendarFeature
import ComposableArchitecture
import Foundation
import TimeTableFeature

public struct MakePromiseEnvironment {
    public init() {}
}

public let makePromiseReducer = AnyReducer<MakePromiseState, MakePromiseAction, MakePromiseEnvironment>.combine(
    makePromiseSelectThemeReducer
        .optional()
        .pullback(
            state: \.selectTheme,
            action: /MakePromiseAction.selectTheme,
            environment: { _ in SelectThemeEnvironment() }
        ),
    makePromiseSetNameAndPlaceReducer
        .optional()
        .pullback(
            state: \.setNameAndPlace,
            action: /MakePromiseAction.setNameAndPlace,
            environment: { _ in SetNameAndPlaceEnvironment() }
        ),
    AnyReducer { _ in
        CalendarCore()
    }
    .optional()
    .pullback(
        state: \.calendar,
        action: /MakePromiseAction.calendar,
        environment: { _ in }
    ),
    AnyReducer { _ in
        TimeSelection()
    }
    .optional()
    .pullback(
        state: \.timeSelection,
        action: /MakePromiseAction.timeSelection,
        environment: { _ in }
    ),
    timeTableReducer
        .optional()
        .pullback(
            state: \.timeTable,
            action: /MakePromiseAction.timeTable,
            environment: { _ in () }
        ),
    AnyReducer { state, action, _ in
        switch action {
        case .dismiss:
            return .none

        case .nextButtonTapped:
            if case let .timeSelection(timeSelection) = state.currentStep,
               let startTime = timeSelection.startTime,
               let endTime = timeSelection.endTime {
                state.timeTable?.startTime = TimeInterval(startTime * 3600)
                state.timeTable?.endTime = TimeInterval(endTime * 3600)
                state.timeTable?.reload()
            }

            if case let .calendar(calendarState) = state.currentStep {
                let days: [TimeTableState.Day] = calendarState.selectedDates.map {
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
        case let .selectTheme(.promiseTypeListItemTapped(promiseType)):
            return .none
        case let .setNameAndPlace(.filledPromiseName(name)):
            return .none
        case let .setNameAndPlace(.filledPromisePlace(place)):
            return .none
        case .calendar:
            return .none
        case .timeSelection:
            return .none
        case .timeTable:
            return .none
        }
    }
)
