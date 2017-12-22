extension Array where Element == String {
    var semicolonStr: String {
        return self.joined(separator: ";")
    }
}

extension String {
    var semicolonArr: [String] {
        return self
            .split(separator: ";")
            .map(String.init)
    }
}
