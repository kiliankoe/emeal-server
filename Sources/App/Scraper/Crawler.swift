import Foundation
import Dispatch
import Vapor

class Crawler {
    let id: Int
    var queue: [Job] = []

    init(id: Int, queue: [Job]) {
        self.id = id
        self.queue = queue
    }

    func run() {
        let dispatchQueue = DispatchQueue(label: "emeal-server.crawler")
        dispatchQueue.async {
            Log.debug("#\(self.id) running ↻")

            while !self.queue.isEmpty {
                let job = self.queue.removeFirst()
                guard let document = job.fetchDocument() else {
                    continue
                }

                switch job {
                case let .menu(week: week, day: day):

                    guard let date = MenuScraper.extractDate(from: document) else {
                        Log.error("Failed to read menu date at \(job.url.absoluteString)")
                        continue
                    }

                    let knownCanteens = (try? Canteen.all().map { $0.name.lowercased() }) ?? []
                    let menus = MenuScraper.extractCanteensAndMeals(from: document)
                        .filter {
                            guard knownCanteens.contains($0.canteen.lowercased()) else {
                                if $0.canteen != "Aktuelle Aktionen in den Mensen" {
                                    Log.error("Unknown canteen '\($0.canteen)'")
                                }
                                return false
                            }
                            return true
                        }

                    let mealJobs = menus.flatMap { menu -> [Job] in
                        let meals = menu.meals.map { meal in
                            return Job.meal(date: date, url: meal)
                        }

                        if day == Day.today && week == .current {
                            // If this job is targeting the current day, mark now missing meals as
                            // being sold out. Some canteens explicitly mark meals as being sold
                            // out, others just seem to remove them. This should help make all that
                            // a little more homogenous.
                            self.updateSoldOutMeals(menu, date: date.dateStamp)
                        } else {
                            // In other cases delete the leftovers, since they're no longer relevant
                            do {
                                try self.leftovers(menu, date: date.dateStamp)
                                    .forEach { try $0.delete() }
                            } catch let error {
                                Log.error("Failed deleting future leftovers: \(error)")
                            }
                        }

                        return meals
                    }

                    self.queue.append(contentsOf: mealJobs)

                    Log.info("#\(self.id) → \(date.dateStamp) \(day): \(mealJobs.count) meal downloads queued")

                case let .meal(date: date, url: url):
                    let previousMeals: [Meal]
                    do {
                        previousMeals = try Meal.makeQuery()
                            .filter(Meal.Keys.detailURL, url)
                            .filter(Meal.Keys.date, date.dateStamp)
                            .all()
                    } catch let error {
                        Log.error("Error on fetching previous meal for \(url): \(error)")
                        continue
                    }

                    guard let meal = MealDetailScraper.scrape(document: document, url: url, forDate: date) else {
                        Log.error("Failed to scrape meal details for \(url.absoluteString)")
                        continue
                    }

                    do {
                        if !previousMeals.isEmpty {
                            try previousMeals.forEach {
                                try $0.update(from: meal)
                            }
                        } else {
                            try meal.save()
                        }
                    } catch let error {
                        Log.error("Failed saving/updating meal \(meal.detailURL.absoluteString): \(error)")
                        continue
                    }
                }
            }

            Log.debug("#\(self.id) done ✔")
        }
    }

    /// Given a list of meals, get all of today's meals not included and mark them as being soldOut
    private func updateSoldOutMeals(_ menu: (canteen: String, meals: [URL]), date: ISODate) {
        do {
            let soldOutMeals = try self.leftovers(menu, date: date)

            if soldOutMeals.count > 0 {
                Log.debug("\(soldOutMeals.count) meals removed since last update @ \(menu.canteen):")
            }

            try soldOutMeals.forEach {
                Log.debug(" - \($0.detailURL)")
                $0.isSoldOut = true
                try $0.save()
            }
        } catch let error {
            Log.error("Error on updating sold out meals: \(error)")
        }
    }

    /// Given a menu and date, returns a list of meals that were saved on previous runs and are
    /// no longer included.
    private func leftovers(_ menu: (canteen: String, meals: [URL]), date: ISODate) throws -> [Meal] {
        return try Meal.makeQuery()
            .filter(Meal.Keys.date, date)
            .filter(Meal.Keys.canteen, menu.canteen)
            .all()
            .filter { !menu.meals.contains($0.detailURL) }
    }
}
