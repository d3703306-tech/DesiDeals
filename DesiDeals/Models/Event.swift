import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: UUID
    let restaurantId: UUID
    let title: String
    let description: String
    let eventType: EventType
    let date: Date
    let endDate: Date?
    let entryFee: Double?
    let ageRestriction: AgeRestriction
    let musicGenre: MusicGenre?
    let performers: [String]?
    let imageName: String
    let dressCode: DressCode?
    let specialGuests: [String]?
    let ticketURL: String?
}

enum EventType: String, Codable, CaseIterable, Hashable {
    case djNight = "DJ Night"
    case liveMusic = "Live Music"
    case bollywoodNight = "Bollywood Night"
    case comedyNight = "Comedy Night"
    case karaoke = "Karaoke"
    case culturalNight = "Cultural Night"
    case newYear = "New Year Party"
    case diwali = "Diwali Party"
    case holi = "Holi Party"
    case ladiesNight = "Ladies Night"
    case brunch = "Sunday Brunch"
    case wineTasting = "Wine & Dine"
    
    var icon: String {
        switch self {
        case .djNight: return "headphones"
        case .liveMusic: return "music.note"
        case .bollywoodNight: return "film"
        case .comedyNight: return "face.smiling"
        case .karaoke: return "microphone"
        case .culturalNight: return "globe"
        case .newYear: return "sparkles"
        case .diwali: return "sparkle"
        case .holi: return "paintbrush"
        case .ladiesNight: return "wineglass"
        case .brunch: return "sun.max"
        case .wineTasting: return "wineglass.fill"
        }
    }
    
    var color: String {
        switch self {
        case .djNight: return "purple"
        case .liveMusic: return "pink"
        case .bollywoodNight: return "orange"
        case .comedyNight: return "yellow"
        case .karaoke: return "green"
        case .culturalNight: return "red"
        case .newYear: return "blue"
        case .diwali: return "yellow"
        case .holi: return "pink"
        case .ladiesNight: return "purple"
        case .brunch: return "orange"
        case .wineTasting: return "red"
        }
    }
}

enum AgeRestriction: String, Codable, CaseIterable, Hashable {
    case allAges = "All Ages"
    case eighteenPlus = "18+"
    case twentyOnePlus = "21+"
}

enum MusicGenre: String, Codable, CaseIterable, Hashable {
    case bollywood = "Bollywood"
    case punjabi = "Punjabi/Bhangra"
    case edm = "EDM"
    case hipHop = "Hip Hop"
    case retro = "Retro/Classic"
    case fusion = "Fusion"
    case classical = "Classical"
    case pop = "Pop"
}

enum DressCode: String, Codable, CaseIterable, Hashable {
    case casual = "Casual"
    case smartCasual = "Smart Casual"
    case ethnic = "Ethnic/Traditional"
    case formal = "Formal"
    case partyWear = "Party Wear"
}
