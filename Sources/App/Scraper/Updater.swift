import Foundation
import Jobs

public class Updater {

    enum Interval {
        static let currentDay = Duration.seconds(20 * 60)
        static let nextDay = Duration.hours(6)
        static let currentWeek = Duration.hours(24)
        static let nextTwoWeeks = Duration.days(5)
    }

    static var currentDayLastRun = Date()

    public static func run() {
        // initial fetch all
        Jobs.oneoff(delay: .seconds(10)) {
            let jobs = Week.all.flatMap { week in
                Day.all.map { day in
                    Job.menu(week: week, day: day)
                }
            }
            print("🏃‍♀️ initial fetch all")
            Updater.run(jobs: jobs, id: 0)
        }

        Jobs.delay(by: Interval.currentDay, interval: Interval.currentDay) {
            print("🏃‍♀️ current day")
            if Time.isDay {
                Updater.run(jobs: [.menu(week: .current, day: .today)], id: 1)
            } else {
                guard Updater.currentDayLastRun.timeIntervalSinceNow.hours <= -3 else { return }
                Updater.run(jobs: [.menu(week: .current, day: .today)], id: 1)
            }

            Updater.currentDayLastRun = Date()
        }

        Jobs.delay(by: Interval.nextDay, interval: Interval.nextDay) {
            print("🏃‍♀️ next day")
            Updater.run(jobs: [.menu(week: .current, day: Day.today.next)], id: 2)
        }

        Jobs.delay(by: Interval.currentWeek, interval: Interval.currentWeek) {
            print("🏃‍♀️ current week")
            let jobs = Day.all.map { Job.menu(week: .current, day: $0) }
            Updater.run(jobs: jobs, id: 3)
        }

        Jobs.delay(by: Interval.nextTwoWeeks, interval: Interval.nextTwoWeeks) {
            print("🏃‍♀️ next two weeks")
            let jobs = [Week.next, Week.afterNext].flatMap { week in
                Day.all.map { day in
                    Job.menu(week: week, day: day)
                }
            }
            Updater.run(jobs: jobs, id: 4)
        }
    }

    private static func run(jobs: [Job], id: Int) {
        guard !jobs.isEmpty else { return }
        let crawler = Crawler(id: id, queue: jobs)
        crawler.run()
    }
}
