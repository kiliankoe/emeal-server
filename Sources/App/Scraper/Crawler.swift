import Foundation
import Dispatch
import SwiftSoup

class Crawler {
    let id: Int
    var queue: [Job] = []

    init(id: Int, queue: [Job]) {
        self.id = id
        self.queue = queue
    }

    func log(_ message: String) {
        print("#\(self.id) \(message)")
    }

    func run() {
        let dispatchQueue = DispatchQueue(label: "emeal-server.crawler")
        dispatchQueue.async {
            self.log("running ↻")

            while !self.queue.isEmpty {
                let job = self.queue.removeFirst()
                switch job {
                case .menu(week: let week, day: let day):
                    let url = MenuScraper.menuURL(forWeek: week, andDay: day)
                    guard let content = self.fetch(url: url) else {
                        self.log("❌ Failed fetching content for \(url). Skipping.")
                        continue
                    }
                    guard let document = try? SwiftSoup.parse(content) else {
                        self.log("❌ Failed parsing content for \(url). Skipping.")
                        continue
                    }

                    let knownCanteens = (try? Canteen.all()) ?? []
                    let menus = MenuScraper.extractCanteensAndMeals(from: document)
                        .filter { menu in knownCanteens.contains { $0.name.lowercased() == menu.canteen.lowercased() } }

                    var sum = 0
                    for menu in menus {
                        let date = isodate(forDay: day, inWeek: week)
                        let mealJobs = menu.meals.flatMap { urlStr -> Job? in
                            guard let url = URL(string: urlStr) else {
                                self.log("❌ Invalid URL for meal: \(urlStr)")
                                return nil
                            }
                            return Job.meal(canteen: menu.canteen, date: date, url: url)
                        }
                        sum += mealJobs.count
                        self.queue.append(contentsOf: mealJobs)
                    }
                    self.log("→ \(job.date): \(sum) meal downloads queued")

                case .meal(canteen: let canteen, date: let date, url: let url):
                    do {
                        let query = try Meal.makeQuery()
                        try query.filter(Meal.Keys.detailURL, url.absoluteString)
                        let meal = try query.all()
                        try meal.forEach { try $0.delete() }
                    } catch {
                        self.log("❌ Failed deleting previous meal in db for \(url). Skipping.")
                    }

                    guard let content = self.fetch(url: url) else {
                        self.log("❌ Failed fetching content for \(url). Skipping.")
                        continue
                    }
                    guard let document = try? SwiftSoup.parse(content) else {
                        self.log("❌ Failed parsing content for \(url). Skipping.")
                        continue
                    }
                    let meal = MealDetailScraper.scrape(document: document, fromCanteen: canteen, onDate: date, url: url.absoluteString)
                    guard let _ = try? meal.save() else {
                        self.log("❌ Failed saving meal \(String(describing: meal.id)) to DB.")
                        continue
                    }
                }
            }

            self.log("done ✔")
        }
    }

    private func fetch(url: URL) -> String? {
        let sema = DispatchSemaphore(value: 0)
        var body: String?

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let data = data,
                let content = String(data: data, encoding: .utf8),
                let response = response as? HTTPURLResponse,
                response.statusCode/100 == 2
            else {
                body = nil
                sema.signal()
                return
            }
            body = content
            sema.signal()
        }
        task.resume()
        sema.wait()
        return body
    }
}

enum Job {
    case menu(week: Week, day: Day)
    case meal(canteen: String, date: ISODate, url: URL)

    var date: ISODate {
        switch self {
        case let .menu(week: week, day: day):
            return isodate(forDay: day, inWeek: week)
        case let .meal(canteen: _, date: date, url: _):
            return date
        }
    }
}
