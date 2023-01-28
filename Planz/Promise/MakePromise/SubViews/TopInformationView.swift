//
//  TopInformationView.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct TopInformationView: View {
    var store: Store<MakePromiseState, MakePromiseAction>
    let xmark = "xmark"
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 4) {
                HStack {
                    Spacer().frame(width: 20)
                    HStack {
                        Text("\(viewStore.currentStep.rawValue)")
                            .foregroundColor(Color(hex: "3E414B"))
                        Text("/ 5").foregroundColor(Gray._300.scale)
                    }

                    Spacer()
                    Button(action: { print("@@@ button tapped") }) {
                        Image(systemName: xmark)
                    }
                    Spacer().frame(width: 20)
                }
                HStack {
                    Spacer().frame(width: 20)
                    Text("약속 테마를 선택해 주세요!")
                        .bold()
                    Spacer()
                }
            }
        }
    }
}
