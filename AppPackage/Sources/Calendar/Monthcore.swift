import ComposableArchitecture
import Foundation

public struct MonthCore: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: Date {
            monthState.id.date
        }
        var coloredDateList: [Date] {
            gesture.rangeList
                .flatMap { $0 }
                .map { monthState.days[$0].date }
        }
        var monthState: MonthState
        var gesture: GestureState
        
        init(monthState: MonthState, gesture: GestureState = .init()) {
            self.monthState = monthState
            self.gesture = gesture
        }
    }
    
    public enum Action: Equatable {
        case drag(startIndex: Int, endIndex: Int)
        case dragEnded(startIndex: Int)
        case resetGesture
        case update(GestureType, TimeOrder, ClosedRange<Int>)
    }
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        switch action {
        case let .drag(
            startIndex: startIndex,
            endIndex: endIndex
        ):
            guard
                endIndex < state.monthState.days.count,
                endIndex >= .zero
            else { return .none }
            
            guard
                !state.monthState.days[startIndex].isFaded,
                !state.monthState.days[endIndex].isFaded
            else { return .none }
            
            let currentRange = min(startIndex, endIndex) ... max(startIndex, endIndex)
            defer { state.gesture.range = currentRange }
            
            guard
                let storedRange = state.gesture.range
            else {
                currentRange
                    .forEach {
                        state.gesture.tempElements.insert(item: $0)
                        state.monthState.days[$0].selectionType = .painted
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
                            if  isRemoved {
                                state.gesture.removableElements.remove(index)
                                state.gesture.tempElements.remove(index)
                                state.monthState.days[index].selectionType = .clear
                            }
                        case let .remove(element: index):
                            state.monthState.days[index].selectionType = .painted
                            state.gesture.tempElements.insert(item: index)
                        }
                    }
                
                return .none
            }
            
            guard
                !state.gesture.rangeList.contains(where: { $0.contains(startIndex) })
            else {
                if !state.gesture.removableElements.contains(startIndex) {
                    state.gesture.removableElements.insert(startIndex)
                    state.monthState.days[startIndex].selectionType = .clear
                }
                diff.elements
                    .forEach {
                        switch $0 {
                        case let .insert(element: index):
                            if state.gesture.removableElements.contains(index) {
                                state.gesture.removableElements.remove(index)
                                state.monthState.days[index].selectionType = .painted
                            }
                            
                        case let .remove(element: index):
                            if overlapsList.contains(where: { $0.contains(index)}) {
                                state.gesture.removableElements.insert(item: index)
                                state.monthState.days[index].selectionType = .clear
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
                            state.monthState.days[index].selectionType = .clear
                        }
                    case let .remove(element: index):
                        if !state.gesture.rangeList.contains(where: { $0.contains(index)}) {
                            state.monthState.days[index].selectionType = .painted
                            state.gesture.removableElements.insert(item: index)
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
                var items: [Int] = []
                var flag = false
                filterdList
                    .forEach {
                        guard
                            let index = state.gesture.rangeList.firstIndex(of: $0)
                        else { return }
                        
                        if state.monthState.previousRange.overlaps(currentRange) {
                            if let range = state.monthState.previousRange.intersection(currentRange) {
                                items.append(contentsOf: range.map { $0 })
                                flag = true
                            }
                        } else if state.monthState.nextRange.overlaps(currentRange) {
                            if let range = state.monthState.nextRange.intersection(currentRange) {
                                items.append(contentsOf: range.map { $0 })
                            }
                        }
                        state.gesture.rangeList.remove(at: index)
                        IndexSet($0.set.subtracting(currentRange))
                            .rangeView
                            .map(\.closedRange)
                            .forEach { state.gesture.rangeList.appendSorted(item: $0) }
                    }
                
                if !items.isEmpty {
                    let item22 = ClosedRange<Int>.init(uncheckedBounds: (items.first!, items.last!))
                    if flag {
                        state.gesture.temp = item22
                    } else {
                        state.gesture.temp = item22
                    }
                }
            } else {
                let extendedRange = filterdList
                    .reduce(into: currentRange) { result, item in
                        guard
                            let index = state.gesture.rangeList.firstIndex(of: item),
                            let firstItem = IndexSet(item.set.union(currentRange.set)).rangeView.first
                        else { return }
                        result = firstItem.closedRange
                        state.gesture.rangeList.remove(at: index)
                    }
                state.gesture.rangeList.appendSorted(item: extendedRange)
            }
            let item = state.gesture.rangeList
                .flatMap { $0 }
            let comparedList = IndexSet(item).rangeView
                .map(\.closedRange)
            if state.gesture.rangeList != comparedList {
                state.gesture.rangeList = comparedList
            }
            
            return .send(.resetGesture)
            
        case .resetGesture:
            state.gesture.range = nil
            state.gesture.tempElements = []
            state.gesture.removableElements = []
            state.gesture.temp = nil
            print("🎁", state.id, state.gesture.rangeList)
            return .none
            
        case let .update(gestureType, timeOrder, dates):
            switch gestureType {
            case .insert:
                switch timeOrder {
                case .previous:
                    let target = dates.map { $0 % 7 }
                    let range = target.first! ... target.last!
                    if state.gesture.rangeList.contains(where: { $0.overlaps(range) }) {
                        let filterdList = state.gesture.rangeList
                            .filter { $0.overlaps(range) }
                        let extendedRange = filterdList
                            .reduce(into: range) { result, item in
                                guard
                                    let index = state.gesture.rangeList.firstIndex(of: item),
                                    let firstItem = IndexSet(item.set.union(range.set)).rangeView.first
                                else { return }
                                result = firstItem.closedRange
                                state.gesture.rangeList.remove(at: index)
                            }
                        state.gesture.rangeList.appendSorted(item: extendedRange)
                    } else {
                        state.gesture.rangeList.appendSorted(item: range)
                    }
                    let item = state.gesture.rangeList
                        .flatMap { $0 }
                    let comparedList = IndexSet(item).rangeView
                        .map(\.closedRange)
                    if state.gesture.rangeList != comparedList {
                        state.gesture.rangeList = comparedList
                    }
                    
                    target.forEach {
                        state.monthState.days[$0].selectionType = .painted
                    }
                    
                case .next:
                    let item = (state.monthState.days.count / 7) - 1
                    let target = dates.map { $0 + item * 7 }
                    let range = target.first! ... target.last!
                    if state.gesture.rangeList.contains(where: { $0.overlaps(range) }) {
                        let filterdList = state.gesture.rangeList
                            .filter { $0.overlaps(range) }
                        let extendedRange = filterdList
                            .reduce(into: range) { result, item in
                                guard
                                    let index = state.gesture.rangeList.firstIndex(of: item),
                                    let firstItem = IndexSet(item.set.union(range.set)).rangeView.first
                                else { return }
                                result = firstItem.closedRange
                                state.gesture.rangeList.remove(at: index)
                            }
                        state.gesture.rangeList.appendSorted(item: extendedRange)
                    } else {
                        state.gesture.rangeList.appendSorted(item: range)
                    }
                    let item2 = state.gesture.rangeList
                        .flatMap { $0 }
                    let comparedList = IndexSet(item2).rangeView
                        .map(\.closedRange)
                    if state.gesture.rangeList != comparedList {
                        state.gesture.rangeList = comparedList
                    }
                    target.forEach {
                        state.monthState.days[$0].selectionType = .painted
                    }
                }
                
                print("🐶", state.id, state.gesture.rangeList)
                return .none

            case .remove:
                switch timeOrder {
                case .previous:
                    let item = (state.monthState.days.count / 7) - 1
                    let target = dates.map { $0 + item * 7 }
                    target.forEach {
                        state.monthState.days[$0].selectionType = .clear
                    }
                    let range = target.first! ... target.last!
                    let filterdList = state.gesture.rangeList
                        .filter { $0.overlaps(range) }
                    filterdList
                        .forEach {
                            guard
                                let index = state.gesture.rangeList.firstIndex(of: $0)
                            else { return }
                            state.gesture.rangeList.remove(at: index)
                            IndexSet($0.set.subtracting(range))
                                .rangeView
                                .map(\.closedRange)
                                .forEach { state.gesture.rangeList.appendSorted(item: $0) }
                        }
                    
                case .next:
                    let target = dates.map { $0 % 7 }
                    let range = target.first! ... target.last!
                    
                    target.forEach {
                        state.monthState.days[$0].selectionType = .clear
                    }
                    let filterdList = state.gesture.rangeList
                        .filter { $0.overlaps(range) }
                    filterdList
                        .forEach {
                            guard
                                let index = state.gesture.rangeList.firstIndex(of: $0)
                            else { return }
                            state.gesture.rangeList.remove(at: index)
                            IndexSet($0.set.subtracting(range))
                                .rangeView
                                .map(\.closedRange)
                                .forEach { state.gesture.rangeList.appendSorted(item: $0) }
                        }
                }
                print("🌈", state.id, state.gesture.rangeList)
                return .none
            }
        }
    }
}

