protocol CacheListener<V> {
    associatedtype V
    func onEntryEvicted(key: String, value: V)
}

enum CacheError: Error {
    case runtimeError(String)
}

private class InternalCacheEntry<V> {
    var v: V
    var ts: Int64

    init(v: V, ts: Int64) {
        self.v = v
        self.ts = ts
    }
}

struct CacheEntry<V> {
    let v: V
    let ts: Int64
}

protocol Cache<V> {
    associatedtype V
    func setListener(_ listener: any CacheListener<V>)
    func put(key: String, value: V)
    func get(key: String) -> V?
    func remove(_ key: String) -> V?
    var size: Int { get }
    func cleanup()
    func clear()
    func removeAnyEntry() -> CacheEntry<V>?
    func forEachEntry(fun: (_ key: String, _ value: V) -> Void)
}

class CacheImpl<V>: Cache {
    private let entryEvictionTimeMillis: Int64
    private let maxEntries: Int
    private var listener: (any CacheListener<V>)?

    private var map: [String: InternalCacheEntry<V>] = [:]

    init(entryEvictionTimeMillis: Int64, maxEntries: Int) throws {
        if entryEvictionTimeMillis <= 0 {
            throw CacheError.runtimeError("entryEvictionTimeMillis must be > 0")
        }

        if maxEntries <= 0 {
            throw CacheError.runtimeError("maxEntries must be > 0")
        }

        self.entryEvictionTimeMillis = entryEvictionTimeMillis
        self.maxEntries = maxEntries
    }

    func setListener(_ listener: any CacheListener<V>) {
        self.listener = listener
    }

    func put(key: String, value: V) {
        putAt(key: key, value: value, now: currentTimeMillis())
    }

    func putAt(key: String, value: V, now: Int64) {
        if let entry = map[key] {
            entry.v = value
            entry.ts = now
            return
        }

        map[key] = InternalCacheEntry(v: value, ts: now)

        if map.count > maxEntries {
            var minKey: String?
            var minTs = Int64.max

            for entry in map {
                if entry.value.ts < minTs {
                    minTs = entry.value.ts
                    minKey = entry.key
                }
            }

            if let minKey {
                if let v = remove(minKey) {
                    listener?.onEntryEvicted(key: key, value: v)
                }
            }
        }
    }

    func get(key: String) -> V? {
        getAt(key: key, now: currentTimeMillis())
    }

    func getAt(key: String, now: Int64) -> V? {
        if let entry = map[key] {
            entry.ts = now
            return entry.v
        }

        return nil
    }

    func remove(_ key: String) -> V? {
        if let value = map.removeValue(forKey: key) {
            return value.v
        }

        return nil
    }

    var size: Int {
        map.count
    }

    func cleanup() {
        cleanupAt(currentTimeMillis())
    }

    func cleanupAt(_ now: Int64) {
        var keysToDelete: [String] = []
        for entry in map {
            if entry.value.ts + entryEvictionTimeMillis < now {
                keysToDelete.append(entry.key)
            }
        }

        for key in keysToDelete {
            if let v = remove(key) {
                listener?.onEntryEvicted(key: key, value: v)
            }
        }
    }

    func clear() {
        map.removeAll()
    }

    func removeAnyEntry() -> CacheEntry<V>? {
        if map.isEmpty {
            return nil
        }

        if let entry = map.first {
            map.removeValue(forKey: entry.key)
            return CacheEntry(v: entry.value.v, ts: entry.value.ts)
        }

        return nil
    }

    func forEachEntry(fun: (_ key: String, _ value: V) -> Void) {
        for entry in map {
            fun(entry.key, entry.value.v)
        }
    }
}
