//
//  KeychainHelper.swift
//  Sporty Test
//
//  Created by Boris Georgiev on 16.01.26.
//


import Foundation
import Security

enum KeychainError: Error {
    case unexpectedData
    case unhandledError(status: OSStatus)
}


// Helper was generated with AI
final class KeychainHelper {
    
    enum Keys {
        static let authToken = "authToken"
    }
    
    static let shared = KeychainHelper()
    private let service = Bundle.main.bundleIdentifier ?? "com.myapp.keys"
    
    private init() {}

    func set(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete first to ensure we can update the value
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func string(forKey key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        // If the item isn't there, that's often expected, so we return nil
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = result as? Data, let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }
        
        return string
    }

    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // We only throw if the error is something other than "not found"
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
}

extension KeychainHelper {
    
    static var authToken: String? {
        try? shared.string(forKey: Keys.authToken)
    }
    
}
