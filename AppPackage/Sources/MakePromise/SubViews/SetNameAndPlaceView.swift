//
//  SetNameAndPlaceView.swift
//  Planz
//
//  Created by 한상준 on 2022/12/18.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

typealias NameAndPlaceView = SetNameAndPlaceView

public struct SetNameAndPlaceView: View {
    private enum TextFieldTexts {
        case promise
        case place

        var title: String {
            switch self {
            case .promise: return "약속명(선택)"
            case .place: return "YUMMY"
            }
        }

        var placeHolder: String {
            switch self {
            case .promise: return "장소(선택)"
            case .place: return "강남, 온라인 등"
            }
        }
    }

    public var body: some View {
        return VStack {
            Spacer()
            TextFieldWithTitleView(
                titleText: TextFieldTexts.promise.title,
                placeHolderText: TextFieldTexts.promise.placeHolder
            )
            TextFieldWithTitleView(
                titleText: TextFieldTexts.place.title,
                placeHolderText: TextFieldTexts.place.placeHolder
            )
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                PDS.COLOR.purple9.scale,
                                style: StrokeStyle(lineWidth: 1.0)
                            )
                    )
                HStack {
                    Spacer()
                    Text("4/10")
                }
            }
            Spacer(minLength: 20)
        }
    }
}
