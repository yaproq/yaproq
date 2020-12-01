import XCTest
@testable import Yaproq

class BaseTests: XCTestCase {
    override func setUp() {
        super.setUp()

        Delimiter.reset()
    }
}
