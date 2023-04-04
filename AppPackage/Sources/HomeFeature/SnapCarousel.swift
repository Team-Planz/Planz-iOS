import ComposableArchitecture
import Foundation
import SwiftUI

public struct SnapCarousel<
    Content: View,
    Item: Identifiable
>: View where Item.ID == UUID {
    private var sliceItemList: [Box<Item>] {
        itemList.slice(2)
    }

    let itemList: [Item]

    let spacing: CGFloat
    let trailingSpace: CGFloat
    var content: (Item) -> Content

    @State var index: Int = .zero
    @State var fakeIndex: Int = .zero
    @GestureState var offset: CGFloat = .zero

    public init(
        itemList: [Item],
        spacing: CGFloat,
        trailingSpace: CGFloat,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.itemList = itemList
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustmentWidth = (trailingSpace / 2) - spacing
            let contentOffset = CGFloat(fakeIndex) * -width + (fakeIndex != .zero ? adjustmentWidth : .zero) + offset
            HStack(alignment: .top, spacing: spacing) {
                ForEach(sliceItemList) { items in
                    VStack(spacing: 20) {
                        ForEach(items.value) { item in
                            content(item)
                                .frame(width: proxy.size.width - trailingSpace)
                        }
                        Spacer()
                    }
                    .background { Color.white }
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: contentOffset)
            .gesture(
                DragGesture()
                    .updating($offset) { value, dragState, _ in
                        dragState = value.translation.width
                    }
                    .onChanged { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(fakeIndex + Int(roundIndex), sliceItemList.count - 1), .zero)
                    }
                    .onEnded { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        fakeIndex = max(min(fakeIndex + Int(roundIndex), sliceItemList.count - 1), .zero)
                    }
            )
            .animation(.easeInOut, value: offset == .zero)
        }
    }
}

private extension Array where Element: Identifiable, Element.ID == UUID {
    func slice(_ size: Int) -> [Box<Element>] {
        guard count > .zero else { return [] }
        var range = count / size
        if count.isMultiple(of: size) {
            range -= 1
        }

        return (0 ... range)
            .map {
                Box(
                    id: self[$0].id,
                    value: Array(self[$0 * size ..< (Swift.min(($0 + 1) * size, count))])
                )
            }
    }
}

private struct Box<Item>: Identifiable {
    let id: UUID
    let value: [Item]
}
