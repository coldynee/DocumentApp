//
//  FileManagerService.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import Foundation
import UIKit

enum FileManagerServiceError: LocalizedError {
    case emptyName
    case imageDataConversionFailed

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Empty name"
        case .imageDataConversionFailed:
            return "Cant wrap image"
        }
    }
}

protocol FileManagerServiceProtocol {
    func contentsOfDirectory(at url: URL) throws -> [ContentItem]
    func createDirectory(named name: String, in directoryURL: URL) throws -> URL
    func createFile(image: UIImage, in directoryURL: URL) throws -> URL
    func removeContent(at url: URL) throws
}

final class FileManagerService: FileManagerServiceProtocol {

    private let fileManager = FileManager.default

    func contentsOfDirectory(at url: URL) throws -> [ContentItem] {
        let urls = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return urls
            .map { itemURL in
                let isDirectory = (try? itemURL
                    .resourceValues(forKeys: [.isDirectoryKey])
                    .isDirectory) ?? false
                return ContentItem(
                    name: itemURL.lastPathComponent,
                    type: isDirectory ? .folder : .file,
                    url: itemURL
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func createDirectory(named name: String, in directoryURL: URL) throws -> URL {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw FileManagerServiceError.emptyName }

        let folderURL = uniqueURL(
            directoryURL.appendingPathComponent(trimmedName, isDirectory: true)
        )
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
        return folderURL
    }

    
    func createFile(image: UIImage, in directoryURL: URL) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw FileManagerServiceError.imageDataConversionFailed
        }

        let fileName = "IMG_\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL = uniqueURL(directoryURL.appendingPathComponent(fileName))
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    func removeContent(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }

    private func uniqueURL(_ url: URL) -> URL {
        guard fileManager.fileExists(atPath: url.path) else { return url }

        let parent = url.deletingLastPathComponent()
        let baseName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        var index = 1
        var candidate = url

        while fileManager.fileExists(atPath: candidate.path) {
            let newName = ext.isEmpty
                ? "\(baseName) \(index)"
                : "\(baseName) \(index).\(ext)"
            candidate = parent.appendingPathComponent(newName)
            index += 1
        }
        return candidate
    }
}
