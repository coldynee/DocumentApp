//
//  AllQuotesViewModel.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import Foundation
import Combine

final class AllQuotesViewModel: ObservableObject {
    @Published var quotes: [QuoteObject] = []
    
    private let realmService: RealmService
    
    init(realmService: RealmService) {
        self.realmService = realmService
    }
    
    func loadQuotes() {
        self.quotes = realmService.getAllQuotesSortedByDate()
    }
}
