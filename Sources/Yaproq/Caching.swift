import Foundation

final class Cache<Key: Hashable, Value> {
    var costLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }

    var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }

    private var cache = NSCache<NSNumber, CachedItem<Value>>()

    init(costLimit: Int = 0, countLimit: Int = 0) {
        self.costLimit = costLimit
        self.countLimit = countLimit
    }

    func setValue(_ value: Value, forKey key: Key) {
        let key = NSNumber(value: key.hashValue)
        let item = CachedItem(value: value)
        cache.setObject(item, forKey: key)
    }

    func setValue(_ value: Value, forKey key: Key, cost: Int) {
        let key = NSNumber(value: key.hashValue)
        let item = CachedItem(value: value)
        cache.setObject(item, forKey: key, cost: cost)
    }

    func getValue(forKey key: Key) -> Value? {
        let key = NSNumber(value: key.hashValue)
        guard let item = cache.object(forKey: key) else { return nil }

        return item.value
    }

    func removeValue(forKey key: String) {
        let key = NSNumber(value: key.hashValue)
        cache.removeObject(forKey: key)
    }

    func clear() {
        cache.removeAllObjects()
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
