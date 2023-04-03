import ComposableArchitecture
import DesignSystem
import Entity
import SwiftUI

public struct PromiseItemCore: ReducerProtocol {
    public struct State: Equatable {
        let promiseType: PromiseType
        let name: String
        let date: Date

        public init(
            promiseType: PromiseType,
            name: String,
            date: Date
        ) {
            self.promiseType = promiseType
            self.name = name
            self.date = date
        }
    }

    public init() {}

    public enum Action: Equatable {
        case tapped
    }

    public var body: some ReducerProtocolOf<Self> {
        EmptyReducer()
    }
}

struct PromiseItem: View {
    let store: StoreOf<PromiseItemCore>
    @ObservedObject var viewStore: ViewStoreOf<PromiseItemCore>

    public init(store: StoreOf<PromiseItemCore>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        HStack(spacing: 16) {
            viewStore.promiseType.image
                .resizable()
                .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: .zero) {
                Text(formatter.string(from: viewStore.date))

                Text(viewStore.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { Color.white }
        }
        .onTapGesture { viewStore.send(.tapped) }
    }
}

private extension PromiseType {
    var image: Image {
        switch self {
        case .meal:
            return PDS.Icon.meal.image
        case .meeting:
            return PDS.Icon.meeting.image
        case .trip:
            return PDS.Icon.trip.image
        case .etc:
            return PDS.Icon.etc.image
        }
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "a h시"
    formatter.amSymbol = "오전"
    formatter.pmSymbol = "오후"

    return formatter
}()

#if DEBUG
    struct PromiseItem_Previews: PreviewProvider {
        static var previews: some View {
            PromiseItem(
                store: .init(
                    initialState: .init(
                        promiseType: .meeting,
                        name: "앱 출시하기",
                        date: .now
                    ),
                    reducer: PromiseItemCore()
                )
            )
        }
    }
#endif
