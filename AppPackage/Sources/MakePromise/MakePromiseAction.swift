//
//  File.swift
//
//
//  Created by 한상준 on 2023/02/25.
//

import Foundation

public enum MakePromiseAction: Equatable {
    case nextButtonTapped
    case backButtonTapped

    case selectTheme(SelectThemeAction)
    case setNameAndPlace(SetNameAndPlaceAction)
}
