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
    var store: Store<SetNameAndPlaceState, SetNameAndPlaceAction>

    public enum TextFieldType {
        case name
        case place

        var title: String {
            switch self {
            case .name: return "약속명(선택)"
            case .place: return "장소(선택)"
            }
        }

        var placeHolder: String {
            switch self {
            case .name: return "YUMMY"
            case .place: return "강남, 온라인 등"
            }
        }
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                TextFieldWithTitleView(
                    type: .name, store: self.store
                )
                TextFieldWithTitleView(
                    type: .place, store: self.store
                )
            }
            Spacer()
        }
    }
}

public struct TextFieldWithTitleView: View {
    var type: SetNameAndPlaceView.TextFieldType
    var store: Store<SetNameAndPlaceState, SetNameAndPlaceAction>

    typealias SetNameAndPlaceStore = ViewStore<SetNameAndPlaceState, SetNameAndPlaceAction>
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Spacer(minLength: 20)
                VStack {
                    HStack {
                        Text(type.title).bold()
                        Spacer()
                    }
                    TextField(
                        type.placeHolder,
                        text: viewStore.binding(
                            get: { type == .name ? $0.promiseName : $0.promisePlace },
                            send: { type == .name ? .filledPromiseName($0) : .filledPromisePlace($0) }
                        )
                    )
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                getBorderColor(viewStore, type: type),
                                style: StrokeStyle(lineWidth: 1.0)
                            )
                    )
                    HStack {
                        if type == .name && viewStore.shouldShowNameTextCountWarning {
                            Text("10글자를 초과했습니다")
                                .foregroundColor(PDS.COLOR.scarlet1.scale)
                        } else if type == .place && viewStore.shouldShowPlaceTextCountWarning {
                            Text("10글자를 초과했습니다")
                                .foregroundColor(PDS.COLOR.scarlet1.scale)
                        }

                        Spacer()
                        Text("\(type == .name ? viewStore.nameTextDisplayCount : viewStore.placeTextDisplayCount)/\(viewStore.maxCharacter)")
                            .foregroundColor(getTextCountColor(viewStore, type: type))
                    }
                }
                Spacer(minLength: 20)
            }
        }
    }

    func getBorderColor(_ viewStore: SetNameAndPlaceStore, type: SetNameAndPlaceView.TextFieldType) -> Color {
        if type == .name {
            return viewStore.shouldShowNameTextCountWarning ? PDS.COLOR.scarlet1.scale :
                PDS.COLOR.purple9.scale
        } else {
            return viewStore.shouldShowPlaceTextCountWarning ? PDS.COLOR.scarlet1.scale :
                PDS.COLOR.purple9.scale
        }
    }

    func getTextCountColor(_ viewStore: SetNameAndPlaceStore, type: SetNameAndPlaceView.TextFieldType) -> Color {
        if type == .name {
            return viewStore.shouldShowNameTextCountWarning ? PDS.COLOR.scarlet1.scale :
                PDS.COLOR.gray4.scale
        } else {
            return viewStore.shouldShowPlaceTextCountWarning ? PDS.COLOR.scarlet1.scale :
                PDS.COLOR.gray4.scale
        }
    }
}
