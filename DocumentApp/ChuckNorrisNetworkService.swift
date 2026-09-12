//
//  ChuckNorrisNetworkService.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badResponse
}

final class ChuckNorrisNetworkService {
    static let shared = ChuckNorrisNetworkService()
    private let baseURL = "https://api.chucknorris.io/jokes"
    
    func fetchRandomQuote() async throws -> ChuckNorrisQuoteDTO {
        guard let url = URL(string: "\(baseURL)/random") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(ChuckNorrisQuoteDTO.self, from: data)
    }
}
