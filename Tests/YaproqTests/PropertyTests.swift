import XCTest
@testable import Yaproq

final class PropertyTests: BaseTests {
    func testNames() {
        // Assert
        XCTAssertEqual(Property.allCases.count, 14)
        XCTAssertEqual(Property.capitalized.rawValue, "capitalized")
        XCTAssertEqual(Property.capitalizeFirstCharacter.rawValue, "capitalizeFirstCharacter")
        XCTAssertEqual(Property.count.rawValue, "count")
        XCTAssertEqual(Property.first.rawValue, "first")
        XCTAssertEqual(Property.isEmpty.rawValue, "isEmpty")
        XCTAssertEqual(Property.keys.rawValue, "keys")
        XCTAssertEqual(Property.last.rawValue, "last")
        XCTAssertEqual(Property.localizedCapitalized.rawValue, "localizedCapitalized")
        XCTAssertEqual(Property.localizedLowercase.rawValue, "localizedLowercase")
        XCTAssertEqual(Property.localizedUppercase.rawValue, "localizedUppercase")
        XCTAssertEqual(Property.lowercased.rawValue, "lowercased")
        XCTAssertEqual(Property.reversed.rawValue, "reversed")
        XCTAssertEqual(Property.uppercased.rawValue, "uppercased")
        XCTAssertEqual(Property.values.rawValue, "values")
    }

    func testValues() {
        // Arrange
        let token = Token(kind: .identifier, lexeme: "variable", line: -1, column: -1)
        let data: [(Property, Any, Any)] = [
            (.capitalized, "capitalize each word", "Capitalize Each Word"),
            (.capitalizeFirstCharacter, "capitalize first character", "Capitalize first character"),
            (.count, [1, 2], 2),
            (.count, ["1": 1, "2": 2], 2),
            (.count, "string", 6),
            (.first, [1, 2], 1),
            (.first, "string", "s"),
            (.isEmpty, [], true),
            (.isEmpty, [1, 2], false),
            (.isEmpty, [:], true),
            (.isEmpty, ["1": 1, "2": 2], false),
            (.isEmpty, "", true),
            (.isEmpty, "string", false),
            (.keys, ["1": 1, "2": 2], ["1", "2"]),
            (.last, [1, 2], 2),
            (.last, "string", "g"),
            (.localizedCapitalized, "capitalize each word", "Capitalize Each Word"),
            (.localizedLowercase, "Lowercase Each Character", "lowercase each character"),
            (.localizedUppercase, "uppercase each character", "UPPERCASE EACH CHARACTER"),
            (.lowercased, "Lowercase Each Character", "lowercase each character"),
            (.reversed, [1, 2], [2, 1]),
            (.reversed, "string", String("string".reversed())),
            (.uppercased, "uppercase each character", "UPPERCASE EACH CHARACTER"),
            (.values, ["1": "3", "2": "4"], ["3", "4"])
        ]
        let invalidData: [(Property, Any)] = [
            (.capitalized, 1),
            (.capitalizeFirstCharacter, 1),
            (.count, (1, 2)),
            (.first, (1, 2)),
            (.isEmpty, (1, 2)),
            (.keys, [1, 2]),
            (.last, (1, 2)),
            (.localizedCapitalized, 1),
            (.localizedLowercase, 1),
            (.localizedUppercase, 1),
            (.lowercased, 1),
            (.reversed, (1, 2)),
            (.uppercased, 1),
            (.values, [1, 2])
        ]

        for propertyData in data {
            let expectedResult = String(describing: propertyData.2)
            let actualResult: String

            if propertyData.0 == .keys || propertyData.0 == .values {
                actualResult = String(describing: ((try? propertyData.0.value(from: propertyData.1, for: token))! as? [String])!.sorted())
            } else {
                actualResult = String(describing: (try? propertyData.0.value(from: propertyData.1, for: token))!)
            }

            // Assert
            XCTAssertEqual(actualResult, expectedResult)
        }

        for propertyData in invalidData {
            // Assert
            XCTAssertThrowsError(try propertyData.0.value(from: propertyData.1, for: token)) { error in
                guard let error = error as? RuntimeError else {
                    XCTFail("The error is not of \(String(describing: RuntimeError.self)) type.")
                    return
                }

                XCTAssertNil(error.filePath)
                XCTAssertEqual(error.line, token.line)
                XCTAssertEqual(error.column, token.column)
                XCTAssertEqual(error.errorDescription, """
                [Line: \(error.line), Column: \(error.column)] \
                \(String(describing: RuntimeError.self)): \(ErrorType.undefinedVariableOrProperty(propertyData.0.rawValue))
                """
                )
            }
        }
    }
}
