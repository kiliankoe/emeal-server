import Foundation

extension Date {
    var dateStamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    init?(menuHeadlineValue: String) {
        guard let date = Date.menuHeadlineFormatter.date(from: menuHeadlineValue) else {
            return nil
        }
        self = date
    }

    static var menuHeadlineFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd. MMMM yyyy"
        df.locale = Locale(identifier: "de_DE")
        return df
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
