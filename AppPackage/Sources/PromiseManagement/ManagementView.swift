//
//  ManagementView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import CommonView
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct PromiseManagement: ReducerProtocol {
    public init() {}

    public struct State: Equatable {
        @BindingState var visibleTab: Tab = .standby
        var confirmedTab = ConfirmedListFeature.State()
        var standbyTab = StandbyListFeature.State()
        @BindingState var detailItem: PromiseDetailView.State?

        public init(
            standbyRows: IdentifiedArrayOf<StandbyCell.State> = [],
            confirmedRows: IdentifiedArrayOf<ConfirmedCell.State> = [],
            detailItem: PromiseDetailView.State? = nil
        ) {
            standbyTab = StandbyListFeature.State(rows: standbyRows)
            confirmedTab = ConfirmedListFeature.State(rows: confirmedRows)
            self.detailItem = detailItem
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case standbyTab(StandbyListFeature.Action)
        case confirmedTab(ConfirmedListFeature.Action)
        case closeDetailButtonTapped
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state = .init(
                    standbyRows: .mock,
                    confirmedRows: .mock,
                    detailItem:
                    PromiseDetailView.State(
                        id: UUID(),
                        title: "약속명",
                        theme: "여행",
                        date: .now,
                        place: "강남",
                        participants: ["정인혜", "이은영"]
                    )
                )

                return .none

            case let .confirmedTab(.delegate(action)):
                switch action {
                case let .showDetailView(item):
                    state.detailItem = PromiseDetailView.State(
                        id: item.id,
                        title: item.title,
                        theme: item.theme,

                        // MARK: - TODO must fix it

                        date: .now,
                        place: item.place,
                        participants: item.participants
                    )
                    return .none
                }
            case .closeDetailButtonTapped:
                state.detailItem = nil
                return .none

            case let .standbyTab(.delegate(action)):
                switch action {
                case let .showDetailView(item):
                    state.detailItem = PromiseDetailView.State(
                        id: item.id,
                        title: item.title,
                        theme: "테마",
                        date: .now,
                        place: "강남역",
                        participants: item.names
                    )
                    return .none
                }

            default:
                return .none
            }
        }
        Scope(state: \.standbyTab, action: /Action.standbyTab) {
            StandbyListFeature()
        }
        Scope(state: \.confirmedTab, action: /Action.confirmedTab) {
            ConfirmedListFeature()
        }
    }
}

public struct ManagementView: View {
    private let store: StoreOf<PromiseManagement>

    public init(store: StoreOf<PromiseManagement>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                GeometryReader { geo in
                    VStack {
                        HeaderTabView(
                            activeTab:
                            viewStore.binding(\.$visibleTab),
                            tabs: Tab.allCases,
                            fullWidth: geo.size.width - 40
                        )

                        TabView(selection:
                            viewStore.binding(\.$visibleTab)
                        ) {
                            StandbyListView(store: self.store.scope(
                                state: \.standbyTab,
                                action: PromiseManagement.Action.standbyTab
                            )
                            )
                            .tag(Tab.standby)

                            ConfirmedListView(store: store.scope(
                                state: \.confirmedTab,
                                action: PromiseManagement.Action.confirmedTab
                            ))
                            .tag(Tab.confirmed)
                        }
                        .animation(.default, value: viewStore.visibleTab.rawValue)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                    .navigationTitle("약속 관리")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                print("Add Item")
                            } label: {
                                PDS.Icon.plus.image
                            }
                        }
                    }
                    .onAppear { viewStore.send(.onAppear) }
                    .fullScreenCover(
                        unwrapping: viewStore.binding(\.$detailItem)
                    ) { state in
                        NavigationStack {
                            PromiseDetailView(state: state.wrappedValue)
                                .toolbar {
                                    ToolbarItem {
                                        Button {
                                            viewStore.send(.closeDetailButtonTapped)
                                        } label: {
                                            PDS.Icon.close.image
                                        }
                                    }
                                }
                                .navigationTitle("약속 상세보기")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
            }
        }
    }
}

struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementView(store: StoreOf<PromiseManagement>(
            initialState: PromiseManagement.State(
                standbyRows: .mock,
                confirmedRows: .mock,
                detailItem:
                PromiseDetailView.State(
                    id: UUID(),
                    title: "약속명",
                    theme: "여행",
                    date: .now,
                    place: "강남",
                    participants: ["정인혜", "이은영"]
                )
            ),
            reducer: PromiseManagement()._printChanges()
        ))
    }
}
