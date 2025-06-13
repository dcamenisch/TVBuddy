//
//  CacheService.swift
//  TVBuddy
//
//  Created by Danny on 13.06.2025.
//

import Foundation

class CacheService<Key: Hashable & Equatable, Value> {
    private let cache = NSCache<WrappedKey, Entry>()
    
    init(cacheSize: Int = 50 * 1024 * 1024) {
        cache.totalCostLimit = cacheSize
    }
    
    func setObject(_ object: Value, forKey key: Key) {
        let entry = Entry(object)
        cache.setObject(entry, forKey: WrappedKey(key))
    }
    
    func object(forKey key: Key) -> Value? {
        guard let entry = cache.object(forKey: WrappedKey(key)) else { return nil }
        return entry.value
    }
    
    func removeObject(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }
    
    func removeAllObjects() {
        cache.removeAllObjects()
    }
}

private extension CacheService {
    final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        override var hash: Int { key.hashValue }
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }
    
    final class Entry {
        let value: Value
        init(_ value: Value) { self.value = value }
    }
}
