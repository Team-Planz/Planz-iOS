//
//  APIRoute.swift
//
//
//  Created by junyng on 2023/02/13.
//

import Entity
import Foundation

/// A structure for representing API routes
public enum APIRoute {
    case user(User)
    case promising(Promising)
    case promise(Promise)

    public enum User {
        case signup
        case resign
        case updateName(UpdateUsernameRequest)
        case fetchInfo
    }

    public enum Promising {
        case create(CreatePromisingRequest)
        case fetchSession(String)
        case respondTimeByHost(String, PromisingTime)
        case respondTimeByGuest(String, PromisingTime)
        case reject(String)
        case confirm(String, ConfirmPromisingRequest)
        case fetch(Int)
        case fetchStatus(Int)
        case fetchAll
        case fetchTimeTable(Int)
        case fetchCategories
        case randomName(Int)
    }

    public enum Promise {
        case fetchAll(Query)
        case fetch(id: Int)

        public enum Query {
            case user
            case month(String)
            case date(String)
            case today
        }
    }
}
