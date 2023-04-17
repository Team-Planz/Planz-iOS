//
//  ManagePromiseView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import CommonView
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ManagePromiseView: View {
    private let store: StoreOf<ManagePromiseCore>

    public init(store: StoreOf<ManagePromiseCore>) {
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
                                action: ManagePromiseCore.Action.standbyTab
                            )
                            )
                            .tag(Tab.standby)

                            ConfirmedListView(store: store.scope(
                                state: \.confirmedTab,
                                action: ManagePromiseCore.Action.confirmedTab
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
                }
            }
        }
    }
}

struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagePromiseView(store: StoreOf<ManagePromiseCore>(
            initialState: ManagePromiseCore.State(
                standbyRows: .mock,
                confirmedRows: .mock
            ),
            reducer: ManagePromiseCore()._printChanges()
        ))
    }
}
