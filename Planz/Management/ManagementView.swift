//
//  ManagementView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PromiseManagement: ReducerProtocol {
    struct State: Equatable {
        var visibleViewType: ManagementView.ViewType = .standby
        var confirmedTab = ConfirmedListFeature.State()
        var standbyTab = StandbyListFeature.State()
        
        init(
            standbyRows: IdentifiedArrayOf<StandbyCell.State> = [],
            confirmedRows: IdentifiedArrayOf<ConfirmedCell.State> = []
        ) {
            standbyTab = StandbyListFeature.State(rows: standbyRows)
            confirmedTab = ConfirmedListFeature.State(rows: confirmedRows)
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case selectedIndexChanged(Int)
        case standbyTab(StandbyListFeature.Action)
        case confirmedTab(ConfirmedListFeature.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state = .init(standbyRows: .mock, confirmedRows: .mock)
                return .none
                
            case let .selectedIndexChanged(index):
                state.visibleViewType = ManagementView.ViewType(rawValue: index) ?? .standby
                return .none
                
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

struct ManagementView: View {
    
    private let store: StoreOf<PromiseManagement>
    @ObservedObject var viewStore: ViewStore<ViewState, PromiseManagement.Action>
    
    init(store: StoreOf<PromiseManagement>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }
    
    struct ViewState: Equatable {
        let visibleViewType: ViewType
        let menuTitle: String
        let menus: [String]
        
        init(state: PromiseManagement.State) {
            self.visibleViewType = state.visibleViewType
            self.menuTitle = state.visibleViewType.title
            self.menus = ViewType.allCases.map({ $0.title })
        }
    }
    
    enum ViewType: Int, CaseIterable {
        case standby
        case confirmed
        
        var title: String {
            switch self {
            case .standby:
                return "대기중인 약속"
            case .confirmed:
                return "확정된 약속"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    HeaderTabView(
                        activeIndex: viewStore.binding(
                            get: \.visibleViewType.rawValue,
                            send: PromiseManagement.Action.selectedIndexChanged),
                        menus: viewStore.menus,
                        fullWidth: geo.size.width - 40
                    )
                    
                    TabView(selection: viewStore.binding(
                        get: \.visibleViewType.rawValue,
                        send: PromiseManagement.Action.selectedIndexChanged)
                    ) {
                        StandbyListView(store: self.store.scope(
                            state: \.standbyTab,
                            action: PromiseManagement.Action.standbyTab)
                        )
                        .tag(ViewType.standby.rawValue)
                        
                        ConfirmedListView(store: store.scope(
                            state: \.confirmedTab,
                            action: PromiseManagement.Action.confirmedTab))
                        .tag(ViewType.confirmed.rawValue)
                    }
                    .animation(.default, value: viewStore.visibleViewType.rawValue)
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
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                        }
                    }
                }
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }
}

struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementView(store: StoreOf<PromiseManagement>(
            initialState: PromiseManagement.State(),
            reducer: PromiseManagement()._printChanges()))
    }
}
