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
        // initial fetch all
        Jobs.oneoff(delay: .seconds(10)) {
            Log.verbose("initial content update")
            let jobs = Week.all.flatMap { week in
                Day.all.map { day in
                    Job.menu(week: week, day: day)
                }
            }
            Updater.run(jobs: jobs, id: 0)
        }

        Jobs.delay(by: Interval.currentDay, interval: Interval.currentDay) {
            Log.verbose("current day update")
            if Time.isDay {
                Updater.run(jobs: [.menu(week: .current, day: .today)], id: 1)
            } else {
                guard Updater.currentDayLastRun.timeIntervalSinceNow.hours <= -3 else { return }
                Updater.run(jobs: [.menu(week: .current, day: .today)], id: 1)
            }

            Updater.currentDayLastRun = Date()
        }

        Jobs.delay(by: Interval.nextDay, interval: Interval.nextDay) {
            Log.verbose("next day update")
            Updater.run(jobs: [.menu(week: .current, day: Day.today.next)], id: 2)
        }

        Jobs.delay(by: Interval.currentWeek, interval: Interval.currentWeek) {
            Log.verbose("current week update")
            let jobs = Day.all.map { Job.menu(week: .current, day: $0) }
            Updater.run(jobs: jobs, id: 3)
        }

        Jobs.delay(by: Interval.nextTwoWeeks, interval: Interval.nextTwoWeeks) {
            Log.verbose("next two weeks update")
            let jobs = [Week.next, Week.afterNext].flatMap { week in
                Day.all.map { day in
                    Job.menu(week: week, day: day)
                }
            }
            Updater.run(jobs: jobs, id: 4)
        }

        Jobs.delay(by: Interval.deleteOldData, interval: Interval.deleteOldData) {
            Log.verbose("delete old data update")
            do {
                let currentDate = isodate(forDay: .today, inWeek: .current)
                let pastMeals = try Meal.all().filter { $0.date < currentDate }
                for meal in pastMeals {
                    try meal.delete()
                }
            } catch {
                Log.error("Failed to delete old meals.")
            }
        }
    }

    private static func run(jobs: [Job], id: Int) {
        guard !jobs.isEmpty else { return }
        let crawler = Crawler(id: id, queue: jobs)
        crawler.run()
    }
}
