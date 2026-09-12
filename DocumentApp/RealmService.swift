//
//  RealmService.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import Foundation
import RealmSwift

final class RealmService {
    private let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func save(quote dto: ChuckNorrisQuoteDTO) {
        do {
            try realm.write {
                let quoteObject = QuoteObject(dto: dto)
                realm.add(quoteObject, update: .modified)
            }
        } catch {
            print("Ошибка сохранения в Realm: \(error)")
        }
    }
    
    func getAllQuotesSortedByDate() -> [QuoteObject] {
        let results = realm.objects(QuoteObject.self).sorted(byKeyPath: "createdAt", ascending: false)
        return Array(results)
    }
    
    func getDownloadedCategories() -> [String] {
        let quotes = realm.objects(QuoteObject.self)
        var categories = Set<String>()
        
        for quote in quotes {
            if quote.categories.isEmpty {
                categories.insert("Без категории")
            } else {
                for category in quote.categories {
                    categories.insert(category)
                }
            }
        }
        return Array(categories).sorted()
    }
    
    func getQuotes(by categoryName: String) -> [QuoteObject] {
        let predicate: NSPredicate
        if categoryName == "Без категории" {
            predicate = NSPredicate(format: "categories.@count == 0")
        } else {
            predicate = NSPredicate(format: "ANY categories == %@", categoryName)
        }
        
        let results = realm.objects(QuoteObject.self)
            .filter(predicate)
            .sorted(byKeyPath: "createdAt", ascending: false)
        return Array(results)
    }
}
