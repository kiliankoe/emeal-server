import Foundation
import SwiftSoup
import Regex

final class MealDetailScraper {
    func extractTitle(from doc: Document) -> String {
        return (try? doc.getElementById("speiseplanessentext").flatMap { try $0.text() } ?? "") ?? ""
    }

    func extractPrices(from doc: Document) -> (students: Double?, employees: Double?) {
        let prices = (try? doc.getElementById("preise")?.text() ?? "") ?? ""
        let digitsRegex = Regex("(\\d.,?\\s?\\d.)")
        let digits = digitsRegex.allMatches(in: prices).map { $0.captures[0] }

        let studentsPriceStr = digits.first??.replacingOccurrences(of: ",", with: ".")
        let employeePriceStr = digits.last??.replacingOccurrences(of: ",", with: ".")

        let studentsPrice = Double(studentsPriceStr ?? "")
        let employeePrice = Double(employeePriceStr ?? "")
        return (studentsPrice ?? 0, employeePrice ?? 0)
    }

    func extractImageURL(from doc: Document) -> String {
        let img = (try? doc.getElementById("essenfoto")?.attr("href") ?? "") ?? ""
        return "https:\(img)"
    }

    private func extractInfos(at pos: Int, from doc: Document) -> [String] {
        guard let infos = try? doc.getElementsByClass("speiseplaninfos") else { return [] }
        let sectionBlock = pos == 0 ? infos.first() : infos.last()
        guard let _listItems = try? sectionBlock?.select("li"), let listItems = _listItems else { return [] }
        guard let values = try? listItems.map({ try $0.text() }) else { return [] }
        return values
    }

    func extractIngredients(from doc: Document) -> [String] {
        return extractInfos(at: 0, from: doc)
    }

    func extractAdditives(from doc: Document) -> [String] {
        return []
    }

    func extractAllergens(from doc: Document) -> [String] {
        return extractInfos(at: 1, from: doc)
    }

    public func scrape(document: Document) -> Meal? {
        let title = self.extractTitle(from: document)
        let (studentPrice, employeePrice) = self.extractPrices(from: document)
        let imgURL = self.extractImageURL(from: document)

        // TODO
        return Meal(title: title, canteen: "", date: "2017-12-19", studentPrice: studentPrice, employeePrice: employeePrice, image: imgURL, detailURL: "", ingredients: [], additives: [], allergens: [], notes: [])
    }
}
