// Copyright 2024 Apple Inc. and the Swift Homomorphic Encryption project authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import HomomorphicEncryption
@testable import PrivateInformationRetrieval
import PrivateInformationRetrievalProtobuf

import TestUtilities
import XCTest

class ConversionTests: XCTestCase {
    func testKeywordDatabase() throws {
        let rowCount = 10
        let payloadSize = 5
        let databaseRows = (0..<rowCount).map { index in KeywordValuePair(
            keyword: [UInt8](String(index).utf8),
            value: (0..<payloadSize).map { _ in UInt8.random(in: 0..<UInt8.max) })
        }

        let proto = databaseRows.proto()
        XCTAssertEqual(proto.rows.count, rowCount)
        XCTAssert(proto.rows.map(\.value).allSatisfy { $0.count == payloadSize })
        let native = proto.native()

        XCTAssertEqual(native, databaseRows)
    }
}
