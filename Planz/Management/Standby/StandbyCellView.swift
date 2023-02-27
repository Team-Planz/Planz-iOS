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
            VStack {
                HStack {
                    Text(item.title)
                        .font(.title3)
                        .bold()
                        .border(.orange)
                    RoleMarkView(role: item.role)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(.black)
                
                HStack {
                    Text(item.leaderName)
                    Text("\(item.replyPeopleCount)명 응답완료")
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                .constant(.init(title: "Title-1", role: .general, leaderName: "LeaderName", replyPeopleCount: 5))
        )
    }
}
