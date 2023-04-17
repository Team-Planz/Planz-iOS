//
//  TimePickerView.swift
//
//
//  Created by junyng on 2023/04/03.
//

import ComposableArchitecture
import SwiftUI

public struct TimePicker: ReducerProtocol {
    public struct State: Equatable {
        let id: Int
        let title: String
        let times: [Int]
        var selectedTime: Int

        public init(
            id: Int,
            title: String,
            times: [Int],
            selectedTime: Int
        ) {
            self.id = id
            self.title = title
            self.times = times
            self.selectedTime = selectedTime
        }
    }

    public enum Action: Equatable {
        case confirmButtonTapped
        case timeChanged(Int)
    }

    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .confirmButtonTapped:
                return .fireAndForget {
                    await dismiss()
                }
            case let .timeChanged(time):
                state.selectedTime = time
                return .none
            }
        }
    }
}

public struct TimePickerView: View {
    let store: StoreOf<TimePicker>
    @ObservedObject var viewStore: ViewStoreOf<TimePicker>

    public init(store: StoreOf<TimePicker>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                Button(Resource.String.confirm) {
                    viewStore.send(.confirmButtonTapped)
                }
            }
            .overlay(
                Text(viewStore.title)
            )
            Picker(
                "TimePicker",
                selection: viewStore.binding(
                    get: \.selectedTime,
                    send: TimePicker.Action.timeChanged
                )
            ) {
                ForEach(viewStore.times, id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
}

public struct TimeRange: Equatable {
    let start: Int
    let end: Int

    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}

private enum Resource {
    enum String {
        static let confirm = "확인"
    }
}
