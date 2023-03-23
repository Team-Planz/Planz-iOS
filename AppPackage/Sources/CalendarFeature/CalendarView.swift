import ComposableArchitecture
import DesignSystem
import Introspect
import SwiftUI

public struct CalendarView: View {
    struct LayoutConstraint {
        var monthView: MonthView.LayoutConstraint {
            .init(
                rowHeight: dayRowHeight,
                weekDayListCount: weekDayListCout,
                horizontalPadding: contentHorizontalPadding
            )
        }

        let currentMonthInfoBottomPadding: CGFloat
        let directionButtonSize: CGSize
        let listButtonSize: CGSize = .init(width: 22, height: 22)
        let weekDayListCout: Int = WeekDay.allCases.count
        let weekDayRowHeight: CGFloat = 30
        let weekDayListBottomPadding: CGFloat = 12
        let dayRowHeight: CGFloat = 40
        let scrollViewHeight: CGFloat = 240
        let contentHorizontalPadding: CGFloat
        let contentTopPadding: CGFloat
        let contentBottomPadding: CGFloat
        let contentBackgroundCornerRadius: CGFloat
    }

    @Namespace var coordinateSpace
    let type: CalendarType
    let layoutConstraint: LayoutConstraint
    let store: StoreOf<CalendarCore>
    @ObservedObject var viewStore: ViewStoreOf<CalendarCore>

    public init(
        type: CalendarType,
        store: StoreOf<CalendarCore>
    ) {
        self.type = type
        layoutConstraint = type.layoutConstraint
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: .zero) {
                headerView
                weekDayListView
                scrollView(width: geometryProxy.size.width)
            }
            .padding(.top, layoutConstraint.contentTopPadding)
            .padding(.horizontal, layoutConstraint.contentHorizontalPadding)
            .padding(.bottom, layoutConstraint.contentBottomPadding)
            .background {
                Color.white
                    .cornerRadius(layoutConstraint.contentBackgroundCornerRadius)
            }
        }
        .onAppear { viewStore.send(.onAppear(type: type)) }
        .onDisappear { viewStore.send(.onDisAppear) }
    }

    var headerView: some View {
        HStack(spacing: .zero) {
            switch type {
            case .home:
                VStack(spacing: .zero) {
                    HStack(spacing: .zero) {
                        Text(viewStore.selectedMonth.yearMonthString)
                            .foregroundColor(PDS.COLOR.gray8.scale)
                            .font(.system(size: 18))
                            .padding(.trailing, 11)

                        Button(action: { viewStore.send(.leftSideButtonTapped) }) {
                            PDS.Icon.calendarHeaderLeft.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: layoutConstraint.directionButtonSize.width,
                                    height: layoutConstraint.directionButtonSize.height
                                )
                        }
                        .padding(.trailing, 6)

                        Button(action: { viewStore.send(.rightSideButtonTapped) }) {
                            PDS.Icon.calendarHeaderRight.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: layoutConstraint.directionButtonSize.width,
                                    height: layoutConstraint.directionButtonSize.height
                                )
                        }

                        Spacer()

                        Button(action: {}) {
                            PDS.Icon.calendarHeaderList.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(
                                    width: layoutConstraint.listButtonSize.width,
                                    height: layoutConstraint.listButtonSize.height
                                )
                        }
                    }
                    .padding(.bottom, 12)

                    Divider()
                        .foregroundColor(.gray)
                        .frame(height: 1)
                }

            case .appointment:
                Button(action: { viewStore.send(.leftSideButtonTapped) }) {
                    PDS.Icon.calendarHeaderLeft.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: layoutConstraint.directionButtonSize.width,
                            height: layoutConstraint.directionButtonSize.height
                        )
                }
                .padding(.trailing, 16)

                Text(viewStore.selectedMonth.yearMonthString)
                    .font(.system(size: 18))
                    .foregroundColor(PDS.COLOR.gray8.scale)
                    .padding(.trailing, 16)

                Button(action: { viewStore.send(.rightSideButtonTapped) }) {
                    PDS.Icon.calendarHeaderRight.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: layoutConstraint.directionButtonSize.width,
                            height: layoutConstraint.directionButtonSize.height
                        )
                }
            }
        }
        .padding(.bottom, layoutConstraint.currentMonthInfoBottomPadding)
    }

    var weekDayListView: some View {
        HStack(spacing: .zero) {
            ForEach(WeekDay.allCases, id: \.self) { weekDay in
                Text(weekDay.description)
                    .foregroundColor(weekDay.color)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: layoutConstraint.weekDayRowHeight
                    )
            }
        }
        .padding(.bottom, layoutConstraint.weekDayListBottomPadding)
    }

    @ViewBuilder
    func scrollView(width: CGFloat) -> some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: .zero) {
                    ForEachStore(
                        store
                            .scope(
                                state: \.monthList,
                                action: CalendarCore.Action.monthAction(id:action:)
                            )
                    ) {
                        MonthView(
                            type: type,
                            layoutConstraint: layoutConstraint.monthView,
                            geometryWidth: width,
                            store: $0
                        )
                    }
                }
                .frame(height: layoutConstraint.scrollViewHeight)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: ScrollViewOffset.self,
                                value: -proxy.frame(in: .named(coordinateSpace)).minX
                            )
                    }
                }
            }
            .introspectScrollView { $0.isPagingEnabled = true }
            .onReceive(viewStore.publisher.selectedMonth) { id in
                scrollViewProxy.scrollTo(id)
            }
            .coordinateSpace(name: coordinateSpace)
            .onPreferenceChange(ScrollViewOffset.self) { offset in
                let horizontalPadding = (layoutConstraint.contentHorizontalPadding) * 2
                let scrollViewWidth = width - horizontalPadding
                let index = (offset / scrollViewWidth).rounded(.down)
                viewStore.send(.scrollViewOffsetChanged(type: type, index: Int(index)))
            }
        }
    }

    private func transformToIndex(point: CGPoint, viewWidth: CGFloat) -> Int {
        let rowWidth = Int(viewWidth) / layoutConstraint.weekDayListCout
        let rowHeight = Int(layoutConstraint.dayRowHeight)
        let xLocation = Int(point.x) / rowWidth
        let yLocation = Int(point.y) / rowHeight * 7

        return xLocation + yLocation
    }
}

