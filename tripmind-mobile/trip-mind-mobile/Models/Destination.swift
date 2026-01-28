import Foundation

struct Destination: Identifiable, Hashable {
    let id = UUID()
    let category: String
    let title: String
    /// Expected to be an asset name (recommended) or a path-like string (we'll best-effort derive an asset name).
    let src: String
    let link: URL

    /// Best-effort asset name derived from `src` (e.g. "/hero/chichen.webp" -> "chichen").
    var derivedAssetName: String {
        let last = src.split(separator: "/").last.map(String.init) ?? src
        if let dot = last.lastIndex(of: ".") {
            return String(last[..<dot])
        }
        return last
    }
}

enum SampleDestinations {
    static let destinations: [Destination] = [
        Destination(
            category: "World Wonder",
            title: "Discover Chichen Itza",
            src: "/hero/chichen.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Chichen_Itza")!
        ),
        Destination(
            category: "World Wonder",
            title: "Marvel at Christ the Redeemer",
            src: "/hero/christ.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Christ_the_Redeemer_(statue)")!
        ),
        Destination(
            category: "Ancient History",
            title: "Step inside the Colosseum",
            src: "/hero/colosseum.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Colosseum")!
        ),
        Destination(
            category: "Ancient History",
            title: "Uncover the Great Pyramid of Giza",
            src: "/hero/giza.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Great_Pyramid_of_Giza")!
        ),
        Destination(
            category: "Adventure",
            title: "Explore Machu Picchu",
            src: "/hero/peru.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Machu_Picchu")!
        ),
        Destination(
            category: "World Wonder",
            title: "Admire the Taj Mahal",
            src: "/hero/taj.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Taj_Mahal")!
        ),
        Destination(
            category: "Landmark",
            title: "Visit the India Gate",
            src: "/hero/india.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/India_Gate")!
        ),
        Destination(
            category: "World Wonder",
            title: "Walk the Great Wall of China",
            src: "/hero/wall.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Great_Wall_of_China")!
        ),
        Destination(
            category: "Iconic Landmark",
            title: "See the Eiffel Tower",
            src: "/hero/tower.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Eiffel_Tower")!
        ),
        Destination(
            category: "Iconic Landmark",
            title: "Experience the Statue of Liberty",
            src: "/hero/liberty.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Statue_of_Liberty")!
        ),
        Destination(
            category: "Architecture",
            title: "Admire the Sydney Opera House",
            src: "/hero/sydney.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Sydney_Opera_House")!
        ),
        Destination(
            category: "Adventure",
            title: "Conquer Mount Everest",
            src: "/hero/everest.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Mount_Everest")!
        ),
        Destination(
            category: "Ancient History",
            title: "Unlock the mystery of Stonehenge",
            src: "/hero/stonehenge.webp",
            link: URL(string: "https://en.wikipedia.org/wiki/Stonehenge")!
        )
    ]
}


