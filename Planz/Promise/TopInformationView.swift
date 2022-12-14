//
//  TopInformationView.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI
public struct TopInformationView: View {
    public var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 20)
                Text("1/5")
                Spacer()
                Text("버튼")
                Spacer().frame(width: 20)
            }
            Text("약속 테마를 선택해 주세요!")
                .bold()
        }
    }
}
struct AppView_Previews2: PreviewProvider {
    static var previews: some View {
        TopInformationView()
    }
}
