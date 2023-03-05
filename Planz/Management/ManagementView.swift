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
        @BindingState var visibleTab: Tab = .standby
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
    
    enum Action: BindableAction {
        case onAppear
        case standbyTab(StandbyListFeature.Action)
        case confirmedTab(ConfirmedListFeature.Action)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state = .init(standbyRows: .mock, confirmedRows: .mock)
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
    
    init(store: StoreOf<PromiseManagement>) {
        self.store = store
    }
    
    var body: some View {
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
                                action: PromiseManagement.Action.standbyTab)
                            )
                            .tag(Tab.standby)
                            
                            ConfirmedListView(store: store.scope(
                                state: \.confirmedTab,
                                action: PromiseManagement.Action.confirmedTab))
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
}

struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementView(store: StoreOf<PromiseManagement>(
            initialState: PromiseManagement.State(),
            reducer: PromiseManagement()._printChanges()))
    }
}
