//
//  RandomQuoteViewModel.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import Foundation
import Combine

final class RandomQuoteViewModel: ObservableObject {
    @Published var quoteText: String = "Нажмите кнопку для загрузки"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let realmService: RealmService
    private let networkService: ChuckNorrisNetworkService
    
    init(realmService: RealmService, networkService: ChuckNorrisNetworkService) {
        self.realmService = realmService
        self.networkService = networkService
    }
    
    func loadAndSaveQuote() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let dto = try await networkService.fetchRandomQuote()
                realmService.save(quote: dto)
                
                self.quoteText = dto.value
                self.isLoading = false
            } catch {
                self.errorMessage = "Ошибка: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
