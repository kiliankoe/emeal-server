import Foundation

extension Date {
    var dateStamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

extension TimeInterval {
    var minutes: Double {
        return self / 60
    }

    var hours: Double {
        return self.minutes / 60
    }
}
