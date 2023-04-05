import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct DayCore: ReducerProtocol {
    public struct State: Equatable, Identifiable {
        public var id: Date {
            day.id
        }

        public var day: Day

        public init(day: Day) {
            self.day = day
        }
    }

    public enum Action: Equatable {
        case tapped
    }

    public init() {}

    public func reduce(
        into _: inout State,
        action: Action
    ) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .tapped:
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
    struct DayView_Previews: PreviewProvider {
        static var previews: some View {
            DayView(
                calendarType: .home, layoutConstraint: .init(rowHeight: 32),
                store: .init(
                    initialState: .init(
                        day: Day(
                            date: .today,
                            promiseList: [
                                .init(
                                    type: .meal,
                                    date: .today,
                                    name: "앱 출시하기",
                                    place: "",
                                    participants: []
                                ),
                                .init(
                                    type: .meal,
                                    date: .today,
                                    name: "앱 출시하기",
                                    place: "",
                                    participants: []
                                ),
                                .init(
                                    type: .meal,
                                    date: .today,
                                    name: "앱 출시하기",
                                    place: "",
                                    participants: []
                                )
                            ],
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
