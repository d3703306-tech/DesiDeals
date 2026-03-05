import Foundation

// MARK: - Expanded Deal Model
struct Deal: Identifiable, Codable, Hashable {
    let id: UUID
    let vendorId: UUID
    let title: String
    let description: String
    let dealType: DealType
    let discountPercentage: Int?
    let originalPrice: Double?
    let discountedPrice: Double?
    let validDays: [WeekDay]
    let validUntil: Date?
    let terms: String
    let isVeg: Bool
    let imageName: String
    let category: DealCategory
    let subcategory: String? // Specific item name
    let redemptionCount: Int // How many times redeemed
    let maxRedemptions: Int? // Limit per user
    let isLimitedTime: Bool
    let featuredUntil: Date? // For featured section
    let createdAt: Date
}

enum DealType: String, Codable, CaseIterable, Hashable {
    case bogo = "BOGO"
    case percentage = "% OFF"
    case fixedPrice = "Fixed Price"
    case happyHour = "Happy Hour"
    case combo = "Combo Deal"
    case unlimited = "Unlimited"
    case flashSale = "Flash Sale"
    case firstVisit = "First Visit"
    case loyalty = "Loyalty Reward"
    
    var color: String {
        switch self {
        case .bogo: return "green"
        case .percentage: return "red"
        case .fixedPrice: return "blue"
        case .happyHour: return "orange"
        case .combo: return "purple"
        case .unlimited: return "pink"
        case .flashSale: return "yellow"
        case .firstVisit: return "cyan"
        case .loyalty: return "indigo"
        }
    }
    
    var icon: String {
        switch self {
        case .bogo: return "2.circle"
        case .percentage: return "percent"
        case .fixedPrice: return "tag.fill"
        case .happyHour: return "clock.fill"
        case .combo: return "basket.fill"
        case .unlimited: return "infinity"
        case .flashSale: return "bolt.fill"
        case .firstVisit: return "star.fill"
        case .loyalty: return "heart.fill"
        }
    }
}

enum WeekDay: String, Codable, CaseIterable, Hashable {
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    case sunday = "Sun"
    case allWeek = "Daily"
    case weekdays = "Mon-Fri"
    case weekends = "Sat-Sun"
}

// MARK: - Expanded Deal Categories
enum DealCategory: String, Codable, CaseIterable, Hashable {
    // Restaurant Food (existing)
    case biryani = "Biryani"
    case curry = "Curry"
    case tandoori = "Tandoori"
    case dosa = "Dosa"
    case chaat = "Chaat"
    case thali = "Thali"
    case appetizer = "Appetizer"
    case dessert = "Dessert"
    case drink = "Drink"
    case buffet = "Buffet"
    
    // Grocery (NEW)
    case spices = "Spices"
    case snacks = "Snacks"
    case frozen = "Frozen Foods"
    case sweets = "Sweets & Mithai"
    case beverages = "Beverages"
    case grains = "Rice & Grains"
    case lentils = "Lentils & Beans"
    case pickles = "Pickles & Chutneys"
    case bakery = "Bakery Items"
    case organic = "Organic"
    
    // Services (NEW)
    case catering = "Catering"
    case delivery = "Delivery"
    case cookingClass = "Cooking Class"
    case mealPrep = "Meal Prep"
    
    // Events (NEW)
    case eventTicket = "Event Ticket"
    case workshop = "Workshop"
    
    var icon: String {
        switch self {
        // Restaurant
        case .biryani: return "🍚"
        case .curry: return "🍛"
        case .tandoori: return "🍗"
        case .dosa: return "🥞"
        case .chaat: return "🥘"
        case .thali: return "🍽️"
        case .appetizer: return "🥟"
        case .dessert: return "🍨"
        case .drink: return "🥤"
        case .buffet: return "🍴"
        // Grocery
        case .spices: return "🌶️"
        case .snacks: return "🥨"
        case .frozen: return "🧊"
        case .sweets: return "🍬"
        case .beverages: return "🧃"
        case .grains: return "🌾"
        case .lentils: return "🫘"
        case .pickles: return "🥒"
        case .bakery: return "🥐"
        case .organic: return "🌿"
        // Services
        case .catering: return "🚚"
        case .delivery: return "🛵"
        case .cookingClass: return "👨‍🍳"
        case .mealPrep: return "🍱"
        // Events
        case .eventTicket: return "🎫"
        case .workshop: return "🎨"
        }
    }
    
    var vendorType: VendorType {
        switch self {
        case .biryani, .curry, .tandoori, .dosa, .chaat, .thali, .appetizer, .dessert, .drink, .buffet:
            return .restaurant
        case .spices, .snacks, .frozen, .sweets, .beverages, .grains, .lentils, .pickles, .bakery, .organic:
            return .groceryStore
        case .catering:
            return .cateringService
        case .delivery:
            return .restaurant
        case .cookingClass, .mealPrep:
            return .cloudKitchen
        case .eventTicket, .workshop:
            return .restaurant
        }
    }
}

// MARK: - Deal Filter
enum DealSortOption: String, CaseIterable {
    case newest = "Newest"
    case endingSoon = "Ending Soon"
    case popular = "Most Popular"
    case highestDiscount = "Highest Discount"
    case nearest = "Nearest"
}
