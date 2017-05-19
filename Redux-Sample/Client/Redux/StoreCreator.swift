import Foundation
import ReSwift

let loggingMiddleware: Middleware<AppState> = { dispatch, fetchState in
    return { next in
        return { action in
            let type = Mirror(reflecting: action).subjectType
            print(String(describing: type))
            // call next middleware
            return next(action)
        }
    }
}

let store = Store<AppState>(reducer: appReducer(), state: AppState(), middleware: [loggingMiddleware])
