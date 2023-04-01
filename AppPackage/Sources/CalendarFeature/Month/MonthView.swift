import ComposableArchitecture
import DesignSystem
import SwiftUI

struct MonthView: View {
    struct LayoutConstraint {
        let rowHeight: CGFloat
        let weekDayListCount: Int
        let horizontalPadding: CGFloat
    }

    let type: CalendarType
    let layoutConstraint: LayoutConstraint
    let geometryWidth: CGFloat
    let store: StoreOf<MonthCore>
    @ObservedObject private var viewStore: ViewStore<ViewState, ViewAction>

    init(
        type: CalendarType,
        layoutConstraint: LayoutConstraint,
        geometryWidth: CGFloat,
        store: StoreOf<MonthCore>
    ) {
        self.type = type
        self.layoutConstraint = layoutConstraint
        self.geometryWidth = geometryWidth
        self.store = store
        viewStore = ViewStore(
            store
                .scope(
                    state: \.viewState,
                    action: \.reducerAction
                )
        )
    }

    var body: some View {
        let horziontalPadding = layoutConstraint.horizontalPadding * 2
        let scrollViewWidth = geometryWidth - horziontalPadding
        let rowWidth = scrollViewWidth / CGFloat(layoutConstraint.weekDayListCount)
        LazyVGrid(
            columns: .init(
                repeating: .init(.fixed(rowWidth), spacing: .zero),
                count: layoutConstraint.weekDayListCount
            ),
            spacing: .zero
        ) {
            ForEachStore(
                store
                    .scope(
                        state: \.monthState.dayStateList,
                        action: { MonthCore.Action.delegate(action: .day(id: $0, action: $1)) }
                    ),
                content: {
                    DayView(
                        calendarType: type,
                        layoutConstraint: .init(rowHeight: layoutConstraint.rowHeight),
                        store: $0
                    )
                }
            )
        }
        .id(viewStore.id)
        .gesture(
            DragGesture(
                minimumDistance: .zero,
                coordinateSpace: type == .promise
                    ? .local
                    : .global
            )
            .onChanged {
                guard type == .promise else { return }
                let startIndex = transformToIndex(
                    point: $0.startLocation,
                    viewWidth: geometryWidth
                )
                let endIndex = transformToIndex(
                    point: $0.location,
                    viewWidth: geometryWidth
                )
                viewStore.send(.drag(startIndex: startIndex, endIndex: endIndex))
            }
            .onEnded {
                guard type == .promise else { return }
                let startIndex = transformToIndex(
                    point: $0.startLocation,
                    viewWidth: geometryWidth
                )
                viewStore.send(.dragEnded(startIndex: startIndex))
            }
        )
    }

    private func transformToIndex(point: CGPoint, viewWidth: CGFloat) -> Int {
        let rowWidth = Int(viewWidth) / layoutConstraint.weekDayListCount
        let rowHeight = Int(layoutConstraint.rowHeight)
        let xLocation = Int(point.x) / rowWidth
        let yLocation = Int(point.y) / rowHeight * layoutConstraint.weekDayListCount

        return xLocation + yLocation
    }
}

private extension MonthView {
    struct ViewState: Equatable {
        let id: Date
        let days: IdentifiedArrayOf<DayCore.State>
    }

    enum ViewAction: Equatable {
        var reducerAction: MonthCore.Action {
            switch self {
            case let .day(id: id, action: dayAction):
                return .delegate(action: .day(id: id, action: dayAction))

            case let .drag(startIndex: startIndex, endIndex: endIndex):
                return .drag(startIndex: startIndex, endIndex: endIndex)

            case let .dragEnded(startIndex: startIndex):
                return .dragEnded(startIndex: startIndex)
            }
        }

        case day(id: DayCore.State.ID, action: DayCore.Action)
        case drag(startIndex: Int, endIndex: Int)
        case dragEnded(startIndex: Int)
    }
}

private extension MonthCore.State {
    var viewState: MonthView.ViewState {
        .init(id: id, days: monthState.dayStateList)
    }
}
