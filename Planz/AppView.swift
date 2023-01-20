//
//  AppView.swift
//  Planz
//
//  Created by junyng on 2022/09/20.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        TimePromiseView(
            store: .init(
                initialState: .init(
                    startDate: .zeroAM ?? .now,
                    endDate: .twelvePM ?? .now
                ),
                reducer: TimePromise()
            )
        )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}

private extension Date {
    static var zeroAM: Self? {
        Calendar.current.date(
            bySettingHour: 0,
            minute: .zero,
            second: .zero,
            of: .now
        )
    }

    static var twelvePM: Self? {
        Calendar.current.date(
            bySettingHour: 24,
            minute: .zero,
            second: .zero,
            of: .now
        )
    }
}
