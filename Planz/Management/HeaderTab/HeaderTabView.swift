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
    
    let tabs: [Tab]
    @Binding var activeTab: Tab
    
    init(
        activeTab: Binding<Tab>,
        tabs: [Tab],
        fullWidth: CGFloat
    ) {
        self.tabs = tabs
        self._activeTab = activeTab
        self.buttonWidth = (fullWidth-spacing)/CGFloat(tabs.count)
        self.barWidth = buttonWidth
        self.buttonLeadings = [0, barWidth+spacing]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: spacing) {
                
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        activeTab = tab
                        withAnimation {
                            barX = buttonLeadings[tab.rawValue]
                        }
                    } label: {
                        Text(tab.title)
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
        .onChange(of: activeTab) { selectedTab in
            withAnimation {
                barX = buttonLeadings[selectedTab.rawValue]
            }
        }
    }
}

struct HeaderTabView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabView(
            activeTab: .constant(Tab.standby),
            tabs: Tab.allCases,
            fullWidth: 400)
        .padding(.horizontal)
    }
}
