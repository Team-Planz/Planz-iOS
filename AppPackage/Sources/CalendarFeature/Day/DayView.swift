import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct DayCore: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public let id: Date
        public var day: Day

        public init(day: Day) {
            id = day.id
            self.day = day
        }
    }

    public enum Action: Equatable {
        case tapped
        case updatePromise([DayPromise])
    }

    public init() {}

    public func reduce(
        into state: inout State,
        action: Action
    ) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .tapped:
            return .none

        case let .updatePromise(promiseList):
            promiseList
                .forEach { state.day.promiseList.updateOrAppend($0) }
            return .none
        }
    }
}

public struct DayView: View {
    public struct LayoutConstraint {
        let rowHeight: CGFloat
    }

    let calendarType: CalendarType
    let layoutConstraint: LayoutConstraint
    let store: StoreOf<DayCore>
    @ObservedObject var viewStore: ViewStoreOf<DayCore>

    public init(
        calendarType: CalendarType,
        layoutConstraint: LayoutConstraint,
        store: StoreOf<DayCore>
    ) {
        self.calendarType = calendarType
        self.layoutConstraint = layoutConstraint
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(spacing: 1) {
            Text(viewStore.day.date.dayString)
                .bold(viewStore.day.isToday)
                .foregroundColor(
                    .dayColor(
                        date: viewStore.day.date,
                        isFaded: viewStore.day.isFaded
                    )
                )

            makeCirlces(count: viewStore.day.promiseList.count)
        }
        .frame(height: layoutConstraint.rowHeight)
        .background {
            ZStack {
                switch viewStore.day.selectionType {
                case .clear:
                    Color.clear

                case .painted:
                    PDS.COLOR.purple9.scale
                        .cornerRadius(11)
                        .frame(width: 32, height: 30)
                }
            }
        }
        .onTapGesture { viewStore.send(.tapped) }
        .disabled(calendarType == .promise)
    }

    @ViewBuilder
    private func makeCirlces(count: Int) -> some View {
        HStack(spacing: 3) {
            let itemList = (0 ..< min(count, 3))
                .map { $0 }
            ForEach(itemList, id: \.self) { item in
                makeCircle(item: item)
            }
        }
    }

    @ViewBuilder
    private func makeCircle(item: Int) -> some View {
        switch item {
        case .zero:
            Circle()
                .frame(width: 3, height: 3)
                .foregroundColor(PDS.COLOR.scarlet1.scale)

        case 1:
            Circle()
                .frame(width: 3, height: 3)
                .foregroundColor(PDS.COLOR.yellow1.scale)

        case 2:
            Circle()
                .frame(width: 3, height: 3)
                .foregroundColor(PDS.COLOR.purple9.scale)

        default:
            EmptyView()
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
}

private extension Color {
    static func dayColor(date: Date, isFaded: Bool) -> Self {
        guard !isFaded else { return PDS.COLOR.gray3.scale }
        return calendar.component(.weekday, from: date) == 1
            ? PDS.COLOR.scarlet1.scale
            : PDS.COLOR.cGray2.scale
    }
}

#if DEBUG
    extension Date {
        static var random: Date {
            let date = Date.now
            var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: .now)
            guard
                let hourRange = calendar.range(of: .hour, in: .day, for: date),
                let hour = hourRange.randomElement(),
                let minuteRange = calendar.range(of: .minute, in: .hour, for: date),
                let minute = minuteRange.randomElement()
            else { return .now }
            dateComponents.hour = hour
            dateComponents.minute = minute
            guard
                let result = calendar.date(from: dateComponents)
            else { return .now }

            return result
        }
    }

    extension Array where Element == DayPromise {
        static var mock: Self {
            [
                .init(date: .random, name: "모각코 🙌"),
                .init(date: .random, name: "YAPP 런칭 약속 👌👌👌👌"),
                .init(date: .random, name: "돼지파티 약속 🐷"),
                .init(date: .random, name: "애플 로그인 약속 🍎"),
                .init(date: .random, name: "🫥 🤠 🫥"),
                .init(date: .random, name: "🫥 🤠 🫥"),
                .init(date: .random, name: "🫥 🤠 🫥"),
                .init(date: .random, name: "🫥 🤠 🫥")
            ]
        }
    }

    public extension IdentifiedArrayOf where Element == DayPromise {
        static var mock: IdentifiedArrayOf<DayPromise> {
            .init(uniqueElements: [DayPromise].mock)
        }
    }

    struct DayView_Previews: PreviewProvider {
        static var previews: some View {
            DayView(
                calendarType: .home, layoutConstraint: .init(rowHeight: 32),
                store: .init(
                    initialState: .init(
                        day: Day(
                            date: .today,
                            promiseList: .mock,
                            isFaded: false,
                            isToday: true
                        )
                    ),
                    reducer: DayCore()
                )
            )
            .previewLayout(.sizeThatFits)
        }
    }
#endif
