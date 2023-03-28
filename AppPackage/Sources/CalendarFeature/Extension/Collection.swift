import Foundation
import IdentifiedCollections

public extension Array where Element: Identifiable {
    var toIdentifiedCollection: IdentifiedArrayOf<Element> {
        IdentifiedArrayOf<Element>(uniqueElements: self)
    }
}

extension Array where Element == ClosedRange<Int> {
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

    mutating
    func appendSorted(contentsOf items: [Element]) {
        items
            .forEach { appendSorted(item: $0) }
    }

    mutating
    func overwrite(items: Self) {
        if self != items {
            self = items
        }
    }
}

extension CollectionDifference where ChangeElement == ClosedRange<Int>.Element {
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
