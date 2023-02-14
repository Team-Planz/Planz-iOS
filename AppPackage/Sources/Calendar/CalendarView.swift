import ComposableArchitecture
import Introspect
import SwiftUI

public struct CalendarView: View {
    public enum Style {
        var layoutConstraint: LayoutConstraint {
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

        case home
        case promise
    }

    struct LayoutConstraint {
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
    let style: Style
    let layoutConstraint: LayoutConstraint
    let store: StoreOf<CalendarCore>
    @ObservedObject var viewStore: ViewStoreOf<CalendarCore>

    public init(
        style: Style,
        store: StoreOf<CalendarCore>
    ) {
        self.style = style
        layoutConstraint = style.layoutConstraint
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: .zero) {
                HStack(spacing: .zero) {
                    switch style {
                    case .home:
                        VStack(spacing: .zero) {
                            HStack(spacing: .zero) {
                                Text(viewStore.selectedMonth.yearMonthString)
                                    .foregroundColor(.grayg8)
                                    .font(.system(size: 18))
                                    .padding(.trailing, 11)

                                Button(action: { viewStore.send(.leftSideButtonTapped) }) {
                                    Image.left
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(
                                            width: layoutConstraint.directionButtonSize.width,
                                            height: layoutConstraint.directionButtonSize.height
                                        )
                                }
                                .padding(.trailing, 6)

                                Button(action: { viewStore.send(.rightSideButtonTapped) }) {
                                    Image.right
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(
                                            width: layoutConstraint.directionButtonSize.width,
                                            height: layoutConstraint.directionButtonSize.height
                                        )
                                }

                                Spacer()

                                Button(action: {}) {
                                    Image.list
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

                    case .promise:
                        Button(action: { viewStore.send(.leftSideButtonTapped) }) {
                            Image.left
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
                            .foregroundColor(.grayg8)
                            .padding(.trailing, 16)

                        Button(action: { viewStore.send(.rightSideButtonTapped) }) {
                            Image.right
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

                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .top, spacing: .zero) {
                            ForEach(viewStore.monthStateList) { month in
                                let horizontalPadding = (layoutConstraint.contentHorizontalPadding) * 2
                                let scrollViewWidth = geometryProxy.size.width - horizontalPadding
                                let rowWidth = scrollViewWidth / CGFloat(layoutConstraint.weekDayListCout)
                                let columns: [GridItem] = .init(
                                    repeating: .init(.fixed(rowWidth), spacing: .zero),
                                    count: layoutConstraint.weekDayListCout
                                )
                                LazyVGrid(
                                    columns: columns,
                                    spacing: .zero
                                ) {
                                    ForEach(month.days) { day in
                                        Text(day.date.dayString)
                                            .bold(day.isToday)
                                            .foregroundColor(.dayColor(date: day.date, isFaded: day.isFaded))
                                            .frame(height: layoutConstraint.dayRowHeight)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .id(month.id)
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
                        let scrollViewWidth = geometryProxy.size.width - horizontalPadding
                        let index = (offset / scrollViewWidth).rounded(.down)
                        viewStore.send(.scrollViewOffsetChanged(Int(index)))
                    }
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
        .onAppear { viewStore.send(.onAppear) }
        .onDisappear { viewStore.send(.onDisAppear) }
    }
}

private enum WeekDay: CaseIterable, CustomStringConvertible {
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
            return Color.scarlet1

        default:
            return Color.cggraycg2
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

private extension Image {
    static let left = Self(uiImage: .init(named: "left", in: .module, with: nil)!)
    static let right = Self(uiImage: .init(named: "right", in: .module, with: nil)!)
    static let list = Self(uiImage: .init(named: "list", in: .module, with: nil)!)
}

private extension Color {
    static func dayColor(date: Date, isFaded: Bool) -> Self {
        guard !isFaded else { return .grayg3 }
        return calendar.component(.weekday, from: date) == 1
            ? .scarlet1
            : .cggraycg2
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
                    style: .home,
                    store: .init(
                        initialState: .init(),
                        reducer: CalendarCore()
                    )
                )

                CalendarView(
                    style: .promise,
                    store: .init(
                        initialState: .init(),
                        reducer: CalendarCore()
                    )
                )
            }
        }
    }
#endif

// MARK: Must be removed when design system module created.

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    static let scarlet1: Color = .init(hex: "FF7F77")
    static let cggraycg2: Color = .init(hex: "5B687A")
    static let grayg3: Color = .init(hex: "E8EAED")
    static let grayg8: Color = .init(hex: "020202")
}
