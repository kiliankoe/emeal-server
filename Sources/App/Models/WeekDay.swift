import Foundation

enum Week: Int {
    case current = 0
    case next
    case afterNext

    static let all: [Week] = [.current, .next, .afterNext]

    var dayOffsetToNow: Int {
        return 7 * self.rawValue
    }

    init?(rawString: String) {
        switch rawString {
        case "current": self = .current
        case "next": self = .next
        case "afterNext": self = .afterNext
        case _: return nil
        }
    }
}

enum Day: Int {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    static var today: Day {
        return Day.today(from: Date())
    }

    var next: Day {
        return Day(rawValue: (self.rawValue + 1) % 7)!
    }

    internal static func today(from date: Date) -> Day {
        let comp = Calendar(identifier: .gregorian).dateComponents([.weekday], from: date)
        switch (comp.weekday ?? 1) {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        case _: return .sunday
        }
    }

    var stuweValue: Int {
        return (self.rawValue + 8) % 7
    }

    func weekdayOffset(to day: Day) -> Int {
        return (self.rawValue - day.rawValue)// + weekoffset
    }

    static let all: [Day] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    init?(rawString: String) {
        switch rawString {
        case "monday": self = .monday
        case "tuesday": self = .tuesday
        case "wednesday": self = .wednesday
        case "thursday": self = .thursday
        case "friday": self = .friday
        case "saturday": self = .saturday
        case "sunday": self = .sunday
        case "today": self = .today
        case _: return nil
        }
    }
}

enum Time {
    static var isDay: Bool {
        let now = Date()
        let comp = Calendar(identifier: .gregorian).dateComponents([.hour], from: now)
        let hour = comp.hour ?? 0
        return hour >= 8 && hour <= 20
    }
}

func isodate(forDay day: Day, inWeek week: Week, fromDate date: Date = Date()) -> ISODate {
    let offset = week.dayOffsetToNow + day.weekdayOffset(to: .today(from: date))
    let date = date.addingTimeInterval(TimeInterval(offset * 24 * 3600))
    return date.dateStamp
}
