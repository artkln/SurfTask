//
//  News.swift
//  SurfTask
//
//  Created by Артём Калинин on 14.09.2021.
//

import UIKit
import RealmSwift

class NewsResponse: Decodable {
    let response: NewsResults
}

class NewsResults: Decodable {
    let results: [News]
}

class News: Object, Decodable {
    @objc dynamic var sectionId: String?
    @objc dynamic var headline: String?
    @objc dynamic var trailText: String?
    @objc dynamic var thumbnail: String?
    @objc dynamic var author: String?
    @objc dynamic var date: String?
    @objc dynamic var bodyText: String?

    enum CodingKeys: String, CodingKey {
        case sectionId
        case fields
    }

    enum FieldsKeys: String, CodingKey {
        case headline
        case trailText
        case thumbnail
        case author = "byline"
        case date = "firstPublicationDate"
        case bodyText
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        if let mainValues = try? decoder.container(keyedBy: CodingKeys.self) {

            self.sectionId = try? mainValues.decode(String.self, forKey: .sectionId)

            if let fieldsValues = try? mainValues
                .nestedContainer(keyedBy: FieldsKeys.self, forKey: .fields) {

                self.headline = try? fieldsValues.decode(String.self, forKey: .headline)
                self.trailText = try? fieldsValues.decode(String.self, forKey: .trailText)
                self.thumbnail = try? fieldsValues.decode(String.self, forKey: .thumbnail)

                if let authorName = try? fieldsValues.decode(String.self, forKey: .author) {
                    self.author = "by " + authorName
                }

                if let stringDate = try? fieldsValues.decode(String.self, forKey: .date) {
                    self.date = stringDate.replacingOccurrences(of: "T", with: " ")
                        .replacingOccurrences(of: "Z", with: "")
                }

                if let text = try? fieldsValues.decode(String.self, forKey: .bodyText) {
                    self.bodyText = "      " + text
                }
            }
        }
    }
}

extension News {
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? News {
            return self.sectionId == object.sectionId && self.headline == object.headline
                && self.trailText == object.trailText && self.thumbnail == object.thumbnail
                && self.author == object.author && self.date == object.date
                && self.bodyText == object.bodyText
        } else {
            return false
        }
    }
}
