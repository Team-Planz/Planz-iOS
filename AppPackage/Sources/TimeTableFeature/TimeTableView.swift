//
//  TimeTableView.swift
//  Planz
//
//  Created by junyng on 2022/09/28.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct TimeTableState: Equatable {
    public struct Day: Hashable, Equatable, Identifiable {
        public let id: Int
        let date: Date
        
        init(date: Date) {
            self.id = date.hashValue
            self.date = date
        }
    }
    
    public enum TimeCell {
        case selected
        case deselected
        
        mutating func toggle() {
            switch self {
            case .deselected:
                self = .selected
            case .selected:
                self = .deselected
            }
        }
    }
    
    public struct TimeRange: Equatable, Hashable {
        let startTime: TimeInterval
        let endTime: TimeInterval
        let isStartTimeVisible: Bool
    }
    
    let days: [Day]
    let startTime: TimeInterval
    let endTime: TimeInterval
    let timeInterval: TimeInterval
    let timeMarkerInterval: TimeInterval
    let timeRanges: [TimeRange]
    var timeCells: [[TimeCell]]
    
    init(
        days: [Day],
        startTime: TimeInterval,
        endTime: TimeInterval,
        timeInterval: TimeInterval,
        timeMarkerInterval: TimeInterval
    ) {
        self.days = days
        self.startTime = startTime
        self.endTime = endTime
        self.timeInterval = timeInterval
        self.timeMarkerInterval = timeMarkerInterval
        self.timeRanges = stride(
            from: startTime,
            to: endTime,
            by: timeInterval
        )
        .map {
            .init(
                startTime: $0,
                endTime: $0 + timeInterval,
                isStartTimeVisible: $0.truncatingRemainder(dividingBy: timeMarkerInterval) == 0
            )
        }
        self.timeCells = .init(
            repeating: .init(repeating: .deselected, count: timeRanges.count),
            count: days.count
        )
    }
}

public enum TimeTableAction: Equatable {
    case timeCellTapped(row: Int, column: Int)
}

public let timeTableReducer = Reducer<
    TimeTableState,
    TimeTableAction,
    Void
> { state, action, _ in
    switch action {
    case let .timeCellTapped(row, column):
        guard 0 <= row && row < state.timeRanges.count else { return .none }
        guard 0 <= column && column < state.days.count else { return .none }
        state.timeCells[column][row].toggle()
        return .none
    }
}

public struct TimeTableView: View {
    let store: Store<TimeTableState, TimeTableAction>
    @ObservedObject var viewStore: ViewStore<TimeTableState, TimeTableAction>
    
