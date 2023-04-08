//
//  TimeSelectionView.swift
//
//
//  Created by junyng on 2023/04/01.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct TimeSelection: ReducerProtocol {
    public struct State: Equatable {
        @PresentationState var picker: TimePicker.State?
        public var startTime: Int?
        public var endTime: Int?
        public let timeRange: TimeRange

        public init(
            picker: TimePicker.State? = nil,
            startTime: Int? = nil,
            endTime: Int? = nil,
            timeRange: TimeRange
        ) {
            self.picker = picker
            self.startTime = startTime
            self.endTime = endTime
            self.timeRange = timeRange
        }

        var isTimeRangeValid: Bool {
            guard let startTime,
                  let endTime else { return false }
            guard timeRange.start <= startTime,
                  timeRange.end >= endTime else { return false }
            return startTime <= endTime
        }

        var times: [Int] {
            (timeRange.start ... timeRange.end).map { $0 }
        }
    }

    public enum Action: Equatable, BindableAction {
        case startTimeTapped
        case endTimeTapped
        case picker(PresentationAction<TimePicker.Action>)
        case binding(BindingAction<State>)
    }

    public enum PickerMode: Identifiable {
        case start
        case end

        public var id: Int {
            hashValue
        }

        public var title: String {
            switch self {
            case .start:
                return "시작 시간을 선택해주세요"
            case .end:
                return "종료 시간을 선택해주세요"
            }
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .startTimeTapped:
                guard let firstTime = state.times.first else {
                    return .none
                }
                state.picker = .init(
                    id: PickerMode.start.id,
                    title: PickerMode.start.title,
                    times: state.times,
                    selectedTime: state.startTime ?? firstTime
                )
                return .none
            case .endTimeTapped:
                guard let lastTime = state.times.last else {
                    return .none
                }
                state.picker = .init(
                    id: PickerMode.end.id,
                    title: PickerMode.end.title,
                    times: state.times,
                    selectedTime: state.endTime ?? lastTime
                )
                return .none
            case .picker(.dismiss):
                guard let selectedTime = state.picker?.selectedTime else {
                    return .none
                }
                if state.picker?.id == PickerMode.start.id {
                    state.startTime = selectedTime
                }
                if state.picker?.id == PickerMode.end.id {
                    state.endTime = selectedTime
                }
                state.picker = nil
                return .none
            case .picker:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$picker, action: /Action.picker) {
            TimePicker()
        }
        BindingReducer()
    }
}

public struct TimeSelectionView: View {
    let store: StoreOf<TimeSelection>
    @ObservedObject var viewStore: ViewStoreOf<TimeSelection>

    public init(store: StoreOf<TimeSelection>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(
                            viewStore.startTime == nil
                                ? PDS.COLOR.gray2.scale
                                : (viewStore.isTimeRangeValid ? PDS.COLOR.purple1.scale : PDS.COLOR.scarlet0.scale)
                        )
                        .frame(
                            width: Constant.overlaySize.width,
                            height: Constant.overlaySize.height
                        )
                    Text("\(viewStore.startTime ?? viewStore.timeRange.start)")
                        .font(.largeTitle)
                        .foregroundColor(
                            viewStore.startTime == nil
                                ? PDS.COLOR.gray4.scale
                                : (viewStore.isTimeRangeValid ? PDS.COLOR.purple9.scale : PDS.COLOR.scarlet1.scale)
                        )
                }
                .onTapGesture {
                    viewStore.send(.startTimeTapped)
                }
                .padding(.trailing, 3)
                Text(Resource.String.fromTime)
                    .foregroundColor(PDS.COLOR.gray8.scale)
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundColor(
                            viewStore.endTime == nil
                                ? PDS.COLOR.gray2.scale
                                : (viewStore.isTimeRangeValid ? PDS.COLOR.purple1.scale : PDS.COLOR.scarlet0.scale)
                        )
                        .frame(
                            width: Constant.overlaySize.width,
                            height: Constant.overlaySize.height
                        )
                    Text("\(viewStore.endTime ?? viewStore.timeRange.end)")
                        .font(.largeTitle)
                        .foregroundColor(
                            viewStore.endTime == nil
                                ? PDS.COLOR.gray4.scale
                                : (viewStore.isTimeRangeValid ? PDS.COLOR.purple9.scale : PDS.COLOR.scarlet1.scale)
                        )
                }
                .padding(.horizontal, 9)
                .onTapGesture {
                    viewStore.send(.endTimeTapped)
                }
                Text(Resource.String.toTime)
                    .foregroundColor(PDS.COLOR.gray8.scale)
            }
            .bold()
            .padding(.top, 150)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .sheet(
            store: self.store.scope(
                state: \.$picker,
                action: TimeSelection.Action.picker
            )
        ) {
            TimePickerView(store: $0)
                .presentationDetents([.height(Constant.pickerHeight)])
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
        static let startTimeSelection = "시작 시간 선택"
        static let endTimeSelection = "끝 시간 선택"
    }
}
