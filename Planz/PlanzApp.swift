//
//  PlanzApp.swift
//  Planz
//
//  Created by junyng on 2022/09/20.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import MakePromise
import SwiftUI
@main
struct PlanzApp: App {
    var body: some Scene {
        WindowGroup {
            MakePromiseView(
                store: .init(
                    initialState: .init(),
                    reducer: makePromiseReducer,
                    environment: .init()
                )
            )
        }
    }
}
