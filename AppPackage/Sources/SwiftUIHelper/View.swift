import Foundation
import SwiftUI

public extension View {
    @ViewBuilder
    func hidden(_ hidden: Bool, _ isSpace: Bool = false) -> some View {
        modifier(HiddenViewModifier(hidden: hidden, isSpace: isSpace))
    }
}

public struct HiddenViewModifier: ViewModifier {
    var hidden: Bool
    var isSpace: Bool

    public init(hidden: Bool, isSpace: Bool) {
        self.hidden = hidden
        self.isSpace = isSpace
    }

    public func body(content: Content) -> some View {
        if hidden {
            if isSpace {
                content.hidden()
            }
        } else {
            content
        }
    }
}
