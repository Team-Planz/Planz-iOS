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
        @PresentationState var alert: AlertState<AlertAction>?
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
            alert: AlertState<AlertAction>? = nil,
            shouldShowBackButton: Bool = false,
            steps: [Step] = [
                .selectTheme(.init()),
                .setNameAndPlace(.init()),
                .calendar(.init()),
                .timeSelection(.init(timeRange: .init(start: 9, end: 23))),
                .timeTable(.mock)
            ]
        ) {
            self.alert = alert
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

    @Dependency(\.apiClient) var apiClient

    public enum Action: Equatable {
        case dismiss
        case nextButtonTapped
        case backButtonTapped

        case temporaryPromisingResponse(TaskResult<SharedModels.CreatePromisingResponse>)

        case selectTheme(SelectTheme.Action)
        case setNameAndPlace(SetNameAndPlace.Action)
        case calendar(CalendarCore.Action)
        case timeSelection(TimeSelection.Action)
        case timeTable(TimeTable.Action)
        case alert(PresentationAction<AlertAction>)
    }

    public enum AlertAction: Equatable {
        case confirmButtonTapped
        case dismiss
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

                if case .timeSelection = state.currentStep {
                    state.alert = .init(
                        title: .init(Resource.string.alert),
                        message: .init(Resource.string.warning),
                        primaryButton: .cancel(.init(Resource.string.cancel), action: .send(.dismiss)),
                        secondaryButton: .default(.init(Resource.string.confirm), action: .send(.confirmButtonTapped))
                    )
                    return .none
                }

                if state.isNextButtonEnable {
                    state.moveNextStep()
                    state.updateBackButtonVisibleState()
                }
                return .none
            case .backButtonTapped:
                if case .timeTable = state.currentStep {
                    return .send(.dismiss)
                }
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
            case .alert(.presented(.confirmButtonTapped)):
                guard case let .timeSelection(timeSelection) = state.currentStep else {
                    return .none
                }
                guard let categoryID = state.selectTheme?.selectThemeItems
                    .filter({ $0.isSelected }).first?.id
                else {
                    return .none
                }
                guard let startTime: Date = .today(hour: timeSelection.startTime),
                      let endTime: Date = .today(hour: timeSelection.endTime)
                else {
                    return .none
                }
                state.alert = nil
                return .task { [state = state] in
                    await .temporaryPromisingResponse(
                        TaskResult {
                            try await apiClient.request(
                                route: .promising(
                                    .create(
                                        .init(
                                            name: state.setNameAndPlace?.promiseName ?? "",
                                            minTime: dateFormatter.string(from: startTime),
                                            maxTime: dateFormatter.string(from: endTime),
                                            categoryID: categoryID,
                                            availableDates: state.calendar?.selectedDates.map { dateFormatter.string(from: $0) } ?? [],
                                            place: state.setNameAndPlace?.promisePlace ?? ""
                                        )
                                    )
                                ),
                                as: SharedModels.CreatePromisingResponse.self
                            )
                        }
                    )
                }
            case let .temporaryPromisingResponse(.success(response)):
                state.moveNextStep()
                state.updateBackButtonVisibleState()
                return .none
            case .temporaryPromisingResponse(.failure):
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.selectTheme, action: /MakePromise.Action.selectTheme) {
            SelectTheme()
        }
        .ifLet(\.setNameAndPlace, action: /MakePromise.Action.setNameAndPlace) {
            SetNameAndPlace()
        }
        .ifLet(\.calendar, action: /MakePromise.Action.calendar) {
            CalendarCore()
        }
        .ifLet(\.timeSelection, action: /MakePromise.Action.timeSelection) {
            TimeSelection()
        }
        .ifLet(\.timeTable, action: /MakePromise.Action.timeTable) {
            TimeTable()
        }
    }

    public init() {}
}

private enum Resource {
    enum string {
        static let alert = "알림"
        static let warning = "다음을 누르시면 이전 단계로 돌아갈 수 없습니다. 진행하시겠습니까?"
        static let cancel = "취소"
        static let confirm = "확인"
    }
}

extension SharedModels.CreatePromisingResponse: Equatable {
    public static func == (lhs: SharedModels.CreatePromisingResponse, rhs: SharedModels.CreatePromisingResponse) -> Bool {
        lhs.id == rhs.id
    }
}

private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter
}()

private extension Date {
    static func today(
        hour: Int? = nil,
        minute: Int? = nil,
        second: Int? = nil
    ) -> Self? {
        let today: Date = .now
        let calendar = Calendar.current
        let dateComponents = DateComponents(
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: today),
            day: calendar.component(.day, from: today),
            hour: hour,
            minute: minute,
            second: second
        )
        return calendar.date(from: dateComponents)
    }
}
