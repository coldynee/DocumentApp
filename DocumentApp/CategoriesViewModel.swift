//
//  CategoriesViewModel.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import Foundation
import Combine

final class CategoriesViewModel: ObservableObject {
    @Published var categories: [String] = []
    private let realmService: RealmService
    
    init(realmService: RealmService) {
        self.realmService = realmService
    }
    
    func loadCategories() {
        self.categories = realmService.getDownloadedCategories()
    }
    
    func getQuotes(for category: String) -> [QuoteObject] {
        return realmService.getQuotes(by: category)
    }
}
