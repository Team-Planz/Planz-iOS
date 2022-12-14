//
//  AppView.swift
//  Planz
//
//  Created by junyng on 2022/09/20.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import SwiftUI
import Then
import ComposableArchitecture

enum PromiseType: String, CaseIterable{
    case meal = "식사 약속"
    case meeting = "미팅 약속"
    case travel = "여행 약속"
    case etc = "기타 약속"
    
    var withEmoji : String {
        switch self {
        case .meal: return self.rawValue + ""
        case .meeting: return self.rawValue + ""
        case .travel: return self.rawValue + ""
        case .etc: return self.rawValue + ""
        }
    }
}


struct AppView: View {
    let store: Store<MakePromiseState, MakePromiseAction> = Store(initialState: MakePromiseState(), reducer: makePromiseReducer, environment: MakePromiseEnvironment())
    
    @State private var tabSelection = 1
    @State private var promiseStep: PromiseStep = .selectTheme
    var body: some View {
        VStack {
            TopInformationView()
            PromiseContentView(promiseStep: $promiseStep)
            Spacer()
            PromiseBottomButton(store: store)
            Spacer(minLength: 12)
        }
    }
}
struct PromiseContentView: View {
    @Binding var promiseStep: PromiseStep
    public var body: some View {
        HStack {
            switch promiseStep {
            case .selectTheme:
                ThemeSelectionView()
            case .fillNAndPlace:
                NameAndPlaceInputView()
            }
        }
        
    }
}

struct FirstView: View {
    @Binding var tabSelection: Int
    var body: some View {
        Button(action: {
            self.tabSelection = 2
        }) {
            Text("Change to tab 2")
        }
    }
}

enum PromiseStep: Int {
    case selectTheme = 1
    case fillNAndPlace
}

struct MakePromiseState: Equatable {
    var currentMakingPromiseStep:Int = 1
    var shouldShowBackButton = false
}

enum MakePromiseAction: Equatable {
    case nextButtonTapped
    case backButtonTapped
    
}

struct MakePromiseEnvironment {
    
}

let makePromiseReducer = Reducer<MakePromiseState, MakePromiseAction, MakePromiseEnvironment> { state, action, enviroment in
    switch action {
    case .nextButtonTapped:
        state.currentMakingPromiseStep += 1
        state.shouldShowBackButton = state.currentMakingPromiseStep > PromiseStep.selectTheme.rawValue
        print("@@@ shouldShowBackButton is \(state.shouldShowBackButton)")
        print("@@@ currentMakingPromiseStep is \(state.currentMakingPromiseStep)")
        return .none
    case .backButtonTapped:
        var step = state.currentMakingPromiseStep
        var initialStep = PromiseStep.selectTheme.rawValue
        state.currentMakingPromiseStep = step > initialStep ? step - 1 : initialStep
        state.shouldShowBackButton = state.currentMakingPromiseStep > initialStep
        print("@@@ shouldShowBackButton is \(state.shouldShowBackButton)")
        print("@@@ currentMakingPromiseStep is \(state.currentMakingPromiseStep)")
        return .none
    }
}



