import CommonView
import ComposableArchitecture
import DesignSystem
import Entity
import Foundation
import SwiftUI
import SwiftUIHelper

public struct PromiseListCore: ReducerProtocol {
    public struct State: Equatable {
        let date: Date
        var promiseList: IdentifiedArrayOf<Promise>
        var selectedPromise: Promise?
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case dismiss
        }

        case rowTapped(Promise.ID)
        case closeButtonTapped
        case deSelectPromise
        case delegate(Delegate)
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case let .rowTapped(id):
                state.selectedPromise = state.promiseList[id: id]
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
                ForEach(viewStore.promiseList) { promise in
                    PromiseItem(state: .init(promise: promise))
                        .onTapGesture { viewStore.send(.rowTapped(promise.id)) }
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
                                    .init(type: .etc, date: .now, name: "돼지파티 약속", place: "", participants: []),
                                    .init(type: .etc, date: .now, name: "ABC1", place: "", participants: []),
                                    .init(type: .etc, date: .now, name: "ABC2", place: "", participants: [])
                                ]
                            ),
                            reducer: PromiseListCore()
                        )
                    )
                }
        }
    }
#endif
