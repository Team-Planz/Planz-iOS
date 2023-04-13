//
//  ManagementView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import APIClient
import APIClientLive
import CommonView
import ComposableArchitecture
import DesignSystem
import Entity
import SharedModel
import SwiftUI

public struct PromiseManagement: ReducerProtocol {
    public init() {}

    @Dependency(\.apiClient) var apiClient

    public struct State: Equatable {
        @BindingState var visibleTab: Tab = .standby
        var confirmedTab = ConfirmedListFeature.State()
        var standbyTab = StandbyListFeature.State()
        @BindingState var detailItem: PromiseDetailViewState?

        public init(
            standbyRows: IdentifiedArrayOf<StandbyCell.State> = [],
            confirmedRows: IdentifiedArrayOf<ConfirmedCell.State> = [],
            detailItem: PromiseDetailViewState? = nil
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
        case standbyFetchAllResponse([StandbyCell.State])
        case confirmedFetchAllResponse([ConfirmedCell.State])
        case delegate(Delegate)
        case makePromiseButtonTapped

        public enum Delegate: Equatable {
            case makePromise
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .delegate:
                return .none

            case .makePromiseButtonTapped:
                return .send(.delegate(.makePromise))

            case let .standbyFetchAllResponse(result):
                let rows = IdentifiedArrayOf(uniqueElements: result)
                state.standbyTab = StandbyListFeature.State(rows: rows)
                return .none

            case let .confirmedFetchAllResponse(result):
                let rows = IdentifiedArrayOf(uniqueElements: result)
                state.confirmedTab = ConfirmedListFeature.State(rows: rows)
                return .none

            case .onAppear:
                return .run { send in
                    await self.initializeAPIRequest(send: send)
                }

            case let .confirmedTab(.delegate(action)):
                switch action {
                case let .showDetailView(item):
                    state.detailItem = PromiseDetailViewState(
                        id: UUID(uuidString: String(item.id)) ?? UUID(),
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
                    state.detailItem = PromiseDetailViewState(
                        id: UUID(uuidString: String(item.id)) ?? UUID(),
                        title: item.title,
                        theme: "테마",
                        date: .now,
                        place: "강남역",
                        participants: item.members
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

    private func initializeAPIRequest(send: Send<Action>) async {
        do {
            async let confirmedFetchResponse: Void = send(.confirmedFetchAllResponse(
                await APIClient.mock.request(
                    route: .promise(.fetchAll(.user)),
                    as: [Promise].self
                )
                .map {
                    ConfirmedCell.State(
                        id: $0.id,
                        title: $0.name,
                        role: $0.isOwner
                            ? RoleType.leader
                            : RoleType.general,
                        leaderName: $0.owner.name,
                        replyPeopleCount: $0.members.count,
                        theme: $0.category.type,
                        date: $0.date.toString(),
                        place: $0.place,
                        participants: $0.members.map(\.name)
                    )
                }
            ))

            async let standbyFetchResponse: Void = try send(.standbyFetchAllResponse(
                await APIClient.mock.request(route: .promising(.fetchAll), as: PromisingTimeStamps.self)
                    .promisingTimeStamps
                    .map { StandbyCell.State(
                        id: $0.id,
                        title: $0.promisingName,
                        role:
                        $0.isOwner
                            ? RoleType.leader
                            : RoleType.general,
                        members: $0.members.map(\.name),
                        startDate: $0.startDate,
                        endDate: $0.endDate,
                        category: StandbyCell.State.Category(
                            id: $0.category.id,
                            keyword: $0.category.keyword,
                            type: $0.category.keyword
                        ),
                        placeName: $0.placeName
                    )
                    }
            ))

            let responses = try await (standbyFetchResponse, confirmedFetchResponse)
        } catch {}
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
                                viewStore.send(.makePromiseButtonTapped)
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
                PromiseDetailViewState(
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
