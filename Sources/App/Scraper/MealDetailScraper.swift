import Foundation
import SwiftSoup
import Regex

final class MealDetailScraper {
    static func extractTitle(from doc: Document) -> String {
        return (try? doc.getElementById("speiseplanessentext").flatMap { try $0.text() } ?? "") ?? ""
    }

    static func extractPrices(from doc: Document) -> (students: Double?, employees: Double?, isSoldOut: Bool) {
        let prices = (try? doc.getElementById("preise")?.text() ?? "") ?? ""
        guard !prices.contains("ausverkauft") else {
            return (nil, nil, true)
        }
        let digitsRegex = Regex("(\\d.,?\\s?\\d.)")
        let digits = digitsRegex.allMatches(in: prices).map { $0.captures[0] }

        let studentsPriceStr = digits.first??.replacingOccurrences(of: ",", with: ".")
        let employeePriceStr = digits.last??.replacingOccurrences(of: ",", with: ".")

        let studentsPrice = Double(studentsPriceStr ?? "")
        let employeePrice = Double(employeePriceStr ?? "")
        return (studentsPrice ?? 0, employeePrice ?? 0, false)
    }

    static func extractImageURL(from doc: Document) -> String? {
        guard let img = (try? doc.select("#essenbild img").attr("src")), !img.isEmpty else { return nil }
        guard !img.contains("noimage.png") else { return nil }
        return "https:\(img)".replacingOccurrences(of: "thumbs/", with: "")
    }

    static func extractHeadlineInfo(from doc: Document) -> (canteen: String, counter: String?, isEveningOffer: Bool)? {
        let headline = (try? doc.select("#speiseplandetails>h1").first()?.text() ?? "") ?? ""
        guard !headline.isEmpty else { return nil }

        let headlineRegex = Regex("(.+) (?:.+|A)ngebot(.*) vom")
        let components = headlineRegex.allMatches(in: headline).first?.captures.flatMap { $0 } ?? []
        guard components.count == 2 else { return nil }

        let canteen = components[0]
        let counter = components[1].isEmpty ? nil : components[1].trim()
        let isEveningOffer = headline.lowercased().contains("abend")

        return (canteen: canteen, counter: counter, isEveningOffer: isEveningOffer)
    }

    private static func extractInfoHeaders(from doc: Document) -> [InfoSection] {
        guard let infos = try? doc.select("#speiseplandetailsrechts>h2") else { return [] }
        return infos.map { InfoSection(string: (try? $0.text()) ?? "") }
    }

    private static func extractInfos(at section: InfoSection, from doc: Document) -> [String] {
        let infoSections = extractInfoHeaders(from: doc)
        guard let secIdx = infoSections.index(of: section) else { return [] }
        let sectionIdx = Int(secIdx)

        guard let infos = try? doc.getElementsByClass("speiseplaninfos") else { return [] }
        let sectionBlock = infos.get(sectionIdx)
        guard let listItems = try? sectionBlock.select("li") else { return [] }
        guard let values = try? listItems.map({ try $0.text() }) else { return [] }
        return values
    }

    static func extractInformation(from doc: Document) -> [String] {
        return extractInfos(at: .information, from: doc)
            .flatMap { Meal.Information(value: $0)?.identifier }
    }

    static func extractAdditives(from doc: Document) -> [String] {
        let parensRegex = Regex("\\((..?)\\)")
        return extractInfos(at: .additives, from: doc).flatMap { allergen in
            parensRegex.firstMatch(in: allergen)?.captures.first ?? ""
        }
    }

    static func extractAllergens(from doc: Document) -> [String] {
        let parensRegex = Regex("\\((..?)\\)")
        return extractInfos(at: .allergens, from: doc).flatMap { allergen in
            parensRegex.firstMatch(in: allergen)?.captures.first ?? ""
        }
    }

    public static func scrape(document: Document, url: URL, forDate date: Date) -> Meal? {
        let title = MealDetailScraper.extractTitle(from: document)
        let (studentPrice, employeePrice, isSoldOut) = MealDetailScraper.extractPrices(from: document)
        let imgURL = MealDetailScraper.extractImageURL(from: document)

        guard let (canteen, counter, isEveningOffer) = MealDetailScraper.extractHeadlineInfo(from: document) else {
            Log.error("Failed to extract meal headline info for meal: \(url.absoluteString)")
            return nil
        }

        let information = MealDetailScraper.extractInformation(from: document)
        let additives = MealDetailScraper.extractAdditives(from: document)
        let allergens = MealDetailScraper.extractAllergens(from: document)

        return Meal(title: title, canteen: canteen, date: date.dateStamp, isSoldOut: isSoldOut, counter: counter, isEveningOffer: isEveningOffer, studentPrice: studentPrice, employeePrice: employeePrice, image: imgURL, detailURL: url, information: information, additives: additives, allergens: allergens)
    }
}

private enum InfoSection: String {
    case information = "informationen"
    case additives = "zusatzstoffe"
    case allergens = "allergene"
    case unknown // placeholder for other possible section headers

    init(string: String) {
        let str = string.lowercased()
        if str.contains(InfoSection.information.rawValue) {
            self = .information
            return
        } else if str.contains(InfoSection.additives.rawValue) {
            self = .additives
            return
        } else if str.contains(InfoSection.allergens.rawValue) {
            self = .allergens
            return
        }
        self = .unknown
    }
}
