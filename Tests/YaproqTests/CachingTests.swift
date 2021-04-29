import XCTest
@testable import Yaproq

final class CachingTests: BaseTests {
    func testInit() {
        // Act
        let cache = Cache<String, String>()

        // Assert
        XCTAssertEqual(cache.costLimit, 0)
        XCTAssertEqual(cache.countLimit, 0)

        // Arrange
        let costLimit = 1
        let countLimit = 2

        // Act
        cache.costLimit = costLimit
        cache.countLimit = countLimit

        // Assert
        XCTAssertEqual(cache.costLimit, costLimit)
        XCTAssertEqual(cache.countLimit, countLimit)
    }

    func testSetGet() {
        // Arrange
        let cache = Cache<String, String>(costLimit: 2, countLimit: 3)
        let key1 = "key1"
        let value1 = "value1"
        let key2 = "key2"
        let value2 = "value2"
        let key3 = "key3"
        let value3 = "value3"
        let key4 = "key4"
        let value4 = "value4"

        // Act
        cache.setValue(value1, forKey: key1)

        // Assert
        XCTAssertEqual(cache.getValue(forKey: key1), value1)

        // Act
        cache.setValue(value2, forKey: key2, cost: 1)

        // Assert
        XCTAssertEqual(cache.getValue(forKey: key1), value1)
        XCTAssertEqual(cache.getValue(forKey: key2), value2)

        // Act
        cache.setValue(value3, forKey: key3, cost: 2)

        // Assert
        XCTAssertEqual(cache.getValue(forKey: key1), value1)
        XCTAssertNil(cache.getValue(forKey: key2))
        XCTAssertEqual(cache.getValue(forKey: key3), value3)

        // Act
        cache.setValue(value4, forKey: key4)

        // Assert
        XCTAssertEqual(cache.getValue(forKey: key1), value1)
        XCTAssertNil(cache.getValue(forKey: key2))
        XCTAssertEqual(cache.getValue(forKey: key3), value3)
        XCTAssertEqual(cache.getValue(forKey: key4), value4)

        // Act
        cache.removeValue(forKey: key1)

        // Assert
        XCTAssertNil(cache.getValue(forKey: key1))
        XCTAssertNil(cache.getValue(forKey: key2))
        XCTAssertEqual(cache.getValue(forKey: key3), value3)
        XCTAssertEqual(cache.getValue(forKey: key4), value4)

        // Act
        cache.removeAllValues()

        // Assert
        XCTAssertNil(cache.getValue(forKey: key1))
        XCTAssertNil(cache.getValue(forKey: key2))
        XCTAssertNil(cache.getValue(forKey: key3))
        XCTAssertNil(cache.getValue(forKey: key4))
    }
}
