import Foundation
import Vapor
import Jobs

public class Updater {

    enum Interval {
        static let currentDay = Duration.seconds(20 * 60)
        static let nextDay = Duration.hours(6)
        static let currentWeek = Duration.hours(24)
        static let nextTwoWeeks = Duration.days(5)
        static let deleteOldData = Duration.days(1)
    }

    static var currentDayLastRun = Date()

    public static func run() {
        // initial fetch of current and next week
        Jobs.oneoff(delay: .seconds(5)) {
            Log.verbose("initial current and next week update")
            let jobs = [Week.current, Week.next].flatMap { week in
                Day.all.map { day in
                    Job.menu(week: week, day: day)
                }
            }
            Updater.run(jobs: jobs)
        }

        Jobs.delay(by: Interval.currentDay, interval: Interval.currentDay) {
            Log.verbose("current day update")
            if Time.isDay {
                Updater.run(jobs: [.menu(week: .current, day: .today)])
            } else {
                guard Updater.currentDayLastRun.timeIntervalSinceNow.hours <= -3 else {
                    Log.verbose("skipping 💤")
                    return
                }
                Updater.run(jobs: [.menu(week: .current, day: .today)])
            }

            Updater.currentDayLastRun = Date()
        }

        Jobs.delay(by: Interval.nextDay, interval: Interval.nextDay) {
            Log.verbose("next day update")
            Updater.run(jobs: [.menu(week: .current, day: Day.today.next)])
        }

        Jobs.delay(by: Interval.currentWeek, interval: Interval.currentWeek) {
            Log.verbose("current week update")
            let jobs = Day.all.map { Job.menu(week: .current, day: $0) }
            Updater.run(jobs: jobs)
        }

        Jobs.delay(by: Interval.nextTwoWeeks, interval: Interval.nextTwoWeeks) {
            Log.verbose("next two weeks update")
            let jobs = [Week.next, Week.afterNext].flatMap { week in
                Day.all.map { day in
                    Job.menu(week: week, day: day)
                }
            }
            Updater.run(jobs: jobs)
        }

        Jobs.delay(by: Interval.deleteOldData, interval: Interval.deleteOldData) {
            Log.verbose("delete old data update")
            do {
                let currentDate = isodate(forDay: .today, inWeek: .current)
                let pastMeals = try Meal.all().filter { $0.date < currentDate }
                for meal in pastMeals {
                    try meal.delete()
                }
            } catch let error {
                Log.error("Failed to delete old meals: \(error)")
            }
        }
    }

    private static func run(jobs: [Job]) {
        guard !jobs.isEmpty else { return }

        if let _ = ProcessInfo.processInfo.environment["EMEAL_CONCURRENT_CRAWLERS"] {
            jobs.enumerated().forEach { (jobs) in
                let (idx, job) = jobs
                let crawler = Crawler(id: idx, queue: [job])
                crawler.run()
            }
        } else {
            let crawler = Crawler(id: 0, queue: jobs)
            crawler.run()
        }


    }
}
