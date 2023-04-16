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
    var store: StoreOf<MakePromise>
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
                            .renderingMode(.template)
                            .foregroundColor(PDS.COLOR.gray6.scale)
                    }
                    Spacer().frame(width: 20)
                }
                HStack {
                    Spacer().frame(width: 20)
                    if let title = viewStore.currentStep?.title {
                        Text(title)
                            .bold()
                    }
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

private extension MakePromise.State.Step {
    var title: String {
        switch self {
        case .selectTheme:
            return "약속 테마를 선택해 주세요!"
        case .setNameAndPlace:
            return "약속명과 장소를 입력해주세요!"
        case .calendar:
            return "제안할 약속 날짜를 선택해주세요!"
        case .timeSelection:
            return "제안할 약속 시간대를 선택해주세요!"
        case .timeTable:
            return "가능한 시간을 선택해주세요!"
        }
    }
}
