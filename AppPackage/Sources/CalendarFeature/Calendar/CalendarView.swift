import ComposableArchitecture
import DesignSystem
import Entity
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
    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

    public init(
        type: CalendarType,
        store: StoreOf<CalendarCore>
    ) {
        self.type = type
        layoutConstraint = type.layoutConstraint
        self.store = store
        viewStore = ViewStore(
            store
                .scope(
                    state: \.viewState,
                    action: \.reducerAction
                )
        )
    }

    public var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: .zero) {
                headerView
                switch viewStore.calendarForm {
                case .default:
                    weekDayListView
                    scrollView(width: geometryProxy.size.width)

                case .list:
                    promiseListView
                }
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

                        Button(action: { viewStore.send(.formChangeButtonTapped) }) {
                            viewStore.calendarForm == .default
                                ? PDS.Icon.calendarHeaderList.image
                                : PDS.Icon.calendar.image
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: layoutConstraint.listButtonSize.width,
                            height: layoutConstraint.listButtonSize.height
                        )
                    }
                    .padding(.bottom, 12)

                    Divider()
                        .foregroundColor(.gray)
                        .frame(height: 1)
                }

            case .promise:
                let isLeadingIndex = Optional(viewStore.selectedMonth) == viewStore.monthList.first?.id
                let leftButtonVisible = type == .promise && isLeadingIndex
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
                .opacity(
                    leftButtonVisible
                        ? .zero
                        : 1
                )

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
                                action: CalendarCore.Action.month(id:action:)
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
            .introspectScrollView {
                $0.isPagingEnabled = true
                $0.isScrollEnabled = type == .promise
                    ? false
                    : true
            }
            .onReceive(viewStore.publisher.selectedMonth) { id in
                scrollViewProxy.scrollTo(id, anchor: .leading)
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

    @ViewBuilder
    var promiseListView: some View {
        let verticalPadding = layoutConstraint.weekDayRowHeight + layoutConstraint.weekDayListBottomPadding

        TabView(selection: viewStore.binding(\.$selectedMonth)) {
            ForEach(viewStore.monthList) { item in
                Group {
                    if item.monthState.promiseList.isEmpty {
                        VStack(spacing: 14) {
                            PDS.Icon.emptySchedule.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 85, height: 75)

                            Text(Resource.Text.emptySchedule)
                                .foregroundColor(PDS.COLOR.gray5.scale)
                                .font(.system(size: 14))
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 30) {
                                ForEach(item.monthState.promiseList) { promise in
                                    HStack(spacing: .zero) {
                                        Text(promise.date.monthDayString)
                                            .frame(width: 30)
                                            .font(.system(size: 14))
                                            .padding(.trailing, 20)
                                            .foregroundColor(PDS.COLOR.purple9.scale)

                                        Text(promise.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.trailing, 12)
                                            .lineLimit(1)

                                        Text(hourMinuteFormatter.string(from: promise.date))
                                            .frame(width: 50)
                                            .font(.system(size: 13))
                                            .foregroundColor(PDS.COLOR.gray5.scale)
                                    }
                                    .onTapGesture { viewStore.send(.promiseTapped(promise.id)) }
                                }
                            }
                        }
                    }
                }
                .tag(item.id)
            }
        }
        .frame(height: layoutConstraint.scrollViewHeight + verticalPadding)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private func transformToIndex(point: CGPoint, viewWidth: CGFloat) -> Int {
        let rowWidth = Int(viewWidth) / layoutConstraint.weekDayListCout
        let rowHeight = Int(layoutConstraint.dayRowHeight)
        let xLocation = Int(point.x) / rowWidth
        let yLocation = Int(point.y) / rowHeight * 7

        return xLocation + yLocation
    }
}

extension CalendarView {
    struct ViewState: Equatable {
        let calendarForm: CalendarForm
        @BindingState var selectedMonth: Date
        let monthList: IdentifiedArrayOf<MonthCore.State>
    }

    enum ViewAction: Equatable, BindableAction {
        var reducerAction: CalendarCore.Action {
            switch self {
            case let .onAppear(type: type):
                return .onAppear(type: type)

            case .onDisAppear:
                return .onDisAppear

            case .leftSideButtonTapped:
                return .leftSideButtonTapped

            case .rightSideButtonTapped:
                return .rightSideButtonTapped

            case .formChangeButtonTapped:
                return .formChangeButtonTapped

            case let .scrollViewOffsetChanged(type: type, index: index):
                return .scrollViewOffsetChanged(type: type, index: index)

            case let .promiseTapped(id):
                return .promiseTapped(id)

            case let .binding(item):
                return .binding(item.pullback(\.viewState))
            }
        }

        case onAppear(type: CalendarType)
        case onDisAppear
        case leftSideButtonTapped
        case rightSideButtonTapped
        case formChangeButtonTapped
        case scrollViewOffsetChanged(type: CalendarType, index: Int)
        case promiseTapped(Promise.ID)
        case binding(BindingAction<ViewState>)
    }
}

private extension CalendarCore.State {
    var viewState: CalendarView.ViewState {
        get {
            .init(
                calendarForm: calendarForm,
                selectedMonth: selectedMonth,
                monthList: monthList
            )
        }
        set {
            selectedMonth = newValue.selectedMonth
        }
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

        case .promise:
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

private extension CalendarView {
    enum Resource {
        enum Text {
            static let emptySchedule = "이번달 일정이 없어요!"
        }
    }
}

private extension WeekDay {
    var color: Color {
        switch self {
        case .sunday:
            return PDS.COLOR.scarlet1.scale

        default:
            return PDS.COLOR.cGray2.scale
        }
    }
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

    var monthDayString: String {
        formatted(
            .dateTime
                .month(.defaultDigits)
                .day()
        )
    }
}

private let hourMinuteFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h시mm분"
    return formatter
}()

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
                        initialState: .preview,
                        reducer: CalendarCore()
                    )
                )

                CalendarView(
                    type: .promise,
                    store: .init(
                        initialState: .init(),
                        reducer: CalendarCore()
                    )
                )
            }
        }
    }
#endif
