import Foundation
import ReSwift

func appReducer() -> Reducer<AppState> {
    return { action, state in
        return AppState(searchState: searchReducer(action: action, state: state?.searchState))
    }
}
