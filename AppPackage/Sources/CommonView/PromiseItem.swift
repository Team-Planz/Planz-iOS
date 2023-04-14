import DesignSystem
import SharedModel
import SwiftUI

public struct PromiseItem: View {
    let state: PromiseItemState

    public init(state: PromiseItemState) {
        self.state = state
    }

    public var body: some View {
        HStack(spacing: 16) {
            state.promiseType.image
                .resizable()
                .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: .zero) {
                Text(formatter.string(from: state.date))
                    .foregroundColor(PDS.COLOR.gray5.scale)
                    .font(.planz(.body12))

                Text(state.name)
                    .font(.planz(.subtitle14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { Color.white }
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
                    id: .zero,
                    promiseType: .meeting,
                    name: "앱 출시하기",
                    date: .now
                )
            )
        }
    }
#endif
