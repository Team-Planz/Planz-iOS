//
//  MakePromiseView.swift
//  Planz
//
//  Created by 한상준 on 2022/12/17.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import Then

struct MakePromiseView: View {
    let store: Store<MakePromiseState, MakePromiseAction> = Store(initialState: MakePromiseState(), reducer: makePromiseReducer, environment: MakePromiseEnvironment())

    @State private var tabSelection = 1
    @State private var promiseStep: MakePromiseStep = .selectTheme
    var body: some View {
        VStack {
            TopInformationView(store: store)
            PromiseContentView(store: store)
            Spacer()
            MakePromiseBottomButton(store: store)
            Spacer(minLength: 12)
        }
    }
}

struct PromiseContentView: View {
    var store: Store<MakePromiseState, MakePromiseAction>

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                switch viewStore.currentStep {
                case .selectTheme:
                    SelectThemeView(store: self.store.scope(state: \.selectThemeState, action: { .selectTheme($0) }))
                case .fillNAndPlace:
                    NameAndPlaceView()
                case .error:
                    MakePromiseErrorView()
                    Spacer()
                }
            }
        }
    }
}