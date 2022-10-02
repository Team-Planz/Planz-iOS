//
//  TimeTableView.swift
//  Planz
//
//  Created by junyng on 2022/09/28.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI

struct Schedule: Identifiable {
    var id: String = UUID().uuidString
    var startTime: TimeInterval
    var endTime: TimeInterval
    var isVisible: Bool
}

struct TimeTable {
    enum Cell {
        case deselected
        case selected
        
        mutating func toggle() {
            switch self {
            case .deselected:
                self = .selected
            case .selected:
                self = .deselected
            }
        }
    }
    
    var id: String
    var startTime: TimeInterval
    var endTime: TimeInterval
    var interval: TimeInterval
    var days: [Day]
    var schedules: [Schedule]
    var cells: [Day: [Cell]]
    var daysPerPage: Int
    var trailingSpace: CGFloat
    
    init(
        id: String = UUID().uuidString,
        startTime: TimeInterval,
        endTime: TimeInterval,
        interval: TimeInterval,
        days: [Day],
        daysPerPage: Int,
        trailingSpace: CGFloat
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.interval = interval
        self.days = days
        self.schedules = stride(from: startTime + interval, to: endTime + interval, by: interval)
            .map {
                .init(
                    startTime: $0 - interval,
                    endTime: $0,
                    isVisible: (($0 - interval) / interval).truncatingRemainder(dividingBy: 2) == 0 ? true : false
                )
            }
        let count = schedules.count
        self.cells = days.reduce(into: [Day: [Cell]]()) {
            $0[$1] = .init(repeating: .deselected, count: count)
        }
        self.daysPerPage = daysPerPage
        self.trailingSpace = trailingSpace
    }
}

struct Day: Identifiable, Hashable {
    let id: Int
    let date: Date
    
    init(date: Date) {
        self.id = date.hashValue
        self.date = date
    }
}

struct TimeTableView: View {
    
