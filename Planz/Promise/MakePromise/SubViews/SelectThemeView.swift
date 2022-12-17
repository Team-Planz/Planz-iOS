//
//  SelectThemeView.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

public struct SelectThemeView: View {
    var store: Store<SelectThemeState, SelectThemeAction>
    let listItemEdgePadding = EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
    public var body: some View {
            VStack(){
                Spacer()
                SelectThemeItemView(promiseType: .meal, store: store)
                    .padding(listItemEdgePadding)
                SelectThemeItemView(promiseType: .meeting, store: store)
                    .padding(listItemEdgePadding)
                SelectThemeItemView(promiseType: .travel, store: store)
                    .padding(listItemEdgePadding)
                SelectThemeItemView(promiseType: .etc, store: store)
                    .padding(listItemEdgePadding)
                Spacer()
            }
            .background(Color.white)
    }
}

public struct SelectThemeItemView: View {
    var promiseType: PromiseType
    var store: Store<SelectThemeState, SelectThemeAction>
    let itemCornerRadius: CGFloat = 16
    let mainColor = Color(hex:"6671F6")
    let gray100 = Color(hex: "F3F5F8")
    let gray500 = Color(hex:"9CA3AD")
    let checkMarkCircle = "checkmark.circle"
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack{
                Text(promiseType.withEmoji)
                    .foregroundColor(viewStore.selectedType == promiseType ? mainColor : gray500)
                Spacer()
                Image(systemName: checkMarkCircle)
                    .foregroundColor(gray500)
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
            .background(viewStore.selectedType == promiseType ? mainColor.opacity(0.15) : gray100)
            .cornerRadius(itemCornerRadius)
            .overlay(RoundedRectangle(cornerRadius: itemCornerRadius).stroke(mainColor, lineWidth: viewStore.selectedType == promiseType ? 0.7 : 0))
            .onTapGesture {
                    viewStore.send(.promiseTypeListItemTapped(promiseType))
            }
        }
    }
}

public struct NameAndPlaceInputView: View {
    public var body: some View {
        return VStack() {
            Spacer()
            TextFieldWithTitleView(titleText: "약속명(선택)", placeHolderText: "YUMMY")
            TextFieldWithTitleView(titleText: "장소(선택)",placeHolderText: "강남, 온라인 등")
            Spacer()
        }
    }
}
public struct TextFieldWithTitleView: View {
    var titleText: String
    
    @State var textFieldText = ""
    var placeHolderText: String
    
    public var body: some View {
        HStack {
            Spacer(minLength: 20)
            VStack {
                HStack {
                    Text(titleText).bold()
                    Spacer()
                }
                TextField(placeHolderText, text: $textFieldText)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex:"6671F6"), style: StrokeStyle(lineWidth: 1.0)))
                HStack {
                    Spacer()
                    Text("4/10")
                }
                
            }
            Spacer(minLength: 20)
        }
    }
}
