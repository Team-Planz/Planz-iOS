import CommonView
import ComposableArchitecture
import DesignSystem
import Entity
import Foundation
import SharedModel
import SwiftUI
import SwiftUIHelper

public struct PromiseListCore: ReducerProtocol {
    public struct State: Equatable {
        let date: Date
        var promiseList: IdentifiedArrayOf<PromiseItemState>
        var selectedPromise: PromiseDetailViewState?
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case selectPromise(Date)
            case dismiss
        }

        case rowTapped(Date)
        case closeButtonTapped
        case deSelectPromise
        case delegate(Delegate)
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .rowTapped(date):
                return .none

            case .closeButtonTapped:
                return .send(.delegate(.dismiss))

            case .deSelectPromise:
                state.selectedPromise = nil
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

struct PromiseListView: View {
    let store: StoreOf<PromiseListCore>
    @ObservedObject var viewStore: ViewStoreOf<PromiseListCore>

    init(store: StoreOf<PromiseListCore>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Text(viewStore.date.headerString + Resource.Text.headerText)
                    .foregroundColor(PDS.COLOR.gray8.scale)
                    .font(.planz(.body12))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { viewStore.send(.closeButtonTapped) }) {
                    PDS.Icon.close.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                .padding(.vertical, 24)
            }

            ScrollView(showsIndicators: false) {
                ForEach(viewStore.promiseList) { itemState in
                    PromiseItem(state: itemState)
                        .onTapGesture { viewStore.send(.rowTapped(itemState.date)) }
                }
            }
            .hidden(viewStore.promiseList.isEmpty)

            Text(Resource.Text.emptyPromiseList)
                .foregroundColor(PDS.COLOR.gray5.scale)
                .font(.planz(.body16))
                .frame(maxHeight: .infinity)
                .hidden(!viewStore.promiseList.isEmpty)
        }
        .frame(alignment: .top)
        .padding(.horizontal, 20)
    }
}

private extension PromiseListView {
    enum Resource {
        enum Text {
            static let headerText = " 약속"
            static let emptyPromiseList = "오늘의 약속이 없습니다."
        }
    }
}

private extension Date {
    var headerString: String {
        formatted(
            .dateTime
                .month()
                .day()
                .locale(.init(identifier: "KO"))
        )
    }
}

#if DEBUG
    struct PromiseListView_Previews: PreviewProvider {
        static var previews: some View {
            ZStack {}
                .sheet(isPresented: .constant(true)) {
                    PromiseListView(
                        store: .init(
                            initialState: .init(
                                date: .now,
                                promiseList: [
                                    .init(id: .zero, promiseType: .etc, name: "돼지파티 약속", date: .now),
                                    .init(id: 1, promiseType: .etc, name: "ABC1", date: .now),
                                    .init(id: 2, promiseType: .etc, name: "ABC2", date: .now)
                                ]
                            ),
                            reducer: PromiseListCore()
                        )
                    )
                }
        }
    }
#endif
