import ComposableArchitecture
import SwiftUI

public struct CalendarView: View {
    public enum Style {
        case home
        case promise
    }
    
    let style: Style
    let store: StoreOf<CalendarCore>
    @ObservedObject var viewStore: ViewStoreOf<CalendarCore>
    
    public init(
        style: Style,
        store: StoreOf<CalendarCore>
    ) {
        self.style = style
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        GeometryReader { _ in
            VStack(spacing: .zero) {
                HStack(spacing: .zero) {
                    ForEach(WeekDay.allCases, id: \.self) { weekDay in
                        Text(weekDay.description)
                            .foregroundColor(weekDay.color)
                            .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                }
            }
        }
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
            return Color(hex: "FF7F77")
            
        default:
            return Color(hex: "5B687A")
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
}
