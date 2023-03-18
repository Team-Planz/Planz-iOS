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
            ForEach(viewStore.days) { day in
                Text(day.date.dayString)
                    .bold(day.isToday)
                    .foregroundColor(.dayColor(date: day.date, isFaded: day.isFaded))
                    .frame(height: layoutConstraint.rowHeight)
                    .frame(maxWidth: .infinity)
                    .background {
                        ZStack {
                            switch day.selectionType {
                            case .clear:
                                Color.clear
                            case .painted:
                                PDS.COLOR.purple9.scale
                                    .cornerRadius(11)
                                    .frame(width: 32, height: 30)
                            }
                        }
                    }
                    .onTapGesture { viewStore.send(.rowTapped(day.date)) }
                    .disabled(type == .appointment)
            }
        }
        .id(viewStore.id)
        .gesture(
            DragGesture(
                minimumDistance: .zero,
                coordinateSpace: type == .appointment
                    ? .local
                    : .global
            )
            .onChanged {
                guard type == .appointment else { return }
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
                guard type == .appointment else { return }
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
        let days: [Day]
    }

    enum ViewAction: Equatable {
        var reducerAction: MonthCore.Action {
            switch self {
            case let .rowTapped(date):
                return .delegate(action: .rowTapped(date))

            case let .drag(startIndex: startIndex, endIndex: endIndex):
                return .delegate(action: .drag(startIndex: startIndex, endIndex: endIndex))

            case let .dragEnded(startIndex: startIndex):
                return .dragEnded(startIndex: startIndex)
            }
        }

        case rowTapped(Date)
        case drag(startIndex: Int, endIndex: Int)
        case dragEnded(startIndex: Int)
    }
}

private extension MonthCore.State {
    var viewState: MonthView.ViewState {
        .init(id: id, days: monthState.days)
    }
}

private extension Date {
    var dayString: String {
        formatted(
            .dateTime
                .day()
        )
    }
}

private extension Color {
    static func dayColor(date: Date, isFaded: Bool) -> Self {
        guard !isFaded else { return PDS.COLOR.gray3.scale }
        return calendar.component(.weekday, from: date) == 1
            ? PDS.COLOR.scarlet1.scale
            : PDS.COLOR.cGray2.scale
    }
}
