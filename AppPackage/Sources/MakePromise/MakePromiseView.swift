//
//  MakePromiseView.swift
//  Planz
//
//  Created by 한상준 on 2022/12/17.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import CalendarFeature
import ComposableArchitecture
import DesignSystem
import SwiftUI
import TimeTableFeature

public struct MakePromiseView: View {
    let store: StoreOf<MakePromise>

    public var body: some View {
        VStack {
            TopInformationView(store: store)
            PromiseContentView(store: store)
            Spacer()
            MakePromiseBottomButton(store: store)
            Spacer(minLength: 12)
        }
    }

    public init(store: StoreOf<MakePromise>) {
        self.store = store
    }
}

struct PromiseContentView: View {
    var store: StoreOf<MakePromise>
    public var body: some View {
        IfLetStore(store.scope(state: \.currentStep)) { store in
            SwitchStore(store) {
                CaseLet(
                    state: /MakePromise.State.Step.selectTheme,
                    action: MakePromise.Action.selectTheme,
                    then: SelectThemeView.init
                )
                CaseLet(
                    state: /MakePromise.State.Step.setNameAndPlace,
                    action: MakePromise.Action.setNameAndPlace,
                    then: NameAndPlaceView.init
                )
                CaseLet(
                    state: /MakePromise.State.Step.timeSelection,
                    action: MakePromise.Action.timeSelection,
                    then: TimeSelectionView.init
                )
                CaseLet(
                    state: /MakePromise.State.Step.calendar,
                    action: MakePromise.Action.calendar,
                    then: {
                        CalendarView(
                            type: .promise,
                            store: $0
                        )
                    }
                )
                CaseLet(
                    state: /MakePromise.State.Step.timeTable,
                    action: MakePromise.Action.timeTable,
                    then: TimeTableView.init
                )
            }
        }
        .frame(alignment: .top)
        .navigationBarBackButtonHidden()
    }
}
