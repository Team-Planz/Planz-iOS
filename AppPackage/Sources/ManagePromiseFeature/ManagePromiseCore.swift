//
//  ManagePromiseCore.swift
//
//
//  Created by Sujin Jin on 2023/04/16.
//

import APIClient
import APIClientLive
import ComposableArchitecture
import Entity
import Foundation
import SharedModel

public struct ManagePromiseCore: ReducerProtocol {
    public init() {}

    @Dependency(\.apiClient) var apiClient

    public struct State: Equatable {
        @BindingState var visibleTab: Tab = .standby
        var confirmedTab = ConfirmedListFeature.State()
        var standbyTab = StandbyListFeature.State()

        public init(
            standbyRows: IdentifiedArrayOf<StandbyCell.State> = [],
            confirmedRows: IdentifiedArrayOf<ConfirmedCell.State> = []
        ) {
            standbyTab = StandbyListFeature.State(rows: standbyRows)
            confirmedTab = ConfirmedListFeature.State(rows: confirmedRows)
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case standbyTab(StandbyListFeature.Action)
        case confirmedTab(ConfirmedListFeature.Action)
        case standbyFetchAllResponse([StandbyCell.State])
        case confirmedFetchAllResponse([ConfirmedCell.State])
        case makePromiseButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case makePromise
            case confirmedDetail(PromiseDetailViewState)
            case standbyDetail(PromiseDetailViewState)
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

                    let detailState = PromiseDetailViewState(
                        id: UUID(uuidString: String(item.id)) ?? UUID(),
                        title: item.title,
                        theme: item.theme,
                        date: .now,
                        place: item.place,
                        participants: item.participants
                    )
                    return .send(.delegate(.confirmedDetail(detailState)))

                case .showMakePromise:
                    return .send(.delegate(.makePromise))
                }

            case let .standbyTab(.delegate(action)):
                switch action {
                case let .showDetailView(item):
                    let detailState = PromiseDetailViewState(
                        id: UUID(uuidString: String(item.id)) ?? UUID(),
                        title: item.title,
                        theme: "테마",
                        date: .now,
                        place: "강남역",
                        participants: item.members
                    )
                    return .send(.delegate(.standbyDetail(detailState)))

                case .showMakePromise:
                    return .send(.delegate(.makePromise))
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
