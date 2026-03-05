// Note: UserBadge is defined in CommonTypes.swift
import Foundation

// MARK: - Review Model
struct Review: Identifiable, Codable {
    let id: UUID
    let targetId: UUID // Vendor OR Deal ID
    let targetType: ReviewTargetType
    let author: ReviewAuthor
    let rating: Double // 1.0 - 5.0
    let title: String
    let content: String
    let photos: [String] // Image names
    let visitDate: Date?
    let mealType: MealType?
    let partySize: Int?
    let helpfulVotes: Int
    let unhelpfulVotes: Int
    let isVerifiedPurchase: Bool
    let isVerifiedVisit: Bool // GPS verified
    let vendorResponse: VendorResponse?
    let tags: [ReviewTag]
    let createdAt: Date
    let updatedAt: Date?
}

enum ReviewTargetType: String, Codable, Hashable {
    case vendor = "vendor"
    case deal = "deal"
    case event = "event"
}

struct ReviewAuthor: Codable {
    let id: UUID
    let name: String
    let avatarImage: String?
    let reviewCount: Int
    let helpfulVotesReceived: Int
    let memberSince: Date
    let isTopContributor: Bool
    let badges: [UserBadge]
}

enum MealType: String, Codable, CaseIterable, Hashable {
    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case lateNight = "Late Night"
}

struct VendorResponse: Codable, Hashable {
    let content: String
    let respondedAt: Date
    let respondedBy: String // Manager name
}

enum ReviewTag: String, Codable, CaseIterable, Hashable {
    case greatService = "Great Service"
    case deliciousFood = "Delicious Food"
    case goodValue = "Good Value"
    case authentic = "Authentic"
    case spicy = "Spicy"
    case familyFriendly = "Family Friendly"
    case romantic = "Romantic"
    case quickService = "Quick Service"
    case generousPortions = "Generous Portions"
    case clean = "Clean"
    case greatAmbiance = "Great Ambiance"
    case vegetarianFriendly = "Vegetarian Friendly"
    case veganOptions = "Vegan Options"
    case goodForGroups = "Good for Groups"
    case hiddenGem = "Hidden Gem"
    case overrated = "Overrated"
    case expensive = "Expensive"
    case rudeStaff = "Rude Staff"
    case longWait = "Long Wait"
    case coldFood = "Cold Food"
    
    var isPositive: Bool {
        switch self {
        case .greatService, .deliciousFood, .goodValue, .authentic, .spicy,
                .familyFriendly, .romantic, .quickService, .generousPortions,
                .clean, .greatAmbiance, .vegetarianFriendly, .veganOptions,
                .goodForGroups, .hiddenGem:
            return true
        case .overrated, .expensive, .rudeStaff, .longWait, .coldFood:
            return false
        }
    }
    
    var icon: String {
        switch self {
        case .greatService: return "👏"
        case .deliciousFood: return "😋"
        case .goodValue: return "💰"
        case .authentic: return "🇮🇳"
        case .spicy: return "🌶️"
        case .familyFriendly: return "👨‍👩‍👧‍👦"
        case .romantic: return "💕"
        case .quickService: return "⚡"
        case .generousPortions: return "🍽️"
        case .clean: return "✨"
        case .greatAmbiance: return "🎵"
        case .vegetarianFriendly: return "🥬"
        case .veganOptions: return "🌱"
        case .goodForGroups: return "👥"
        case .hiddenGem: return "💎"
        case .overrated: return "📉"
        case .expensive: return "💸"
        case .rudeStaff: return "😤"
        case .longWait: return "⏰"
        case .coldFood: return "🥶"
        }
    }
}

// MARK: - Review Summary
struct ReviewSummary: Codable, Hashable {
    let averageRating: Double
    let totalReviews: Int
    let fiveStar: Int
    let fourStar: Int
    let threeStar: Int
    let twoStar: Int
    let oneStar: Int
    let tagCounts: [ReviewTag: Int]
    
    var ratingDistribution: [(rating: Int, count: Int, percentage: Double)] {
        let total = Double(totalReviews)
        guard total > 0 else { return [] }
        return [
            (5, fiveStar, Double(fiveStar) / total * 100),
            (4, fourStar, Double(fourStar) / total * 100),
            (3, threeStar, Double(threeStar) / total * 100),
            (2, twoStar, Double(twoStar) / total * 100),
            (1, oneStar, Double(oneStar) / total * 100)
        ]
    }
}

// MARK: - Review Sort Options
enum ReviewSortOption: String, CaseIterable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case highestRated = "Highest Rated"
    case lowestRated = "Lowest Rated"
    case mostHelpful = "Most Helpful"
    case verifiedOnly = "Verified Only"
}
