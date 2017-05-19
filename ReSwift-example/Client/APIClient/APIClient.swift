import Foundation
import Alamofire
import SwiftyJSON
import WebLinking

final class APIClient {
    private init() {}
    static let baseURLString = "https://api.github.com"
    class func send(query: String, page: Int, completion: @escaping ([GitHubModel]) -> Void) {
        Alamofire.request(baseURLString + "/search/repositories", parameters: ["q": query, "page": page]).responseJSON { response in
            let json = JSON(response.result.value as Any)
            completion(json["items"].flatMap({ (_, data) -> GitHubModel? in
                return GitHubModel(json: data)
            })
            )
        }
    }
}
