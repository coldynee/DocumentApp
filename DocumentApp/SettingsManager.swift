//
//  SettingsManager.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import Foundation

protocol SettingsManagerProtocol {
    var isAscendingSort: Bool { get set }
}

final class SettingsManager: SettingsManagerProtocol {

    private let defaults = UserDefaults.standard
    private let ascendingKey = "settings.sort.ascending"

    var isAscendingSort: Bool {
        get {
            if defaults.object(forKey: ascendingKey) == nil {
                return true
            }
            return defaults.bool(forKey: ascendingKey)
        }
        set {
            defaults.set(newValue, forKey: ascendingKey)

            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
}

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}
