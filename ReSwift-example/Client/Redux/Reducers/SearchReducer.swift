import Foundation
import ReSwift

func searchReducer(action: Action, state: SearchState?) -> SearchState {
    let prevState = state ?? SearchState()
    var nextState = prevState
    switch action {
    case let action as SearchAction.UpdateGitHubModel:
        nextState.query = action.query
        nextState.page = action.page
        
        if nextState.isFirstPage {
            nextState.models = action.models
        } else {
            nextState.models.append(contentsOf: action.models)
        }
    case is SearchAction.StartLoading:
        nextState.isLoading = true
    case is SearchAction.StopLoading:
        nextState.isLoading = false
        nextState.needsToRefresh = false
    case is SearchAction.Refresh:
        nextState.needsToRefresh = true
    default: break
    }
    return nextState
}
