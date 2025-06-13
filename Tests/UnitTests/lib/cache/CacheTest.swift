import XCTest

@testable import Gammaray

final class CacheTest: XCTestCase {
    func testPutAndGetEntry() throws {
        let cache = try CacheImpl<String>(entryEvictionTimeMillis: 1, maxEntries: 1)

        XCTAssertNil(cache.getAt(key: "key", now: 1))

        cache.putAt(key: "key", value: "v", now: 1)

        XCTAssertEqual(cache.get(key: "key"), "v")
    }

    func testDropOldestEntryWhenFull() throws {
        let cache = try CacheImpl<String>(entryEvictionTimeMillis: 1, maxEntries: 2)
        cache.putAt(key: "key2", value: "v2", now: 2)
        cache.putAt(key: "key1", value: "v1", now: 1)
        cache.putAt(key: "key3", value: "v3", now: 3)

        XCTAssertEqual(cache.size, 2)

        XCTAssertNil(cache.getAt(key: "key1", now: 4))
        XCTAssertEqual(cache.getAt(key: "key2", now: 4), "v2")
        XCTAssertEqual(cache.getAt(key: "key3", now: 4), "v3")
    }

    func testInvalidateOutdatedKeys() throws {
        class TestListener: CacheListener {
            var key1 = 0
            var key3 = 0
            func onEntryEvicted(key: String, value: String) {
                if key == "key1" && value == "v1" {
                    key1 += 1
                }
                if key == "key3" && value == "v3" {
                    key3 += 1
                }
            }
        }
        let listener = TestListener()

        let evictionTime: Int64 = 10
        let cache = try CacheImpl<String>(entryEvictionTimeMillis: evictionTime, maxEntries: 4)
        cache.setListener(listener)
        cache.putAt(key: "key1", value: "v1", now: 1)
        cache.putAt(key: "key2", value: "v2", now: 3)
        cache.putAt(key: "key3", value: "v3", now: 2)
        cache.putAt(key: "keyPutBeforeButGetLater", value: "v4", now: 1)

        _ = cache.getAt(key: "keyPutBeforeButGetLater", now: 3)

        let future = evictionTime + 3
        cache.cleanupAt(future)

        XCTAssertEqual(cache.size, 2)

        XCTAssertNil(cache.getAt(key: "key1", now: future))
        XCTAssertEqual(cache.getAt(key: "key2", now: future), "v2")
        XCTAssertNil(cache.getAt(key: "key3", now: future))
        XCTAssertEqual(cache.getAt(key: "keyPutBeforeButGetLater", now: future), "v4")

        XCTAssertEqual(listener.key1, 1)
        XCTAssertEqual(listener.key3, 1)
    }

    func testBeEmptyAfterClear() throws {
        let cache = try CacheImpl<String>(entryEvictionTimeMillis: 1, maxEntries: 2)
        cache.putAt(key: "key1", value: "v1", now: 1)
        cache.putAt(key: "key2", value: "v2", now: 1)

        cache.clear()

        XCTAssertEqual(cache.size, 0)

        XCTAssertNil(cache.getAt(key: "key1", now: 1))
        XCTAssertNil(cache.getAt(key: "key2", now: 1))
    }
}
