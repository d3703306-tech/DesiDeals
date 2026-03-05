import Foundation

// MARK: - User Profile
struct UserProfile: Identifiable, Codable {
    let id: UUID
    let email: String
    let phone: String?
    let name: String
    let avatarImage: String?
    let bio: String?
    let location: String?
    
    // Preferences
    let favoriteAreas: [String]
    let cuisinePreferences: [String]
    let dietaryRestrictions: [DietaryRestriction]
    let pricePreference: String?
    
    // Stats
    let reviewCount: Int
    let helpfulVotesReceived: Int
    let redemptionCount: Int
    let savedDealsCount: Int
    let favoriteVendorsCount: Int
    let streakDays: Int // Consecutive app opens
    
    // Badges
    let badges: [UserBadge]
    
    // Membership
    let memberSince: Date
    let tier: UserTier
    let points: Int
    let isEmailVerified: Bool
    let isPhoneVerified: Bool
    
    // Settings
    let notificationsEnabled: Bool
    let emailNotificationsEnabled: Bool
    let locationEnabled: Bool
    let showProfilePublicly: Bool
}

enum DietaryRestriction: String, Codable, CaseIterable, Hashable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten Free"
    case dairyFree = "Dairy Free"
    case nutFree = "Nut Free"
    case halal = "Halal"
    case kosher = "Kosher"
    case jain = "Jain"
    
    var icon: String {
        switch self {
        case .vegetarian: return "🥬"
        case .vegan: return "🌱"
        case .glutenFree: return "🌾"
        case .dairyFree: return "🥛"
        case .nutFree: return "🥜"
        case .halal: return "☪️"
        case .kosher: return "✡️"
        case .jain: return "🕉️"
        }
    }
}

enum UserTier: String, Codable, CaseIterable, Hashable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    
    var minPoints: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 500
        case .gold: return 2000
        case .platinum: return 5000
        case .diamond: return 10000
        }
    }
    
    var color: String {
        switch self {
        case .bronze: return "brown"
        case .silver: return "gray"
        case .gold: return "yellow"
        case .platinum: return "cyan"
        case .diamond: return "blue"
        }
    }
    
    var benefits: [String] {
        switch self {
        case .bronze:
            return ["Basic deals access"]
        case .silver:
            return ["Basic deals access", "Early access to weekly deals"]
        case .gold:
            return ["All Silver benefits", "Exclusive Gold member deals", "Priority customer support"]
        case .platinum:
            return ["All Gold benefits", "Free event tickets monthly", "Birthday month special offers"]
        case .diamond:
            return ["All Platinum benefits", "Personal concierge", "VIP event access", "No redemption limits"]
        }
    }
}

// Note: UserBadge is defined in CommonTypes.swift

// MARK: - User Activity
enum UserActivityType: String, Codable, Hashable {
    case reviewPosted = "Posted a review"
    case dealRedeemed = "Redeemed a deal"
    case dealSaved = "Saved a deal"
    case vendorFavorited = "Added to favorites"
    case photoUploaded = "Uploaded photos"
    case helpfulVote = "Marked review helpful"
    case checkIn = "Checked in"
    case tierUpgraded = "Tier upgraded"
    case badgeEarned = "Earned badge"
}

struct UserActivity: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let type: UserActivityType
    let description: String
    let relatedId: UUID? // Deal, Vendor, or Review ID
    let pointsEarned: Int
    let timestamp: Date
}
