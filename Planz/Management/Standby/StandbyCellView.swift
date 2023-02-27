//
//  StandbyCellView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/27.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct StandbyCellView: View {
    
    @Binding var item: StandbyModel
    
    var body: some View {
        Group {
            HStack {
                VStack {
                    ManagementTitleCellView(
                        title: item.title,
                        role: item.role
                    )
                    
                    HStack {
                        Text(item.leaderName)
                        Rectangle()
                            .frame(width: 1, height: 12)
                        Text("\(item.replyPeopleCount)명 응답완료")
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Image(systemName: "chevron.forward")
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
            }
            .border(.gray)
            .padding()
            .background(.gray.opacity(0.2))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
struct StandbyCellView_Previews: PreviewProvider {
    static var previews: some View {
        StandbyCellView(item:
                .constant(
                    .init(
                    title: "가나다라마바사아자차카파타하이",
                    role: .general,
                    leaderName: "LeaderName",
                    replyPeopleCount: 5)
                )
        )
    }
}
