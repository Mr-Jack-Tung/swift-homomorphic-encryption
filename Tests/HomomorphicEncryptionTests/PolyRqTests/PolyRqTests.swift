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
import XCTest

final class PolyRqTests: XCTestCase {
    func testZero() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let zeroCoeff = PolyRq<_, Coeff>.zero(context: context)
        XCTAssert(zeroCoeff.isZero(variableTime: true))

        let zeroEval = PolyRq<_, Eval>.zero(context: context)
        XCTAssert(zeroEval.isZero(variableTime: true))
    }

    func testCoefficient() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let data: [UInt32] = [0, 1, 0, 1,
                              0, 1, 2, 0,
                              0, 1, 2, 3]
        let x = PolyRq<_, Coeff>(
            context: context,
            data: Array2d(data: data, rowCount: 3, columnCount: 4))

        XCTAssertEqual(x.coefficient(coeffIndex: 0), [0, 0, 0])
        XCTAssertEqual(x.coefficient(coeffIndex: 1), [1, 1, 1])
        XCTAssertEqual(x.coefficient(coeffIndex: 2), [0, 2, 2])
        XCTAssertEqual(x.coefficient(coeffIndex: 3), [1, 0, 3])
    }

    func testAddAssignConst() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let data: [UInt32] = [0, 1, 0, 1,
                              0, 1, 2, 0,
                              0, 1, 2, 3]
        var x = PolyRq<_, Coeff>(
            context: context,
            data: Array2d(data: data, rowCount: 3, columnCount: 4))
        let y = x
        let sum = x + y
        x += y

        XCTAssertEqual(x, sum)
        XCTAssertEqual(x.poly(rnsIndex: 0), [0, 0, 0, 0])
        XCTAssertEqual(x.poly(rnsIndex: 1), [0, 2, 1, 0])
        XCTAssertEqual(x.poly(rnsIndex: 2), [0, 2, 4, 1])
    }

    func testSubAssignConst() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let data: [UInt32] = [0, 1, 0, 1,
                              0, 1, 2, 0,
                              0, 1, 2, 3]

        var x = PolyRq<_, Coeff>.zero(context: context)
        let y = PolyRq<_, Coeff>(
            context: context,
            data: Array2d(data: data, rowCount: 3, columnCount: 4))
        let difference = x - y
        x -= y

        XCTAssertEqual(x, difference)
        XCTAssertEqual(x.poly(rnsIndex: 0), [0, 1, 0, 1])
        XCTAssertEqual(x.poly(rnsIndex: 1), [0, 2, 1, 0])
        XCTAssertEqual(x.poly(rnsIndex: 2), [0, 4, 3, 2])
    }

    func testNegationConst() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let data: [UInt32] = [0, 1, 0, 1,
                              0, 1, 2, 0,
                              0, 1, 2, 3]
        var x = PolyRq<_, Coeff>(
            context: context,
            data: Array2d(data: data, rowCount: 3, columnCount: 4))

        x = -x

        XCTAssertEqual(x.poly(rnsIndex: 0), [0, 1, 0, 1])
        XCTAssertEqual(x.poly(rnsIndex: 1), [0, 2, 1, 0])
        XCTAssertEqual(x.poly(rnsIndex: 2), [0, 4, 3, 2])
    }

    func testMultiplicationPoly() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let xData: [UInt32] = [0, 1, 0, 1,
                               0, 1, 2, 0,
                               0, 1, 2, 3]
        var x = PolyRq<_, Eval>(
            context: context,
            data: Array2d(data: xData, rowCount: 3, columnCount: 4))
        let yData: [UInt32] = [1, 1, 1, 0,
                               1, 2, 2, 1,
                               1, 2, 3, 0]
        let y = PolyRq<_, Eval>(
            context: context,
            data: Array2d(data: yData, rowCount: 3, columnCount: 4))
        let product = x * y
        x *= y

        XCTAssertEqual(x, product)
        XCTAssertEqual(x.poly(rnsIndex: 0), [0, 1, 0, 0])
        XCTAssertEqual(x.poly(rnsIndex: 1), [0, 2, 1, 0])
        XCTAssertEqual(x.poly(rnsIndex: 2), [0, 2, 1, 0])
    }

    func testMultiplicationConstantPoly() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let xData: [UInt32] = [0, 1, 0, 1,
                               0, 1, 2, 0,
                               0, 1, 2, 3]
        var x = PolyRq<_, Coeff>(
            context: context,
            data: Array2d(data: xData, rowCount: 3, columnCount: 4))
        let y = UInt32(12)
        let yResidues = context.moduli.map { modulus in y % modulus }
        let product = x * yResidues
        x *= yResidues

        XCTAssertEqual(x, product)
        XCTAssertEqual(x.poly(rnsIndex: 0), [0, y % 2, (2 * y) % 2, (3 * y) % 2])
        XCTAssertEqual(x.poly(rnsIndex: 1), [0, y % 3, (2 * y) % 3, (3 * y) % 3])
        XCTAssertEqual(x.poly(rnsIndex: 2), [0, y % 5, (2 * y) % 5, (3 * y) % 5])
    }

    func testDivideAndRoundQLast() throws {
        // 2 moduli
        do {
            let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [13, 17])
            // x = [2, 41, 42, 43]
            let xData: [UInt32] = [2, 2, 3, 4,
                                   2, 7, 8, 9]
            var x = PolyRq<_, Coeff>(
                context: context,
                data: Array2d(data: xData, rowCount: 2, columnCount: 4))

            try x.divideAndRoundQLast()
            // round(x / 17) = round(0, 41/17, 42/17, 43/17) ~= round(0, 2.41, 2.47, 2.52) = [0, 2, 2, 3]
            XCTAssertEqual(x.data, Array2d(data: [0, 2, 2, 3], rowCount: 1, columnCount: 4))
        }
        // 3 moduli
        do {
            let context: PolyContext<UInt64> = try PolyContext(degree: 2, moduli: [13, 17, 29])
            // x = [25, 298]
            let xData: [UInt64] = [12, 12,
                                   8, 9,
                                   25, 8]
            var x = PolyRq<_, Coeff>(
                context: context,
                data: Array2d(data: xData, rowCount: 3, columnCount: 2))

            // round(x / 29) = round([25/29, 298/29]) = round(0.86, 10.28) = [1, 10]
            try x.divideAndRoundQLast()
            XCTAssertEqual(x.data, Array2d(data: [1, 10, 1, 10], rowCount: 2, columnCount: 2))
        }
    }

    func testMultiplyInverseXPower() throws {
        let context: PolyContext<UInt32> = try PolyContext(degree: 4, moduli: [2, 3, 5])
        let data: [UInt32] = [0, 1, 0, 1,
                              0, 1, 2, 0,
                              0, 1, 2, 3]
        let x = PolyRq<_, Coeff>(
            context: context,
            data: Array2d(data: data, rowCount: 3, columnCount: 4))
        var y = [PolyRq<UInt32, Coeff>]()
        y.append(x)
        for i in 1...7 {
            var x = x
            try x.multiplyInversePowerOfX(i)
            y.append(x)
        }
        for i in 0...3 {
            let z = y[i] + y[i + 4]
            for rnsIndex in 0...2 {
                XCTAssertEqual(z.poly(rnsIndex: rnsIndex), [0, 0, 0, 0])
            }
        }
        XCTAssertEqual(y[0], x)
        XCTAssertEqual(y[1].poly(rnsIndex: 0), [1, 0, 1, 0])
        XCTAssertEqual(y[1].poly(rnsIndex: 1), [1, 2, 0, 0])
        XCTAssertEqual(y[1].poly(rnsIndex: 2), [1, 2, 3, 0])
        XCTAssertEqual(y[2].poly(rnsIndex: 0), [0, 1, 0, 1])
        XCTAssertEqual(y[2].poly(rnsIndex: 1), [2, 0, 0, 2])
        XCTAssertEqual(y[2].poly(rnsIndex: 2), [2, 3, 0, 4])
        XCTAssertEqual(y[3].poly(rnsIndex: 0), [1, 0, 1, 0])
        XCTAssertEqual(y[3].poly(rnsIndex: 1), [0, 0, 2, 1])
        XCTAssertEqual(y[3].poly(rnsIndex: 2), [3, 0, 4, 3])
    }
}