//
//  Tab.swift
//  Planz
//
//  Created by Sujin Jin on 2023/03/02.
//  Copyright © 2023 Team-Planz. All rights reserved.
//

import Foundation

enum Tab: Int, CaseIterable {
    case standby = 0
    case confirmed
    
    var title: String {
        switch self {
        case .standby:
            return "대기중인 약속"
        case .confirmed:
            return "확정된 약속"
        }
    }
}
