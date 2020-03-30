struct BigInteger {
    private let digits: [Int8]
}

extension BigInteger: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        var digits = [Int8]()
        for c in value {
            if let i = Int8(String(c)), i >= 0, i < 10 {
                digits.insert(Int8(i), at: 0)
            }
        }

        self.digits = digits
    }
}

extension BigInteger {
    var length: Int {
        return digits.count
    }

    func digit(at index: UInt) -> Int8 {
        guard index < digits.count else {
            return 0
        }

        return digits[Int(index)]
    }
}

extension BigInteger: CustomStringConvertible {
    var description: String {
        return digits.reduce("") { s, digit in
            return String(digit) + s
        }
    }
}

extension BigInteger {
    static func + (left: BigInteger, right: BigInteger) -> BigInteger {
        var digits = [Int8]()
        var carry: Int8 = 0
        var i: UInt = 0
        let length = max(left.length, right.length)

        while i < length {
            let sum = left.digit(at: i) + right.digit(at: i) + carry
            digits.append(sum % 10)
            carry = sum > 9 ? 1 : 0
            i = i + 1
        }

        if carry > 0 {
            digits.append(carry)
        }

        return BigInteger(digits: digits)
    }

    static func - (left: BigInteger, right: BigInteger) -> BigInteger {
        var digits = [Int8]()
        var carry: Int8 = 0
        var i: UInt = 0
        let length = max(left.length, right.length)

        while i < length {
            var diff = left.digit(at: i) - right.digit(at: i) - carry
            if diff < 0 {
                diff = 10 + diff
                carry = 1
            }
            else {
                carry = 0
            }
            digits.append(diff)
            i = i + 1
        }

        if carry != 0 {
            fatalError("Can't handle negative numbers")
        }

        return BigInteger(digits: digits)
    }

    static func << (left: BigInteger, right: UInt) -> BigInteger {
        var digits = left.digits
        for _ in 0..<right {
            digits.insert(0, at: 0)
        }

        return BigInteger(digits: digits)
    }

    func split(with length: UInt, half: UInt) -> (BigInteger, BigInteger) {
        var b = [Int8]()
        var a = [Int8]()

        for i in 0..<length {
            if i < half {
                b.append(digit(at: i))
            }
            else {
                a.append(digit(at: i))
            }
        }

        return (BigInteger(digits: a), BigInteger(digits: b))
    }

    static func * (left: BigInteger, right: BigInteger) -> BigInteger {
        let length = UInt(max(left.length, right.length))
        if length == 1 {
            let prod = left.digit(at: 0) * right.digit(at: 0)
            if prod < 10 {
                return BigInteger(digits: [prod])
            }
            else {
                let d1 = prod % 10
                let d2 = (prod - d1) / 10
                return BigInteger(digits: [d1, d2])
            }
        }

        let half_n = UInt(length/2)
        let (a, b) = left.split(with: length, half: half_n)
        let (c, d) = right.split(with: length, half: half_n)

        let ac = a * c
        let bd = b * d
        let ad_bc = (a + b) * (c + d) - ac - bd
        //        let ad_bc = a * d + b * c

        let res = (ac << (half_n * 2)) + (ad_bc << half_n) + bd
        return res
    }
}
