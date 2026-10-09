import Foundation
import Security
struct KeyStore {
    static func save(_ value: String, name: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "PersonalAIKeyboard", kSecAttrAccount as String: name]
        SecItemDelete(query as CFDictionary)
        var item = query; item[kSecValueData as String] = Data(value.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else { throw KeyboardFailure.missingConfiguration }
    }
    static func read(_ name: String) -> String {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "PersonalAIKeyboard", kSecAttrAccount as String: name, kSecReturnData as String: true]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}
