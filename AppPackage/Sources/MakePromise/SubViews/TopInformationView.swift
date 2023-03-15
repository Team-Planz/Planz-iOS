//
//  TopInformationView.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct TopInformationView: View {
    var store: Store<MakePromiseState, MakePromiseAction>
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 4) {
                HStack {
                    Spacer().frame(width: 20)
                    HStack {
                        Text("\(viewStore.index + 1)")
                            .foregroundColor(PDS.COLOR.gray8.scale)
                        Text("/ \(viewStore.steps.count)").foregroundColor(PDS.COLOR.gray3.scale)
                    }

                    Spacer()
                    Button(action: {
                        viewStore.send(.dismiss)
                    }) {
                        Image(systemName: PlanzText.xmark.rawValue)
                    }
                    Spacer().frame(width: 20)
                }
                HStack {
                    Spacer().frame(width: 20)
                    Text(PlanzText.themeSelectTitle.rawValue)
                        .bold()
                    Spacer()
                }
            }
        }
    }

    // TODO: (Andrew) 모듈화 필요
    enum PlanzText: String {
        case xmark
        case themeSelectTitle = "약속 테마를 선택해 주세요!"
    }
}
