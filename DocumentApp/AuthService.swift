//
//  AuthService.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import Foundation
import KeychainSwift

enum AuthError: LocalizedError {
    case emptyPassword
    case passwordTooShort
    case passwordsDontMatch
    case wrongPassword

    var errorDescription: String? {
        switch self {
        case .emptyPassword:      return "Password cant be empty"
        case .passwordTooShort:   return "Password too short"
        case .passwordsDontMatch: return "Passwords not match"
        case .wrongPassword:      return "Wrong password"
        }
    }
}

protocol AuthServiceProtocol {
    func hasSavedPassword() -> Bool
    func savePassword(_ password: String) throws
    func verifyPassword(_ password: String) throws
    func changePassword(from oldPassword: String, to newPassword: String) throws
    func deletePassword()
}

final class AuthService: AuthServiceProtocol {

    private let keychain = KeychainSwift()
    private let passwordKey = "app.user.password"

    func hasSavedPassword() -> Bool {
        keychain.get(passwordKey) != nil
    }

    func savePassword(_ password: String) throws {
        try validate(password: password)
        keychain.set(password, forKey: passwordKey, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }

    func verifyPassword(_ password: String) throws {
        guard let saved = keychain.get(passwordKey) else {
            throw AuthError.wrongPassword
        }
        guard saved == password else {
            throw AuthError.wrongPassword
        }
    }

    func changePassword(from oldPassword: String, to newPassword: String) throws {
        try verifyPassword(oldPassword)
        try validate(password: newPassword)
        keychain.set(newPassword, forKey: passwordKey, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }

    func deletePassword() {
        keychain.delete(passwordKey)
    }

    private func validate(password: String) throws {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw AuthError.emptyPassword }
        guard trimmed.count >= 4 else { throw AuthError.passwordTooShort }
    }
}
