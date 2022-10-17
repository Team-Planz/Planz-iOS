//
//  PLAlert.swift
//  Planz
//
//  Created by junyng on 2022/10/17.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PLAlertState: Equatable {
    let title: String
    var description: String
    var buttons: [Button]
    
    struct Button: Equatable {
        let action: PLAlertAction
        let title: String
        let style: Style
        
        enum Style {
            case `default`
            case cancel
        }
        
        static func `default`(
            action: PLAlertAction,
            title: String
        ) -> Self {
            Self(action: action, title: title, style: .default)
        }
        
        static func cancel(
            action: PLAlertAction,
            title: String
        ) -> Self {
            Self(action: action, title: title, style: .cancel)
        }
    }
}

struct PLAlert: View {
    let store: Store<PLAlertState, PLAlertAction>
    @ObservedObject var viewStore: ViewStore<PLAlertState, PLAlertAction>
    
    init(store: Store<PLAlertState, PLAlertAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            LazyVStack(spacing: 12) {
                Text(viewStore.title)
                    .font(.system(size: 16))
                    .bold()
                    .foregroundColor(R.color.gray900)
                
                Text(viewStore.description)
                    .font(.system(size: 13))
                    .foregroundColor(R.color.gray900)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.top, 24)
            .padding(.horizontal, 30)
            
            HStack(spacing: 12) {
                ForEach(0..<viewStore.buttons.count, id: \.self) {
                    let button = viewStore.buttons[$0]
                    Button(action: {
                        viewStore.send(button.action)
                    }) {
                        Text(button.title)
                            .font(.system(size: 16))
                            .foregroundColor(button.style == .default
                                             ? R.color.gray100 : R.color.gray700)
                            .frame(maxWidth: .infinity)
                            .frame(height: C.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(button.style == .default
                                          ? R.color.purple900 : R.color.gray200)
                            )
                    }
                }
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .frame(
            width: C.alertSize.width,
            height: C.alertSize.height
        )
    }
}

enum PLAlertAction {
    case confirm
    case cancel
}

extension View {
    @ViewBuilder func alert(
      _ store: Store<PLAlertState?, PLAlertAction>
    ) -> some View {
        ZStack {
            self
            
            IfLetStore(
                store,
                then: { store in
                    Color.black.opacity(0.75).ignoresSafeArea()
                    
                    PLAlert(store: store)
                }
            )
        }
    }
}

fileprivate struct C {
    static let buttonHeight: CGFloat = 51
    static let alertSize: CGSize = .init(width: 280, height: 191)
}

fileprivate struct R {
    struct color {
        static let gray100: Color = .init(red: 243/255, green: 245/255, blue: 248/255)
        static let gray200: Color = .init(red: 205/255, green: 210/255, blue: 217/255)
        static let gray700: Color = .init(red: 106/255, green: 112/255, blue: 122/255)
        static let gray900: Color = .init(red: 2/255, green: 2/255, blue: 2/255)
        static let purple900: Color = .init(red: 102/255, green: 113/255, blue: 246/255)
    }
}

struct TestState: Equatable {
    var alert: PLAlertState?
}

//enum TestAction {
//    case onAppear
//    case showAlertTapped
//    case alert(PLAlertAction)
//}
//
//struct TestView: View {
//    let store: Store<TestState, TestAction>
//    @ObservedObject var viewStore: ViewStore<TestState, TestAction>
//
//    init(store: Store<TestState, TestAction>) {
//        self.store = store
//        self.viewStore = ViewStore(store)
//    }
//
//    var body: some View {
//        Button(action: {
//            viewStore.send(.showAlertTapped)
//        }, label: {
//            Text("Show Alert")
//        })
//            .alert(
//                store.scope(state: \.alert, action: TestAction.alert)
//            )
//    }
//}
//
//let testReducer = Reducer<
//    TestState,
//    TestAction,
//    Void
//> { state, action, _ in
//    switch action {
//    case .onAppear:
//        state.alert = .init(
//            title: "알림",
//            description: "작업한 내용이 저장되지 않고 홈화면으로 이동합니다. 진행하시겠습니까?",
//            buttons: [
//                .cancel(action: .cancel, title: "취소"),
//                .default(action: .confirm, title: "확인")
//            ]
//        )
//        return .none
//    case .showAlertTapped:
//        state.alert = .init(
//            title: "알림",
//            description: "작업한 내용이 저장되지 않고 홈화면으로 이동합니다. 진행하시겠습니까?",
//            buttons: [
//                .cancel(action: .cancel, title: "취소"),
//                .default(action: .confirm, title: "확인")
//            ]
//        )
//        return .none
//    case .alert(.cancel):
//        print("canceled")
//        state.alert = nil
//        return .none
//    default:
//        return .none
//    }
//}
