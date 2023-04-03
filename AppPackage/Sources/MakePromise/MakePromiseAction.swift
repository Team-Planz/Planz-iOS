//
//  File.swift
//
//
//  Created by 한상준 on 2023/02/25.
//

import CalendarFeature
import Foundation
import TimeTableFeature

public enum MakePromiseAction: Equatable {
    case dismiss
    case nextButtonTapped
    case backButtonTapped

    case selectTheme(SelectThemeAction)
    case setNameAndPlace(SetNameAndPlaceAction)
    case calendar(CalendarCore.Action)
    case timeSelection(TimeSelection.Action)
    case timeTable(TimeTableAction)
}