    @State var timeTable: TimeTable = .init(
        startTime: 9.0 * .hour,
        endTime: 24.0 * .hour,
        interval: 30 * .min,
        days: .weekend,
        daysPerPage: 4,
        trailingSpace: 40
    )
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            LazyHStack(spacing: 0) {
                                ForEach(timeTable.days) { day in
                                    LazyVStack(alignment: .center, spacing: 0) {
                                        Text(day.formatted(with: .d))
                                            .foregroundColor(R.color.dayTitle)
                                        
                                        Text(day.formatted(with: .mmdd))
                                            .foregroundColor(R.color.main)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: C.dayCellCornerRadius)
                                            .stroke(R.color.main)
                                            .background(
                                                RoundedRectangle(cornerRadius: C.dayCellCornerRadius)
                                                    .fill(R.color.dayBackground)
                                            )
                                            .frame(
                                                width: C.dayCellSize.width,
                                                height: C.dayCellSize.height
                                            )
                                    )
                                    .frame(
                                        width: (proxy.size.width - C.scheduleColumnWidth - timeTable.trailingSpace) / CGFloat(timeTable.daysPerPage)
                                    )
                                    .frame(maxHeight: .infinity)
                                }
                            }
                            .padding(.leading, C.scheduleColumnWidth)
                            .frame(height: C.headerHeight)
                            .background(R.color.background)
                            
                            Rectangle()
                                .frame(height: C.lineWidth)
                                .foregroundColor(R.color.line)
                            
                            let rows = Array(
                                repeating: GridItem(.fixed(C.timeCellHeight), spacing: 0, alignment: .leading),
                                count: timeTable.schedules.count
                            )
                            LazyHGrid(
                                rows: rows,
                                spacing: 0,
                                pinnedViews: .sectionHeaders
                            ) {
                                Section(
                                    header:
                                        LazyVStack(spacing: 0) {
                                            ForEach(timeTable.schedules) { schedule in
                                                Group {
                                                    if schedule.isVisible {
                                                        Text(schedule.startTime.formatted(with: .hhmm))
                                                            .font(.system(.callout))
                                                            .foregroundColor(R.color.schedule)
                                                            .minimumScaleFactor(0.5)
                                                    } else {
                                                        Spacer()
                                                    }
                                                }
                                                .frame(height: C.timeCellHeight, alignment: .top)
                                            }
                                        }
                                        .frame(width: C.scheduleColumnWidth)
                                        .background(R.color.background)
                                        .overlay(
                                            Rectangle()
                                                .frame(width: 1)
                                                .foregroundColor(R.color.line),
                                            alignment: .trailing
                                        )
                                ) {
                                    ForEach(timeTable.days) { day in
                                        ForEach(0..<rows.count, id: \.self) { row in
                                            let id = "\(day.id)\(row)"
                                            Rectangle()
                                                .frame(width: (proxy.size.width - C.scheduleColumnWidth - timeTable.trailingSpace) / CGFloat(timeTable.daysPerPage))
                                                .foregroundColor(timeTable.cells[day]?[row] == .selected ? R.color.main : R.color.background)
                                                .clipShape(Rectangle())
                                                .overlay(
                                                    Rectangle()
                                                        .frame(width: C.lineWidth)
                                                        .foregroundColor(R.color.line),
                                                    alignment: .trailing
                                                )
                                                .overlay(
                                                    Rectangle()
                                                        .frame(height: C.lineWidth)
                                                        .foregroundColor(R.color.line)
                                                    ,
                                                    alignment: .bottom
                                                )
                                                .id(id)
                                                .onTapGesture {
                                                    timeTable.cells[day]?[row].toggle()
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(
                            width: C.scheduleColumnWidth + ((proxy.size.width - C.scheduleColumnWidth - timeTable.trailingSpace) / CGFloat(timeTable.daysPerPage)) * CGFloat(timeTable.days.count)
                        )
                    }
                    
                    GeometryReader { _proxy in
                        LinearGradient(
                            colors: [R.color.background.opacity(0.1), R.color.background],
                            startPoint: .trailing,
                            endPoint: .leading
                        )
                            .offset(x: _proxy.frame(in: .global).minX)
                            .frame(
                                width: C.scheduleColumnWidth,
                                height: C.headerHeight
                            )
                    }
                }
            }
        }
    }
    
    private struct C {
        static let headerHeight: CGFloat = 80
        static let lineWidth: CGFloat = 1
        static let scheduleColumnWidth: CGFloat = 62
        static let disabledAreaWidth: CGFloat = 40
        static let dayCellSize: CGSize = .init(width: 43, height: 61)
        static let dayCellCornerRadius: CGFloat = 27
        static let timeCellHeight: CGFloat = 40
    }
    
    private struct R {
        struct color {
            static let dayTitle: Color = .init(red: 62/255, green: 65/255, blue: 75/255)
            static let dayBackground: Color = .init(red: 232/255, green: 234/255, blue: 254/255)
            static let background: Color = .init(red: 251/255, green: 251/255, blue: 251/255)
            static let schedule: Color = .init(red: 91/255, green: 104/255, blue: 122/255)
            static let main: Color = .init(red: 102/255, green: 113/255, blue: 246/255)
            static let line: Color = .init(red: 232/255, green: 234/255, blue: 237/255)
        }
    }
}

private extension Day {
    func formatted(with formatter: DateFormatter) -> String {
        formatter.string(from: date)
    }
}

private extension TimeInterval {
    static let day: Self = 86400
    static let hour: Self = 3600
    static let min: Self = 60
    
    func formatted(with formatter: DateComponentsFormatter) -> String {
        formatter.string(from: self) ?? .init()
    }
}

extension Array where Element == Day {
    static var weekend: Self {
        return (0..<7).map { index -> Day in
            return .init(date: .init(timeIntervalSinceNow: .day * TimeInterval(index)))
        }
    }
}

private extension DateFormatter {
    static var d: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
    
    static var mmdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

private extension DateComponentsFormatter {
    static var hhmm: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
}

struct TimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableView()
    }
}