private extension CalendarType {
    var layoutConstraint: CalendarView.LayoutConstraint {
        switch self {
        case .home:
            return .init(
                currentMonthInfoBottomPadding: 16,
                directionButtonSize: .init(width: 20, height: 20),
                contentHorizontalPadding: 19.5,
                contentTopPadding: 20,
                contentBottomPadding: 24,
                contentBackgroundCornerRadius: 16
            )

        case .appointment:
            return .init(
                currentMonthInfoBottomPadding: 20,
                directionButtonSize: .init(width: 24, height: 24),
                contentHorizontalPadding: .zero,
                contentTopPadding: .zero,
                contentBottomPadding: .zero,
                contentBackgroundCornerRadius: .zero
            )
        }
    }
}

enum WeekDay: CaseIterable, CustomStringConvertible {
    var description: String {
        switch self {
        case .sunday:
            return "일"
        case .monday:
            return "월"
        case .tuesday:
            return "화"
        case .wednesday:
            return "수"
        case .thursday:
            return "목"
        case .friday:
            return "금"
        case .saturday:
            return "토"
        }
    }

    var color: Color {
        switch self {
        case .sunday:
            return PDS.COLOR.scarlet1.scale

        default:
            return PDS.COLOR.cGray2.scale
        }
    }

    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

private extension Date {
    var dayString: String {
        formatted(
            .dateTime
                .day()
        )
    }

    var yearMonthString: String {
        formatted(
            .dateTime
                .year()
                .month()
                .locale(.init(identifier: "ko_KR"))
        )
    }
}

private struct ScrollViewOffset: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value += nextValue()
    }
}

#if DEBUG
    struct CalendarView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                CalendarView(
                    type: .home,
                    store: .init(
                        initialState: .init(),
                        reducer: CalendarCore()
                    )
                )

                CalendarView(
                    type: .appointment,
                    store: .init(
                        initialState: .init(),
                        reducer: CalendarCore()
                    )
                )
            }
        }
    }
#endif
