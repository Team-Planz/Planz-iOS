import ComposableArchitecture
import SwiftUI

public struct CalendarView: View {
    let store: StoreOf<CalendarCore>
    @ObservedObject var viewStore: ViewStoreOf<CalendarCore>
    
    public init(store: StoreOf<CalendarCore>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        ZStack {
            
        }
    }
}

#if DEBUG
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(
            store: .init(
                initialState: .init(),
                reducer: CalendarCore()
            )
        )
    }
}
#endif
