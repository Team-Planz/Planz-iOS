import Foundation

extension Range where Bound == Int {
    var closedRange: ClosedRange<Bound> {
        lowerBound ... (upperBound - 1)
    }
}

extension ClosedRange where Bound == Int {
    var set: Set<Bound> {
        return reduce(into: Set<Bound>()) { result, item in
            result.insert(item)
        }
    }

    func intersection(_ other: Self) -> Self? {
        let intersection = set.intersection(other.set)
        let item = IndexSet(intersection)
            .rangeView
            .map(\.closedRange)
            .first
        guard let result = item else { return nil }

        return result
    }

    func subtracting(_ other: Self) -> [Self] {
        let subtracting = set.subtracting(other)
        return IndexSet(subtracting)
            .rangeView
            .map(\.closedRange)
    }

    func union(_ other: Self) -> Self? {
        let union = set.union(other)
        let item = IndexSet(union)
            .rangeView
            .map(\.closedRange)
            .first
        guard let result = item else { return nil }

        return result
    }
}
