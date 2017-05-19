import Foundation
import ReSwift

struct SearchState: StateType {
    var isLoading = true
    var query: String?
    var page = 1
    var needsToRefresh = false
    
    var models = [GitHubModel]()
    
    var isFirstPage: Bool {
        return page == 1
    }
}
