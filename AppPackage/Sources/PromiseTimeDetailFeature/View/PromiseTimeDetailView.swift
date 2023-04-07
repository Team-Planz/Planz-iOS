//
//  File.swift
//
//
//  Created by 한상준 on 2023/04/07.
//
import ComposableArchitecture
import DesignSystem
import SwiftUI
import TimeTableFeature

public struct PromiseTimeDetailView: View {
    // TODO: PTDStore에서 갖고있도록 수정 필요
    let timeTableStore: Store<TimeTableState, TimeTableAction> = .init(initialState: .mock, reducer: timeTableReducer, environment: ())

    let store: StoreOf<PromiseTimeDetailFeature>

    public init(store: StoreOf<PromiseTimeDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack {
                    ZStack {
                        VStack {
                            PromiseInformationView()
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 12))
                            TimeTableView(store: timeTableStore)
                        }
                        VStack(alignment: .leading) {
                            Spacer()

                            if viewStore.showAttedeeModal == false {
                                ResponseModalView(title: "런치런치", attendee: "손흥민, 이강인, 오인규, 조규성")
                                    .animation(.easeOut)
                                    .transition(.move(edge: .bottom))
                                    .shadow(radius: 10, x: 0, y: 0)
                                    .mask(Rectangle().padding(.top, -20))
                            }
                        }
                        .padding(.bottom, -40)
                    }.background(Color.white)
                }
                .navigationTitle("약속명").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button(action: {
                        viewStore.send(.profileIconTapped)
                    }) {
                        PDS.Icon.face.image
                    }
                    Button(action: {
                        viewStore.send(.shareTapped)
                    }) {
                        PDS.Icon.iosShare.image
                    }
                }
            }
        }
    }
}
