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
    let store: Store<MakePromiseState, MakePromiseAction>

    public var body: some View {
        VStack {
            TopInformationView(store: store)
            PromiseContentView(store: store)
            Spacer()
            MakePromiseBottomButton(store: store)
            Spacer(minLength: 12)
        }
    }

    public init(store: Store<MakePromiseState, MakePromiseAction>) {
        self.store = store
    }
}

struct PromiseContentView: View {
    var store: Store<MakePromiseState, MakePromiseAction>
    public var body: some View {
        IfLetStore(store.scope(state: \.currentStep)) { store in
            SwitchStore(store) {
                CaseLet(
                    state: /MakePromiseState.Step.selectTheme,
                    action: MakePromiseAction.selectTheme,
                    then: SelectThemeView.init
                )
                CaseLet(
                    state: /MakePromiseState.Step.setNameAndPlace,
                    action: MakePromiseAction.setNameAndPlace,
                    then: NameAndPlaceView.init
                )
                CaseLet(
                    state: /MakePromiseState.Step.timeSelection,
                    action: MakePromiseAction.timeSelection,
                    then: TimeSelectionView.init
                )
                CaseLet(
                    state: /MakePromiseState.Step.calendar,
                    action: MakePromiseAction.calendar,
                    then: {
                        CalendarView(
                            type: .promise,
                            store: $0
                        )
                    }
                )
                CaseLet(
                    state: /MakePromiseState.Step.timeTable,
                    action: MakePromiseAction.timeTable,
                    then: TimeTableView.init
                )
            }
        }
        .frame(alignment: .top)
        .navigationBarBackButtonHidden()
    }
}
