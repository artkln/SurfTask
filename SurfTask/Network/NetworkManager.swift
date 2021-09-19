//
//  NetworkManager.swift
//  SurfTask
//
//  Created by Артём Калинин on 15.09.2021.
//

import Foundation
import Alamofire
import RealmSwift

extension Session {
    static let shared: Session = {
        let configuration = URLSessionConfiguration.default
        let AFSession = Session(configuration: configuration)
        return AFSession
    }()
}

class UserSession {
    static let shared = UserSession()
    private init() {}

    let API: String = "8e6dec04-e7df-490d-b2d1-9caf62c7f3c0"
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    private let URL = "https://content.guardianapis.com/search"

    func getNewsRequest(_ categories: [String], completion: @escaping ([News]?) -> Void) {
        var actualNews = [News]()
        let group = DispatchGroup()

        for category in categories {
            let parameters = [
                "api-key": UserSession.shared.API,
                "format": "json",
                "from-date": "2021-06-01",
                "show-fields": "headline,bodyText,trailText,byline,firstPublicationDate,thumbnail",
                "type": "article",
                "page-size": "100",
                "section": category
            ]

            group.enter()
            Session.shared.request(URL, parameters: parameters).responseData { response in
                guard let data = response.value else { return }

                if let newsResults = try? JSONDecoder().decode(NewsResponse.self, from: data).response {
                    actualNews.append(contentsOf: newsResults.results)
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(actualNews)
        }
    }

    func getNewsRealm() -> Results<News>? {
        var news: Results<News>?

        do {
            let realm = try Realm()
            news = realm.objects(News.self)
           // print(realm.configuration.fileURL)
        } catch let error {
            print(error.localizedDescription)
        }

        return news
    }
}
