import Foundation
import SwiftyJSON

final class GitHubModel: NSObject {
    let id: Int
    let fullName: String
    let stargazersCount: Int
    
    init?(json: JSON) {
        guard let id = json["id"].int,
            let fullName = json["full_name"].string,
            let stargazersCount = json["stargazers_count"].int else {
            return nil
        }
        
        self.id = id
        self.fullName = fullName
        self.stargazersCount = stargazersCount
    }
}
