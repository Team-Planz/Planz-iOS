//
//  PromiseBottomButton.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct MakePromiseBottomButton: View {
    var store: Store<MakePromiseState, MakePromiseAction>
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Spacer(minLength: 12)
                
                HStack(spacing:12){
                    if viewStore.shouldShowBackButton {
                        PromiseBackButton(store: store)
                    }
                    PromiseNextButton(store: store)
                        .onTapGesture {
                            viewStore.send(.nextButtonTapped)
                        }
                }
                Spacer(minLength: 12)
            }
        }
        
    }
}

public struct PromiseNextButton: View {
    var store:  Store<MakePromiseState, MakePromiseAction>
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(){
                Spacer()
                Text("다음")
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            .background(viewStore.selectThemeState.selectedType != nil ? Purple._900.scale : Gray._300.scale)
            .clipShape(RoundedRectangle(cornerRadius:16))
        }
    }
}

public struct PromiseBackButton: View {
    var store:  Store<MakePromiseState, MakePromiseAction>
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            Button {
                viewStore.send(.backButtonTapped)
            } label: {
                Image(systemName: "chevron.backward")
                    .foregroundColor(Gray._500.scale)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            .frame(width: 51)
            .background(Gray._200.scale)
            .clipShape(RoundedRectangle(cornerRadius:16))
        }
    }
}
