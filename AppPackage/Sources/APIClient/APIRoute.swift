//
//  APIRoute.swift
//
//
//  Created by junyng on 2023/02/13.
//

import Foundation

/// A structure for representing API routes
public enum APIRoute {
    case user(User)
    case promising(Promising)
    case promise(Promise)

    public enum User {
        case signup(SharedModels.User)
        case resign
        case updateName(SharedModels.UpdateUsernameRequest)
        case fetchInfo
    }

    public enum Promising {
        case create(SharedModels.CreatePromisingRequest)
        case fetchSession(String)
        case respondTimeByHost(String, SharedModels.PromisingTime)
        case respondTimeByGuest(String, SharedModels.PromisingTime)
        case reject(String)
        case confirm(String, SharedModels.ConfirmPromisingRequest)
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
