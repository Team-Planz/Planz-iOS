//
//  TimePromiseView.swift
//  Planz
//
//  Created by junyng on 2022/12/17.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct TimePromise: ReducerProtocol {
    struct State: Equatable {
        @BindableState var pickerSelection: PickerSelection?
        @BindableState var startDate: Date
        @BindableState var endDate: Date
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            }
        }
        BindingReducer()
    }
}

struct TimePromiseView: View {
    let store: StoreOf<TimePromise>
    @ObservedObject var viewStore: ViewStoreOf<TimePromise>

    init(store: StoreOf<TimePromise>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(Resource.PlanzColor.gray100)
                        .frame(
                            width: Constant.overlaySize.width,
                            height: Constant.overlaySize.height
                        )
                    Text(
                        viewStore.startDate.formatted(
                            .verbatim(
                                "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))",
                                timeZone: .current,
                                calendar: .current
                            )
                        )
                    )
                    .font(.largeTitle)
                    .foregroundColor(Resource.PlanzColor.gray300)
                }
                .onTapGesture {
                    viewStore.send(.binding(.set(\.$pickerSelection, .start)))
                }
                .padding(.trailing, 3)
                Text(Resource.String.fromTime)
                    .foregroundColor(Resource.PlanzColor.gray900)
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(Resource.PlanzColor.gray100)
                        .frame(
                            width: Constant.overlaySize.width,
                            height: Constant.overlaySize.height
                        )
                    Text(
                        viewStore.endDate.formatted(
                            .verbatim(
                                "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))",
                                timeZone: .current,
                                calendar: .current
                            )
                        )
                    )
                    .font(.largeTitle)
                    .foregroundColor(Resource.PlanzColor.gray300)
                }
                .padding(.horizontal, 9)
                .onTapGesture {
                    viewStore.send(.binding(.set(\.$pickerSelection, .end)))
                }
                Text(Resource.String.toTime)
                    .foregroundColor(Resource.PlanzColor.gray900)
            }
            .bold()
            .padding(.top, 150)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .sheet(item: viewStore.binding(\.$pickerSelection)) { selection in
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Button(Resource.String.confirm) {
                        viewStore.send(.binding(.set(\.$pickerSelection, nil)))
                    }
                }
                .overlay(
                    Text(selection.title)
                )
                Picker(
                    "TimePicker",
                    selection: selection == .start
                        ? self.viewStore.binding(\.$startDate)
                        : self.viewStore.binding(\.$endDate)
                ) {
                    let dates = Constant.timeRange.compactMap {
                        Calendar.current.date(
                            bySettingHour: $0,
                            minute: .zero,
                            second: .zero,
                            of: .now
                        )
                    }
                    ForEach(dates, id: \.self) {
                        Text($0.formatted(.dateTime.hour()))
                    }
                }
                .pickerStyle(.wheel)
                .presentationDetents([.height(Constant.pickerHeight)])
            }
            .padding()
        }
    }
}

enum PickerSelection: Identifiable {
    case start
    case end

    var id: Int {
        hashValue
    }

    var title: String {
        switch self {
        case .start:
            return Resource.String.startTimeSelection
        case .end:
            return Resource.String.endTimeSelection
        }
    }
}

private enum Constant {
    static let timeRange = 9 ... 24
    static let pickerHeight: CGFloat = 200
    static let overlaySize: CGSize = .init(width: 50, height: 14)
}

private enum Resource {
    enum String {
        static let fromTime = "시 부터 "
        static let toTime = "시 까지로 할래요!"
        static let confirm = "확인"
        static let startTimeSelection = "시작 시간 선택"
        static let endTimeSelection = "끝 시간 선택"
    }

    enum PlanzColor {
        static let gray100: Color = .init(red: 243 / 255, green: 245 / 255, blue: 248 / 255)
        static let gray300: Color = .init(red: 205 / 255, green: 210 / 255, blue: 217 / 255)
        static let gray900: Color = .init(red: 2 / 255, green: 2 / 255, blue: 2 / 255)
    }
}
