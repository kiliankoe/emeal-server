import Foundation
import Dispatch
import SwiftSoup

class Crawler {
    var queue: [Job] = []

    static let shared = Crawler()

    func add(_ job: Job) {
        self.queue.append(job)
    }

    func run() {
        DispatchQueue.global(qos: .background).async {
            var queue = self.queue
            self.queue.removeAll(keepingCapacity: false)
            while !queue.isEmpty {
                let job = queue.removeFirst()
                print("Fetching content for job \(job).")
                switch job {
                case .menu(week: let week, day: let day):
                    let url = MenuScraper.menuURL(forWeek: week, andDay: day)
                    guard let content = self.fetch(url: url) else {
                        print("❌ Failed fetching content for \(url). Skipping.")
                        continue
                    }
                    guard let document = try? SwiftSoup.parse(content) else {
                        print("❌ Failed parsing content for \(url). Skipping.")
                        continue
                    }

                    let knownCanteens = (try? Canteen.all()) ?? []
                    let menus = MenuScraper.extractCanteensAndMeals(from: document)
                        .filter { menu in knownCanteens.contains { $0.name.lowercased() == menu.canteen.lowercased() } }

                    for menu in menus {
                        let date = isodate(forDay: day, inWeek: week)
                        let mealJobs = menu.meals.flatMap { urlStr -> Job? in
                            guard let url = URL(string: urlStr) else {
                                print("❌ Invalid URL for meal: \(urlStr)")
                                return nil
                            }
                            return Job.meal(canteen: menu.canteen, date: date, url: url)
                        }
                        print("Added \(mealJobs.count) meal download jobs to queue for canteen \(menu.canteen).")
                        queue.append(contentsOf: mealJobs)
                    }
                case .meal(canteen: let canteen, date: let date, url: let url):
                    guard let content = self.fetch(url: url) else {
                        print("❌ Failed fetching content for \(url). Skipping.")
                        continue
                    }
                    guard let document = try? SwiftSoup.parse(content) else {
                        print("❌ Failed parsing content for \(url). Skipping.")
                        continue
                    }
                    let meal = MealDetailScraper.scrape(document: document, fromCanteen: canteen, onDate: date, url: url.absoluteString)
                    guard let _ = try? meal.save() else {
                        print("❌ Failed saving meal \(String(describing: meal.id)) to DB.")
                        continue
                    }
                }
            }
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
}
