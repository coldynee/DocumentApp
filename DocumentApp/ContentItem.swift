//
//  ContentItem.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import Foundation

enum ContentType {
    case folder
    case file
}

struct ContentItem {
    let name: String
    let type: ContentType
    let url: URL
}
