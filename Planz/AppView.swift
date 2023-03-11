//
//  AppView.swift
//  Planz
//
//  Created by junyng on 2022/09/20.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import CalendarFeature
import ComposableArchitecture
import HomeContainerFeature
import SwiftUI

struct AppView: View {
    var body: some View {
        ZStack {
            CalendarView(type: .home, store: .init(initialState: .init(), reducer: CalendarCore(type: .home)))
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
