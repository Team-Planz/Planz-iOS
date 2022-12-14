//
//  MakePromiseStore.swift
//  Planz
//
//  Created by 한상준 on 2022/12/14.
//  Copyright © 2022 Team-Planz. All rights reserved.
//

import Foundation
import ComposableArchitecture

enum MakePromiseStep: Int, Comparable {
    case error = 0
    case selectTheme = 1
    case fillNAndPlace
    
    static func < (lhs: MakePromiseStep, rhs: MakePromiseStep) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
public struct MakePromiseState: Equatable {
    var shouldShowBackButton = false
    var currentStep: MakePromiseStep = .selectTheme
    var selectedTheme: PromiseType? = nil
}

public enum MakePromiseAction: Equatable {
    case nextButtonTapped
    case backButtonTapped
    
}

public struct MakePromiseEnvironment {
    
}

typealias Step = MakePromiseStep


public let makePromiseReducer = Reducer<MakePromiseState, MakePromiseAction, MakePromiseEnvironment> { state, action, enviroment in
    switch action {
    case .nextButtonTapped:
        state.currentStep = Step(rawValue: state.currentStep.rawValue + 1) ?? .error
        state.shouldShowBackButton = state.currentStep > Step.selectTheme
        return .none
        
    case .backButtonTapped:
        var step = state.currentStep
        var initialStep = Step.selectTheme
        state.currentStep =  step > initialStep ? Step(rawValue:step.rawValue - 1) ?? initialStep : initialStep
        state.shouldShowBackButton = state.currentStep > initialStep
        return .none
    }
}



