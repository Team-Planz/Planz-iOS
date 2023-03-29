import ComposableArchitecture
import Foundation

public struct MonthCore: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: Date {
            monthState.id.date
        }

        var selectedDates: [Date] {
            gesture.rangeList
                .flatMap { $0 }
                .map { monthState.dayStateList[$0].id }
        }

        public var monthState: MonthState
        var gesture: GestureState

        public init(monthState: MonthState, gesture: GestureState = .init()) {
            self.monthState = monthState
            self.gesture = gesture
        }

        public subscript(_ date: Date) -> Day? {
            return monthState.dayStateList[id: date]?.day
        }
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case day(id: DayCore.State.ID, action: DayCore.Action)
            case drag(startIndex: Int, endIndex: Int)
            case removeSelectedDates(items: [Date])
            case firstWeekDragged(GestureType, ClosedRange<Int>)
            case lastWeekDragged(GestureType, ClosedRange<Int>)
        }

        case delegate(action: Delegate)
        case dragFiltered(startIndex: Int, currentRange: ClosedRange<Int>)
        case dragEnded(startIndex: Int)
        case selectRelatedDays(ClosedRange<Int>)
        case deSelectRelatedDays(ClosedRange<Int>)
        case groupContinuousRanges
        case resetGesture
        case cleanUp
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate(action: .drag):
                return .none

            case let .dragFiltered(
                startIndex: startIndex,
                currentRange: currentRange
            ):
                defer { state.gesture.range = currentRange }

                guard
                    let storedRange = state.gesture.range
                else {
                    currentRange
                        .forEach {
                            guard
                                state.gesture.rangeList.contains(where: { $0.contains(startIndex) })
                            else {
                                state.gesture.tempElements.insert($0)
                                state.monthState.dayStateList[$0].day.selectionType = .painted

                                return
                            }
                            state.monthState.dayStateList[$0].day.selectionType = .clear
                        }

                    return .none
                }
                let overlapsList = state.gesture.rangeList
                    .filter { $0.overlaps(currentRange) }
                let diff = storedRange
                    .difference(from: currentRange)

                guard
                    !overlapsList.isEmpty
                else {
                    diff.elements
                        .forEach {
                            switch $0 {
                            case let .insert(element: index):
                                let isRemoved = state.gesture.removableElements.contains(index)
                                    || state.gesture.tempElements.contains(index)
                                if isRemoved {
                                    state.gesture.removableElements.remove(index)
                                    state.gesture.tempElements.remove(index)
                                    state.monthState.dayStateList[index].day.selectionType = .clear
                                }
                            case let .remove(element: index):
                                state.monthState.dayStateList[index].day.selectionType = .painted
                                state.gesture.tempElements.insert(index)
                            }
                        }

                    return .none
                }

                guard
                    !state.gesture.rangeList.contains(where: { $0.contains(startIndex) })
                else {
                    diff.elements
                        .forEach {
                            switch $0 {
                            case let .insert(element: index):
                                if state.gesture.removableElements.contains(index) {
                                    state.gesture.removableElements.remove(index)
                                    state.monthState.dayStateList[index].day.selectionType = .painted
                                }

                            case let .remove(element: index):
                                if overlapsList.contains(where: { $0.contains(index) }) {
                                    state.gesture.removableElements.insert(index)
                                    state.monthState.dayStateList[index].day.selectionType = .clear
                                }
                            }
                        }
                    return .none
                }
                diff.elements
                    .forEach {
                        switch $0 {
                        case let .insert(element: index):
                            let isRemoved = state.gesture.removableElements.contains(index)
                                || state.gesture.tempElements.contains(index)
                            if isRemoved {
                                state.gesture.tempElements.remove(index)
                                state.gesture.removableElements.remove(index)
                                state.monthState.dayStateList[index].day.selectionType = .clear
                            }
                        case let .remove(element: index):
                            if !state.gesture.rangeList.contains(where: { $0.contains(index) }) {
                                state.monthState.dayStateList[index].day.selectionType = .painted
                                state.gesture.removableElements.insert(index)
                            }
                        }
                    }

                return .none

            case let .dragEnded(startIndex: startIndex):
                guard
                    let currentRange = state.gesture.range
                else { return .none }
                let filterdList = state.gesture.rangeList
                    .filter { $0.overlaps(currentRange) }
                if state.gesture.rangeList.contains(where: { $0.contains(startIndex) }) {
                    let effects = filterdList
                        .compactMap { range -> EffectTask<Action>? in
                            guard
                                let interection = range.intersection(currentRange),
                                let index = state.gesture.rangeList.firstIndex(of: range)
                            else { return nil }
                            state.gesture.rangeList.remove(at: index)
                            state.gesture.rangeList
                                .appendSorted(contentsOf: range.subtracting(currentRange))

                            let removable = state.monthState.dayStateList[interection].map(\.id)
                            let effect = EffectTask<Action>(
                                value: .delegate(action: .removeSelectedDates(items: removable))
                            )
                            if
                                range.overlaps(state.monthState.previousRange),
                                let intersection = range.intersection(state.monthState.previousRange),
                                let targetRange = intersection.intersection(currentRange)
                            {
                                return .merge(
                                    effect,
                                    EffectTask(value: .delegate(action: .firstWeekDragged(.remove, targetRange)))
                                )

                            } else if
                                range.overlaps(state.monthState.nextRange),
                                let intersection = range.intersection(state.monthState.nextRange),
                                let targetRange = intersection.intersection(currentRange)
                            {
                                return .merge(
                                    effect,
                                    EffectTask(value: .delegate(action: .lastWeekDragged(.remove, targetRange)))
                                )
                            }
                            return effect
                        }
                    return .merge(effects)

                } else {
                    let range = groupOverlappingRanges(
                        range: currentRange,
                        rangeList: &state.gesture.rangeList
                    )
                    state.gesture.rangeList.appendSorted(item: range)
                    if let intersection = state.monthState.previousRange.intersection(range) {
                        return .send(.delegate(action: .firstWeekDragged(.insert, intersection)))
                    } else if let intersection = state.monthState.nextRange.intersection(range) {
                        return .send(.delegate(action: .lastWeekDragged(.insert, intersection)))
                    }
                }

                return .send(.cleanUp)

            case let .selectRelatedDays(relatedRange):
                relatedRange
                    .forEach { state.monthState.dayStateList[$0].day.selectionType = .painted }
                let range = groupOverlappingRanges(
                    range: relatedRange,
                    rangeList: &state.gesture.rangeList
                )
                state.gesture.rangeList
                    .appendSorted(item: range)

                return .send(.cleanUp)

            case let .deSelectRelatedDays(range):
                state.gesture.rangeList
                    .filter { $0.overlaps(range) }
                    .forEach {
                        guard
                            let index = state.gesture.rangeList.firstIndex(of: $0)
                        else { return }
                        state.gesture.rangeList.remove(at: index)
                        state.gesture.rangeList
                            .appendSorted(contentsOf: $0.subtracting(range))
                        $0.intersection(range)?
                            .forEach { state.monthState.dayStateList[$0].day.selectionType = .clear }
                    }

                return .send(.resetGesture)

            case .groupContinuousRanges:
                let item = state.gesture.rangeList
                    .flatMap { $0 }
                let comparedList = IndexSet(item)
                    .rangeView
                    .map(\.closedRange)
                state.gesture.rangeList
                    .overwrite(items: comparedList)

                return .none

            case .resetGesture:
                state.gesture.range = nil
                state.gesture.tempElements = []
                state.gesture.removableElements = []
                return .none

            case .cleanUp:
                return .merge(
                    .send(.groupContinuousRanges),
                    .send(.resetGesture)
                )

            case .delegate:
                return .send(.cleanUp)
            }
        }
        .forEach(
            \.monthState.dayStateList,
            action: (/MonthCore.Action.delegate)
                .appending(path: /Action.Delegate.day),
            element: DayCore.init
        )
    }
}

public extension MonthCore {
    struct GestureState: Equatable {
        var range: ClosedRange<Int>?
        var rangeList: [ClosedRange<Int>] = []
        var removableElements: Set<Int> = []
        var tempElements: Set<Int> = []

        public init() {}
    }
}

private func groupOverlappingRanges(
    range targetItem: ClosedRange<Int>,
    rangeList: inout [ClosedRange<Int>]
) -> ClosedRange<Int> {
    rangeList
        .filter { $0.overlaps(targetItem) }
        .reduce(into: targetItem) { result, range in
            guard
                let index = rangeList.firstIndex(of: range),
                let item = range.union(targetItem)
            else { return }
            result = item
            rangeList.remove(at: index)
        }
}
