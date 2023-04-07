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
            id = date.hashValue
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
        timeRanges = stride(
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
        timeCells = .init(
            repeating: .init(repeating: .deselected, count: timeRanges.count),
            count: days.count
        )
    }
}

public enum TimeTableAction: Equatable {
    case timeCellTapped(row: Int, column: Int)
}

public let timeTableReducer = AnyReducer<
    TimeTableState,
    TimeTableAction,
    Void
> { state, action, _ in
    switch action {
    case let .timeCellTapped(row, column):
        guard row >= 0, row < state.timeRanges.count else { return .none }
        guard column >= 0, column < state.days.count else { return .none }
        state.timeCells[column][row].toggle()
        return .none
    }
}

public struct TimeTableView: View {
    let store: Store<TimeTableState, TimeTableAction>
    @ObservedObject var viewStore: ViewStore<TimeTableState, TimeTableAction>

    public init(store: Store<TimeTableState, TimeTableAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        GeometryReader { proxy in
            let dayCellWidth: CGFloat = viewStore.days.count <= LayoutConstant.visibleDaysCount
                ? proxy.size.width / CGFloat(viewStore.days.count)
                : max(proxy.size.width - LayoutConstant.trailingSpace, 0) / CGFloat(LayoutConstant.visibleDaysCount)

            ScrollView(.vertical, showsIndicators: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        weekView
                            .padding(.leading, LayoutConstant.timelineWidth)
                            .frame(
                                width: dayCellWidth * CGFloat(viewStore.days.count),
                                height: LayoutConstant.headerHeight
                            )
                            .background(Resource.PlanzColor.white200)

                        Divider()
                            .frame(height: LayoutConstant.lineWidth)
                            .overlay(Resource.PlanzColor.gray200)

                        grid
                            .frame(
                                width: dayCellWidth * CGFloat(viewStore.days.count),
                                height: LayoutConstant.timeCellHeight * CGFloat(viewStore.timeRanges.count)
                            )

                        Divider()
                            .frame(height: LayoutConstant.lineWidth)
                            .overlay(Resource.PlanzColor.gray200)
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
                        Text(day.formatted(with: .dayOnly))
                            .font(.system(size: 12))
                            .foregroundColor(Resource.PlanzColor.gray800)

                        Text(day.formatted(with: .monthAndDay))
                            .font(.system(size: 14))
                            .foregroundColor(Resource.PlanzColor.purple900)
                    }
                    .frame(
                        width: proxy.size.width / CGFloat(viewStore.days.count),
                        height: proxy.size.height
                    )
                    .background(
                        RoundedRectangle(cornerRadius: LayoutConstant.dayCellCornerRadius)
                            .stroke(Resource.PlanzColor.dayCellBorder)
                            .background(
                                RoundedRectangle(cornerRadius: LayoutConstant.dayCellCornerRadius)
                                    .fill(Resource.PlanzColor.dayCellBackground)
                            )
                            .frame(
                                width: LayoutConstant.dayCellSize.width,
                                height: LayoutConstant.dayCellSize.height
                            )
                    )
                }
            }
        }
    }

    var timeline: some View {
        LazyVStack(spacing: 0) {
            ForEach(0 ..< viewStore.timeRanges.count, id: \.self) {
                let timeRange = viewStore.timeRanges[$0]
                Group {
                    if timeRange.isStartTimeVisible {
                        Text(timeRange.startTime.formatted(with: .hhmm))
                            .font(.system(size: 12))
                            .foregroundColor(Resource.PlanzColor.gray900)
                            .minimumScaleFactor(0.5)
                    } else {
                        Spacer()
                    }
                }
                .frame(height: LayoutConstant.timeCellHeight, alignment: .top)
            }
        }
        .frame(width: LayoutConstant.timelineWidth)
        .background(Resource.PlanzColor.white200)
        .overlay(
            HStack {
                Divider()
                    .frame(width: LayoutConstant.lineWidth)
                    .overlay(Resource.PlanzColor.gray200)
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
                    ForEach(0 ..< columns, id: \.self) { column in
                        ForEach(0 ..< rows, id: \.self) { row in
                            Rectangle()
                                .frame(width: (proxy.size.width - LayoutConstant.timelineWidth) / CGFloat(columns))
                                .foregroundColor(viewStore.timeCells[column][row] == .selected
                                    ? Resource.PlanzColor.purple900 : Resource.PlanzColor.white200)
                                .clipShape(Rectangle())
                                .overlay(
                                    VerticalLine()
                                        .stroke(Resource.PlanzColor.timeCellBorder)
                                        .frame(width: LayoutConstant.lineWidth),
                                    alignment: .trailing
                                )
                                .overlay(
                                    HorizontalLine()
                                        .stroke(Resource.PlanzColor.timeCellBorder,
                                                style: row % 2 == 0 ? .init(dash: [2]) : .init())
                                        .frame(height: LayoutConstant.lineWidth),
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
            colors: [Resource.PlanzColor.white200.opacity(0.1), Resource.PlanzColor.white200],
            startPoint: .trailing,
            endPoint: .leading
        )
        .frame(
            width: LayoutConstant.timelineWidth,
            height: LayoutConstant.headerHeight
        )
    }
}

private enum LayoutConstant {
    static let headerHeight: CGFloat = 84
    static let lineWidth: CGFloat = 1
    static let timelineWidth: CGFloat = 62
    static let trailingSpace: CGFloat = 26
    static let visibleDaysCount: Int = 4
    static let dayCellSize: CGSize = .init(width: 44, height: 60)
    static let dayCellCornerRadius: CGFloat = 30
    static let timeCellHeight: CGFloat = 40
}

private enum Resource {
    enum PlanzColor {
        static let gray200: Color = .init(red: 205 / 255, green: 210 / 255, blue: 217 / 255)
        static let gray500: Color = .init(red: 156 / 255, green: 163 / 255, blue: 173 / 255)
        static let gray800: Color = .init(red: 2 / 255, green: 2 / 255, blue: 2 / 255)
        static let gray900: Color = .init(red: 91 / 255, green: 104 / 255, blue: 122 / 255)
        static let white200: Color = .init(red: 251 / 255, green: 251 / 255, blue: 251 / 255)
        static let purple100: Color = .init(red: 251 / 255, green: 251 / 255, blue: 251 / 255)
        static let purple900: Color = .init(red: 102 / 255, green: 113 / 255, blue: 246 / 255)
        static let dayCellBackground: Color = .init(red: 232 / 255, green: 234 / 255, blue: 254 / 255)
        static let dayCellBorder: Color = .init(red: 206 / 255, green: 210 / 255, blue: 252 / 255)
        static let timeCellBorder: Color = .init(red: 232 / 255, green: 234 / 255, blue: 237 / 255)
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
