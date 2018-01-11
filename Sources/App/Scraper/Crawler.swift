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
                            return Job.meal(canteen: menu.canteen, date: job.date, url: meal)
                        }

                        if day == Day.today && week == .current {
                            // If this job is targeting the current day, mark now missing meals as
                            // being sold out. Some canteens explicitly mark meals as being sold
                            // out, others just seem to remove them. This should help make all that
                            // a little more homogenous.
                            self.updateSoldOutMeals(menu)
                        }

                        return meals
                    }

                    self.queue.append(contentsOf: mealJobs)
                    Log.info("#\(self.id) → \(job.date) \(day): \(mealJobs.count) meal downloads queued")

                case let .meal(canteen: canteen, date: date, url: url):
                    do {
                        let query = try Meal.makeQuery()
                        try query.filter(Meal.Keys.detailURL, url.absoluteString)
                        let meal = try query.all()
                        try meal.forEach { try $0.delete() }
                    } catch {
                        Log.error("Failed deleting previous meal in db for \(url).")
                    }

                    let meal = MealDetailScraper.scrape(document: document, fromCanteen: canteen, onDate: date, url: url.absoluteString)

                    do {
                        try meal.save()
                    } catch {
                        Log.error("Failed saving meal \(String(describing: meal.id)) to db.")
                        continue
                    }
                }
            }

            Log.debug("#\(self.id) done ✔")
        }
    }

    /// Given a list of meals, get all of today's meals not included and mark them as being soldOut
    private func updateSoldOutMeals(_ menu: (canteen: String, meals: [URL])) {
        let meals = menu.meals.map { $0.absoluteString }

        do {
            let query = try Meal.makeQuery()
            try query.filter(Meal.Keys.date, isodate(forDay: .today, inWeek: .current))
            try query.filter(Meal.Keys.canteen, menu.canteen)
            let soldOutMeals = try query.all()
                .filter { !meals.contains($0.detailURL) }

            if soldOutMeals.count > 0 {
                Log.debug("\(soldOutMeals.count) meals removed since last update @ \(menu.canteen):")
            }

            soldOutMeals.forEach {
                Log.debug(" - \($0.detailURL)")
                $0.isSoldOut = true
//                try $0.save() // Is this necessary?
            }
        } catch let error {
            Log.error("Error on updating sold out meals: \(error)")
        }
    }
}
