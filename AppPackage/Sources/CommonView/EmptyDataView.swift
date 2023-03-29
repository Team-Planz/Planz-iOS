//
//  EmptyDataView.swift
//  Planz
//
//  Created by Sujin Jin on 2023/03/02.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct EmptyDataViewFeature: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        case makePromiseButtonTapped
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case makePromise
        }
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .makePromiseButtonTapped:
                return .send(.delegate(.makePromise))
            case .delegate:
                return .none
            }
        }
    }
}

public struct EmptyDataView: View {
    public let store: StoreOf<EmptyDataViewFeature>
    
    public init(store: StoreOf<EmptyDataViewFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                PDS.Icon.illustEmptydata.image

                VStack(spacing: 4) {
                    Group {
                        Text("약속이 없습니다.")
                        Text("친구들과 약속을 잡아보세요")
                    }
                    .foregroundColor(PDS.COLOR.cGray1.scale)
                }
                .padding(
                    EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
                )

                Button("약속잡기") {
                    // TODO: - 약속잡기 화면 이동
                    viewStore.send(.makePromiseButtonTapped)
                }
                .buttonStyle(RoundCornerButtonStyle())
            }
        }
    }
}

private struct RoundCornerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(PDS.COLOR.purple9.scale)
            .padding(EdgeInsets(top: 11, leading: 33, bottom: 11, trailing: 33))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(PDS.COLOR.purple9.scale, lineWidth: 1)
            )
    }
}

#if DEBUG
    struct ManagementNoDataView_Previews: PreviewProvider {
        static var previews: some View {
            EmptyDataView(store: .init(
                initialState: EmptyDataViewFeature.State(),
                reducer: EmptyDataViewFeature()._printChanges()))
        }
    }
#endif
