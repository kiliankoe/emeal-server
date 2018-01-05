@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
    }

    public func initialFetchAll() {
//        let jobs = Week.all.flatMap { week in
//            return Day.all.map { Job.menu(week: week, day: $0) }
//        }
        let jobs = [Day.today].map { Job.menu(week: .current, day: $0) }

        Crawler.shared.queue.append(contentsOf: jobs)

        Crawler.shared.run()
    }
}
