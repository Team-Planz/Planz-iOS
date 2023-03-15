//
//  MakePromiseView.swift
//  Planz
//
//  Created by 한상준 on 2022/12/17.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

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
        WithViewStore(self.store) { viewStore in
            VStack {
                switch viewStore.currentStep {
                case .selectTheme:
                    SelectThemeView(store: self.store.scope(state: \.selectTheme!, action: { .selectTheme($0) }))
                case .setNameAndPlace:
                    NameAndPlaceView()
                case .none:
                    MakePromiseErrorView()
                }
            }
            .frame(alignment: .top)
        }
        .navigationBarBackButtonHidden()
    }
}
