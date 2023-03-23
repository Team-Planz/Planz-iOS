import CalendarFeature
import ComposableArchitecture
import DesignSystem
import Foundation
import Introspect
import SwiftUI

public struct HomeView: View {
    let store: StoreOf<HomeCore>
    @ObservedObject var viewStore: ViewStore<ViewState, HomeCore.Action>

    public init(store: StoreOf<HomeCore>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: \.viewState))
    }

    public var body: some View {
        VStack(spacing: .zero) {
            HStack(alignment: .center, spacing: .zero) {
                PDS.Icon.planzLogoHome.image
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)

                Text(Resource.Text.planz)
                    .foregroundColor(PDS.COLOR.purple7.scale)

                Spacer()

                PDS.Icon.profile.image
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .padding(.bottom, 20)

            todayPromiseListView

            CalendarView(
                type: .home,
                store: store
                    .scope(
                        state: \.calendar,
                        action: HomeCore.Action.calendar
                    )
            )
        }
        .padding(.horizontal, 20)
        .background {
            PDS.COLOR.white1.scale
                .ignoresSafeArea()
        }
    }

    var todayPromiseListView: some View {
        VStack(spacing: .zero) {
            HStack(spacing: 12) {
                Text(Resource.Text.todayPromise)

                Text("\(viewStore.todayPromiseList.count)")
                    .padding(.horizontal, 10)
                    .foregroundColor(PDS.COLOR.purple9.scale)
                    .background(PDS.COLOR.purple3.scale)
                    .cornerRadius(10)

                Spacer()
            }
            .frame(height: 60)
            .padding(.leading, 16)

            SnapCarousel(
                itemList: viewStore.todayPromiseList,
                spacing: 10,
                trailingSpace: 80
            ) { promise in
                PromiseView(
                    promiseType: promise.type,
                    name: promise.name,
                    date: promise.date
                )
                .onTapGesture { viewStore.send(.rowTapped(promise.date)) }
            }
            .frame(height: viewStore.todPromiseListHeight)
            .padding(.bottom, 38)
        }
        .background(.white)
        .cornerRadius(12)
        .padding(.bottom, 16)
    }
}

extension HomeView {
    struct ViewState: Equatable {
        var todPromiseListHeight: CGFloat {
            switch todayPromiseList.count {
            case .zero:
                return .zero
            case 1:
                return 46
            default:
                return 112
            }
        }

        let todayPromiseList: [Promise]
    }

    enum Resource {
        enum Text {
            static let planz = "플랜즈"
            static let todayPromise = "오늘의 약속"
        }
    }
}

extension HomeCore.State {
    var viewState: HomeView.ViewState {
        .init(todayPromiseList: todayPromiseList)
    }
}

#if DEBUG
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(
                store: .init(
                    initialState: .init(
                        calendar: .init(
                            monthList: mock
                        )
                    ),
                    reducer: HomeCore()
                )
            )
        }
    }
#endif

public let mock: IdentifiedArrayOf<MonthCore.State> = {
    var list = IdentifiedArrayOf<MonthCore.State>()
    let item = try? CalendarClient.liveValue.createMonthStateList(.home, .default, .currentMonth)
    var unwraped = item ?? []
    let firstIndex = unwraped.firstIndex(where: { $0.id.date == .currentMonth })!
    let dayFirstIndex = unwraped[firstIndex].days.firstIndex(where: { $0.id == .today })!
    unwraped[firstIndex].days[dayFirstIndex].promiseList = [
        .init(type: .meeting, date: .today, name: "모각코 🙌"),
        .init(type: .etc, date: .today, name: "YAPP 런칭 약속 👌👌👌👌"),
        .init(type: .meal, date: .today, name: "돼지파티 약속 🐷"),
        .init(type: .meeting, date: .today, name: "애플 로그인 약속 🍎"),
        .init(type: .etc, date: .today, name: "🫥 🤠 🫥")
    ]
    let result = unwraped.map { MonthCore.State(monthState: $0) }
    list.append(contentsOf: result)

    return list
}()
