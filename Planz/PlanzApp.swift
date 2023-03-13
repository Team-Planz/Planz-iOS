//
//  PlanzApp.swift
//  Planz
//
//  Created by junyng on 2022/09/20.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct PlanzApp: App {
    let store: StoreOf<AppCore> = .init(
        initialState: .launchScreen,
        reducer: AppCore()
    )

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