    public init(store: Store<TimeTableState, TimeTableAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let dayCellWidth: CGFloat = viewStore.days.count <= C.visibleDaysCount
            ? proxy.size.width / CGFloat(viewStore.days.count)
            : max((proxy.size.width - C.trailingSpace), 0) / CGFloat(C.visibleDaysCount)
            
            ScrollView(.vertical, showsIndicators: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        weekView
                            .padding(.leading, C.timelineWidth)
                            .frame(
                                width: dayCellWidth * CGFloat(viewStore.days.count),
                                height: C.headerHeight
                            )
                            .background(R.color.white200)
                        
                        Divider()
                            .frame(height: C.lineWidth)
                            .overlay(R.color.gray200)
                       
                        grid
                            .frame(
                                width: dayCellWidth * CGFloat(viewStore.days.count),
                                height: C.timeCellHeight * CGFloat(viewStore.timeRanges.count)
                            )
                        
                        Divider()
                            .frame(height: C.lineWidth)
                            .overlay(R.color.gray200)
                    }
                }
                .overlay(
                    gradient, alignment: .topLeading
                )
            }
        }
    }
    
    var weekView: some View {
        GeometryReader { proxy in
            LazyHStack(spacing: 0) {
                ForEach(viewStore.days) { day in
                    VStack(alignment: .center) {
                        Text(day.formatted(with: .d))
                            .font(.system(size: 12))
                            .foregroundColor(R.color.gray800)
                        
                        Text(day.formatted(with: .mmdd))
                            .font(.system(size: 14))
                            .foregroundColor(R.color.purple900)
                    }
                    .frame(
                        width: proxy.size.width / CGFloat(viewStore.days.count),
                        height: proxy.size.height
                    )
                    .background(
                        RoundedRectangle(cornerRadius: C.dayCellCornerRadius)
                            .stroke(R.color.dayCellBorder)
                            .background(
                                RoundedRectangle(cornerRadius: C.dayCellCornerRadius)
                                    .fill(R.color.dayCellBackground)
                            )
                            .frame(
                                width: C.dayCellSize.width,
                                height: C.dayCellSize.height
                            )
                    )
                }
            }
        }
    }
    
    var timeline: some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<viewStore.timeRanges.count, id: \.self) {
                let timeRange = viewStore.timeRanges[$0]
                Group {
                    if timeRange.isStartTimeVisible {
                        Text(timeRange.startTime.formatted(with: .hhmm))
                            .font(.system(size: 12))
                            .foregroundColor(R.color.gray900)
                            .minimumScaleFactor(0.5)
                    } else {
                        Spacer()
                    }
                }
                .frame(height: C.timeCellHeight, alignment: .top)
            }
        }
        .frame(width: C.timelineWidth)
        .background(R.color.white200)
        .overlay(
            HStack {
                Divider()
                    .frame(width: C.lineWidth)
                    .overlay(R.color.gray200)
            },
            alignment: .trailing
        )
    }
    
    var grid: some View {
        GeometryReader { proxy in
            let rows = viewStore.timeRanges.count
            let columns = viewStore.days.count
            let gridItems = Array(
                repeating: GridItem(.flexible(), spacing: 0, alignment: .leading),
                count: rows
            )
            LazyHGrid(
                rows: gridItems,
                spacing: 0,
                pinnedViews: .sectionHeaders
            ) {
                Section(
                    header: timeline
                ) {
                    ForEach(0..<columns, id: \.self) { column in
                        ForEach(0..<rows, id: \.self) { row in
                            Rectangle()
                                .frame(width: (proxy.size.width - C.timelineWidth) / CGFloat(columns))
                                .foregroundColor(viewStore.timeCells[column][row] == .selected
                                                 ? R.color.purple900 : R.color.white200)
                                .clipShape(Rectangle())
                                .overlay(
                                    VerticalLine()
                                        .stroke(R.color.timeCellBorder)
                                        .frame(width: C.lineWidth),
                                    alignment: .trailing
                                )
                                .overlay(
                                    HorizontalLine()
                                        .stroke(R.color.timeCellBorder,
                                                style: row % 2 == 0 ? .init(dash: [2]) : .init())
                                        .frame(height: C.lineWidth),
                                    alignment: .bottom
                                )
                                .id("\(row)\(column)")
                                .onTapGesture {
                                    viewStore.send(.timeCellTapped(row: row, column: column))
                                }
                        }
                    }
                }
            }
        }
    }
    
    var gradient: some View {
        LinearGradient(
            colors: [R.color.white200.opacity(0.1), R.color.white200],
            startPoint: .trailing,
            endPoint: .leading
        )
        .frame(
            width: C.timelineWidth,
            height: C.headerHeight
        )
    }
}

fileprivate struct C {
    static let headerHeight: CGFloat = 84
    static let lineWidth: CGFloat = 1
    static let timelineWidth: CGFloat = 62
    static let trailingSpace: CGFloat = 26
    static let visibleDaysCount: Int = 4
    static let dayCellSize: CGSize = .init(width: 44, height: 60)
    static let dayCellCornerRadius: CGFloat = 30
    static let timeCellHeight: CGFloat = 40
}

fileprivate struct R {
    struct color {
        static let gray200: Color = .init(red: 205/255, green: 210/255, blue: 217/255)
        static let gray500: Color = .init(red: 156/255, green: 163/255, blue: 173/255)
        static let gray800: Color = .init(red: 2/255, green: 2/255, blue: 2/255)
        static let gray900: Color = .init(red: 91/255, green: 104/255, blue: 122/255)
        static let white200: Color = .init(red: 251/255, green: 251/255, blue: 251/255)
        static let purple100: Color = .init(red: 251/255, green: 251/255, blue: 251/255)
        static let purple900: Color = .init(red: 102/255, green: 113/255, blue: 246/255)
        static let dayCellBackground: Color = .init(red: 232/255, green: 234/255, blue: 254/255)
        static let dayCellBorder: Color = .init(red: 206/255, green: 210/255, blue: 252/255)
        static let timeCellBorder: Color = .init(red: 232/255, green: 234/255, blue: 237/255)
    }
}

public extension TimeTableState {
    static var mock: Self {
        let startTime: TimeInterval = 9 * .hour
        let endTime: TimeInterval = 24 * .hour
        let timeInterval: TimeInterval = 0.5 * .hour
        return .init(
            days: .weekend,
            startTime: startTime,
            endTime: endTime,
            timeInterval: timeInterval,
            timeMarkerInterval: timeInterval * 2
        )
    }
}

struct TimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableView(
            store: .init(
                initialState: .mock,
                reducer: timeTableReducer,
                environment: ()
            )
        )
    }
}
