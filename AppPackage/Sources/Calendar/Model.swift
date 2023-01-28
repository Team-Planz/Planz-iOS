import Foundation

public struct Day: Identifiable, Hashable {
    public var id: Date { date }
    let date: Date
    var appoints: [String] = []
    
    //: - MARK: isFaded, isToday는 ViewState 속성이지만, 해당 자료구조를 두개를 생성하며 관리하는게 비효율적이라고 생각해서 State 자체에 종속시켰습니다.
    // isToday 같은 경우 현재 상수로 선언했지만, 추후에 앱이 켜졌을때 비교를 하는 코드를 작성하도록 하겠습니다.
    let isFaded: Bool
    let isToday: Bool

    var flag: Bool = false
}

public struct MonthState: Identifiable, Hashable {
    public let id: Date
    var days: [Day] = []
    var ranges: [Date: [Date]] = [: ]
}
