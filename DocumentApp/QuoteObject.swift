//
//  QuoteObject.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import Foundation
import RealmSwift

struct ChuckNorrisQuoteDTO: Codable {
    let id: String
    let value: String
    let created_at: String
    let categories: [String]
    
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: created_at) ?? Date()
    }
}

final class QuoteObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var text: String
    @Persisted var createdAt: Date
    @Persisted var categories: List<String>
    
    var displayCategory: String {
        return categories.first ?? "Без категории"
    }
    
    convenience init(dto: ChuckNorrisQuoteDTO) {
        self.init()
        self.id = dto.id
        self.text = dto.value
        self.createdAt = dto.date
        self.categories.append(objectsIn: dto.categories)
    }
}
