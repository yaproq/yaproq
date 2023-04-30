import Foundation

final class Cache<Key: Hashable, Value> {
    var costLimit: Int {
        get { underlyingCache.totalCostLimit }
        set { underlyingCache.totalCostLimit = newValue }
    }

    var countLimit: Int {
        get { underlyingCache.countLimit }
        set { underlyingCache.countLimit = newValue }
    }

    private var underlyingCache = NSCache<NSNumber, CachedItem<Value>>()

    init(costLimit: Int = 0, countLimit: Int = 0) {
        self.costLimit = costLimit
        self.countLimit = countLimit
    }

    func setValue(_ value: Value, forKey key: Key) {
        let key = NSNumber(value: key.hashValue)
        let item = CachedItem(value: value)
        underlyingCache.setObject(item, forKey: key)
    }

    func setValue(_ value: Value, forKey key: Key, cost: Int) {
        let key = NSNumber(value: key.hashValue)
        let item = CachedItem(value: value)
        underlyingCache.setObject(item, forKey: key, cost: cost)
    }

    func getValue(forKey key: Key) -> Value? {
        let key = NSNumber(value: key.hashValue)
        guard let item = underlyingCache.object(forKey: key) else { return nil }

        return item.value
    }

    func removeValue(forKey key: String) {
        let key = NSNumber(value: key.hashValue)
        underlyingCache.removeObject(forKey: key)
    }

    func clear() {
        underlyingCache.removeAllObjects()
    }
}

extension Cache {
    private final class CachedItem<T> {
        let value: T

        init(value: T) {
            self.value = value
        }
    }
}
