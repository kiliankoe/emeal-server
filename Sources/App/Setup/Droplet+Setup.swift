@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
    }

    public func initialFetchAll() {
        let menuJobs = Week.all.flatMap { week in
            return Day.all.map { Job.menu(week: week, day: $0) }
        }
        Crawler.shared.queue.append(contentsOf: menuJobs)

//        Crawler.shared.run()
    }
}
