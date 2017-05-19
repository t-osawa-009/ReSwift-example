import Foundation
import ReSwift
import Alamofire

struct SearchAction {
    struct UpdateGitHubModel: Action {
        let models: [GitHubModel]
        let query: String
        let page: Int
    }
    struct Refresh: Action {}
    
    struct StartLoading: Action {}
    
    struct StopLoading: Action {}
    
    struct Creator {
        static func fetchSearch(query: String, page: Int) -> Store<AppState>.AsyncActionCreator {
            return {state, store, callback in
                store.dispatch(SearchAction.StartLoading())
                APIClient.send(query: query, page: page, completion: { (models) in
                    store.dispatch(SearchAction.StopLoading())
                    callback {_, _ in UpdateGitHubModel(models: models, query: query, page: page)}
                })
            }
        }
    }
}
