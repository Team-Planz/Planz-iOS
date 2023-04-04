import DesignSystem
import Entity
import SwiftUI

public struct PromiseItem: View {
    let state: State

    public init(state: State) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: 16) {
            state.promiseType.image
                .resizable()
                .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: .zero) {
                Text(formatter.string(from: state.date))

                Text(state.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { Color.white }
        }
    }
}

public extension PromiseItem {
    struct State: Equatable {
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
                state: .init(
                    promiseType: .meeting,
                    name: "앱 출시하기",
                    date: .now
                )
            )
        }
    }
#endif
