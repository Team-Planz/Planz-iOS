//
//  AppView.swift
//  Planz
//
//  Created by junyng on 2022/09/20.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI
import Then
import ComposableArchitecture

struct AppView: View {
    let store: Store<MakePromiseState, MakePromiseAction> = Store(initialState: MakePromiseState(), reducer: makePromiseReducer, environment: MakePromiseEnvironment())
    
    @State private var tabSelection = 1
    @State private var promiseStep: MakePromiseStep = .selectTheme
    var body: some View {
        VStack {
            TopInformationView()
            PromiseContentView(store: store)
            Spacer()
            MakePromiseBottomButton(store: store)
            Spacer(minLength: 12)
        }
    }
}
struct PromiseContentView: View {
    var store: Store<MakePromiseState, MakePromiseAction>
    let selectThemeStore: Store<SelectThemeState, SelectThemeAction> = Store(initialState: SelectThemeState(), reducer: makePromiseSelectThemeReducer, environment: SelectThemeEnvironment())
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                switch viewStore.currentStep {
                case .selectTheme:
                    SelectThemeView(store: selectThemeStore)
                case .fillNAndPlace:
                    NameAndPlaceInputView()
                case .error:
                    Spacer()
                }
            }
        }
    }
}
