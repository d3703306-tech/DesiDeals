import Foundation
import CoreLocation

// MARK: - Shared Enums and Types
// This file contains types shared across multiple model files

enum DallasArea: String, CaseIterable, Hashable {
    case all = "All Areas"
    case dallas = "Dallas"
    case frisco = "Frisco"
    case plano = "Plano"
    case irving = "Irving"
    case richardson = "Richardson"
    case carrollton = "Carrollton"
    case addison = "Addison"
    case allen = "Allen"
    case mckinney = "McKinney"
    case southlake = "Southlake"
    case celina = "Celina"
}

enum CuisineType: String, Codable, CaseIterable, Hashable {
    case northIndian = "North Indian"
    case southIndian = "South Indian"
    case hyderabadi = "Hyderabadi"
    case punjabi = "Punjabi"
    case gujarati = "Gujarati"
    case bengali = "Bengali"
    case fusion = "Fusion"
    case streetFood = "Street Food"
    case homeStyle = "Home Style"
    case tandoori = "Tandoori"
    case buffet = "Buffet"
    case chaat = "Chaat"
    case biryani = "Biryani"
    
    var icon: String {
        switch self {
        case .northIndian: return "🍛"
        case .southIndian: return "🍘"
        case .hyderabadi: return "🥘"
        case .punjabi: return "🍲"
        case .gujarati: return "🍽️"
        case .bengali: return "🐟"
        case .fusion: return "🍜"
        case .streetFood: return "🌮"
        case .homeStyle: return "🏠"
        case .tandoori: return "🔥"
        case .buffet: return "🍴"
        case .chaat: return "🥙"
        case .biryani: return "🍚"
        }
    }
}

enum PriceRange: String, Codable, CaseIterable, Hashable {
    case low = "$"
    case medium = "$$"
    case high = "$$$"
    case luxury = "$$$$"
}

struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - User Badges
enum UserBadge: String, Codable, CaseIterable, Hashable {
    case firstReview = "First Review"
    case dealHunter = "Deal Hunter"
    case foodCritic = "Food Critic"
    case explorer = "Explorer"
    case loyalCustomer = "Loyal Customer"
    case helpfulReviewer = "Helpful Reviewer"
    case trendSetter = "Trend Setter"
    case nightOwl = "Night Owl"
    case earlyBird = "Early Bird"
    case vegetarian = "Veggie Lover"
    case spiceKing = "Spice King"
    case sweetTooth = "Sweet Tooth"
    case socialButterfly = "Social Butterfly"
    case topContributor = "Top Contributor"
    case founder = "Founding Member"
    
    var icon: String {
        switch self {
        case .firstReview: return "✍️"
        case .dealHunter: return "🏹"
        case .foodCritic: return "🍽️"
        case .explorer: return "🧭"
        case .loyalCustomer: return "❤️"
        case .helpfulReviewer: return "👍"
        case .trendSetter: return "🔥"
        case .nightOwl: return "🦉"
        case .earlyBird: return "🐦"
        case .vegetarian: return "🥗"
        case .spiceKing: return "🌶️"
        case .sweetTooth: return "🍰"
        case .socialButterfly: return "🦋"
        case .topContributor: return "⭐"
        case .founder: return "🚀"
        }
    }
    
    var description: String {
        switch self {
        case .firstReview: return "Posted your first review"
        case .dealHunter: return "Redeemed 10+ deals"
        case .foodCritic: return "Posted 50+ reviews"
        case .explorer: return "Visited 20+ different vendors"
        case .loyalCustomer: return "5+ visits to same vendor"
        case .helpfulReviewer: return "100+ helpful votes received"
        case .trendSetter: return "First to review 10+ new places"
        case .nightOwl: return "10+ late night redemptions"
        case .earlyBird: return "10+ breakfast/brunch redemptions"
        case .vegetarian: return "15+ vegetarian deal redemptions"
        case .spiceKing: return "Known for spicy food reviews"
        case .sweetTooth: return "10+ dessert deal redemptions"
        case .socialButterfly: return "Shared 20+ deals with friends"
        case .topContributor: return "Top 1% of reviewers"
        case .founder: return "Joined in the first month"
        }
    }
}