extension MonthCore {
    struct GestureState: Equatable {
        var range: ClosedRange<Int>?
        var rangeList: [ClosedRange<Int>] = []
        var removableElements: Set<Int> = []
        var tempElements: Set<Int> = []
        
        var temp: ClosedRange<Int>?
    }
}

private extension Set {
    // MARK: - When Not Contained
    mutating
    func insert(item: Element) {
        guard !contains(item) else { return }
        self.insert(item)
    }
}

extension Range where Bound == Int {
    var closedRange: ClosedRange<Bound> {
        lowerBound ... (upperBound - 1)
    }
}

extension ClosedRange<Int> {
    var set: Set<Int> {
        return reduce(into: Set<Int>()) { result, item in
            result.insert(item)
        }
    }
}

private extension Array where Element == ClosedRange<Int> {
    mutating
    func appendSorted(item: Element) {
        var slice: Array<Element>.SubSequence = self[...]
        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if item.lowerBound < slice[middle].lowerBound {
                slice = slice[..<middle]
            } else {
                slice = slice[slice.index(after: middle)...]
            }
        }
        insert(item, at: slice.startIndex)
    }
}

private extension CollectionDifference where ChangeElement == ClosedRange<Int>.Element {
    enum CustomChange {
        case insert(element: Int)
        case remove(element: Int)
    }
    
    var elements: [CustomChange] {
        map {
            switch $0 {
            case let .insert(offset: _, element: element, associatedWith: _):
                return .insert(element: element)
            case let .remove(offset: _, element: element, associatedWith: _):
                return .remove(element: element)
            }
        }
    }
}
