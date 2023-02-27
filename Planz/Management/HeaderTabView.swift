//
//  HeaderTabView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/02/25.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import SwiftUI

struct HeaderTabView: View {
    private let spacing: CGFloat = 60
    private let buttonLeadings: [CGFloat]
    private let barWidth: CGFloat
    private let buttonWidth: CGFloat
    @State private var barX: CGFloat = 0
    
    let menus: [String]
    @Binding var activeIndex: Int
    
    init(
        activeIndex: Binding<Int>,
        menus: [String],
        fullWidth: CGFloat
    ) {
        self.menus = menus
        self._activeIndex = activeIndex
        self.buttonWidth = (fullWidth-spacing)/CGFloat(menus.count)
        self.barWidth = buttonWidth
        self.buttonLeadings = [0, barWidth+spacing]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: spacing) {
                ForEach(0..<menus.count, id: \.self) { row in
                    Button {
                        activeIndex = row
                        withAnimation {
                            barX = buttonLeadings[row]
                        }
                    } label: {
                        Text(menus[row])
                            .frame(width: buttonWidth)
                            .foregroundColor(.black)
                            .bold()
                    }
                }
            }
            
            Rectangle()
                .frame(width: barWidth, height: 2)
                .alignmentGuide(.leading) { $0[.leading] }
                .offset(.init(width: barX, height: 0))
        }
        .onChange(of: activeIndex) { selectedRow in
            withAnimation {
                barX = buttonLeadings[selectedRow]
            }
        }
    }
}

struct HeaderTabView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabView(
            activeIndex: .constant(0),
            menus: ["AA", "BB"],
            fullWidth: 400)
        .padding(.horizontal)
    }
}
