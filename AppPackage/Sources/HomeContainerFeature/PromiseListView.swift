import ComposableArchitecture
import Foundation
import SwiftUI
import DesignSystem
import Entity
import CommonView

public struct PromiseListCore: ReducerProtocol {
    public struct State: Equatable {
        let date: Date
        var promiseList: [Promise]
    }
    
    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case dismiss
        }
        
        case closeButtonTapped
        case delegate(Delegate)
    }
    
    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .send(.delegate(.dismiss))
                
            case .delegate:
                return .none
            }
        }
    }
}


struct PromiseListView: View {
    let store: StoreOf<PromiseListCore>
    @ObservedObject var viewStore: ViewStoreOf<PromiseListCore>
    
    init (store: StoreOf<PromiseListCore>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
            VStack {
                HStack {
                    Text(viewStore.date.headerString + Resource.Text.headerText)
                        .foregroundColor(PDS.COLOR.gray8.scale)
                        .font(.planz(.body12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: { }) {
                        PDS.Icon.close.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.vertical, 24)
                }
                
                ScrollView(showsIndicators: false) {
                    
                    ForEach(viewStore.promiseList) {
                        PromiseItem(state: .init(promise: $0))
                        }
                }
                .opacity(viewStore.promiseList.isEmpty ? .zero : 1)
                
                Text(Resource.Text.emptyPromiseList)
                    .foregroundColor(PDS.COLOR.gray5.scale)
                    .font(.planz(.body16))
                    .opacity(viewStore.promiseList.isEmpty ? 1: .zero)
            }
            .padding(.horizontal, 20)
    }
}

private extension PromiseListView {
    struct Resource {
        struct Text {
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
        )
    }
}

#if DEBUG
struct PromiseListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack { }
            .sheet(isPresented: .constant(true)) {
                PromiseListView(
                    store: .init(
                        initialState: .init(
                            date: .now,
                            promiseList: [
                                .init(type: .etc, date: .now, name: "돼지파티 약속"),
                                .init(type: .etc, date: .now, name: "ABC1"),
                                .init(type: .etc, date: .now, name: "ABC2")
                            ]
                        ),
                        reducer: PromiseListCore()
                    )
                )
            }
    }
}
#endif

