//
//  ThemeSelectionView.swift
//  Planz
//
//  Created by 한상준 on 2022/10/08.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI

public struct ThemeSelectionView: View {
    let listItemEdgePadding = EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
    public var body: some View {
        return VStack(){
            Spacer()
            ListItemView(promiseType: .constant(.meal))
                .padding(listItemEdgePadding)
            ListItemView(promiseType: .constant(.meeting))
                .padding(listItemEdgePadding)
            ListItemView(promiseType: .constant(.travel))
                .padding(listItemEdgePadding)
            ListItemView(promiseType: .constant(.etc))
                .padding(listItemEdgePadding)
            Spacer()
        }
        .background(Color.white)
    }
}

public struct ListItemView: View {
    @Binding var promiseType: PromiseType
    public var body: some View {
        HStack{
            Text(promiseType.rawValue)
                .foregroundColor(Color(hex:"9CA3AD"))
            Spacer()
            Image(systemName: "checkmark.circle")
                .foregroundColor(Color(hex:"9CA3AD"))
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
        .background(Color(hex: "F3F5F8")).clipShape(RoundedRectangle(cornerRadius:16))
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
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
