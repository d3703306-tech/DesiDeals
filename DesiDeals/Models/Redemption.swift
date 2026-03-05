import Foundation
import CoreLocation

// MARK: - Deal Redemption
struct Redemption: Identifiable, Codable, Hashable {
    let id: UUID
    let dealId: UUID
    let userId: UUID
    let vendorId: UUID
    let code: String // QR/Barcode data
    let status: RedemptionStatus
    let createdAt: Date
    let expiresAt: Date
    let redeemedAt: Date?
    let redeemedLocation: CLLocationCoordinate2D?
    let redeemedByStaffName: String?
    let billAmount: Double? // Actual bill for analytics
    let savingsAmount: Double?
    let reviewPromptedAt: Date?
    let reviewCompleted: Bool
}

enum RedemptionStatus: String, Codable, CaseIterable, Hashable {
    case active = "Active"
    case used = "Used"
    case expired = "Expired"
    case cancelled = "Cancelled"
    case refunded = "Refunded"
}

// MARK: - QR Code Data Structure
struct RedemptionQRData: Codable {
    let redemptionId: UUID
    let dealId: UUID
    let userId: UUID
    let vendorId: UUID
    let timestamp: Date
    let signature: String // For security verification
    
    var qrString: String? {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
}

// MARK: - Saved Deal (User's saved/wishlist)
struct SavedDeal: Identifiable, Codable, Hashable {
    let id: UUID
    let dealId: UUID
    let userId: UUID
    let savedAt: Date
    let reminderDate: Date? // Remind me before expiry
    let notes: String?
}

// MARK: - Favorite Vendor
struct FavoriteVendor: Identifiable, Codable, Hashable {
    let id: UUID
    let vendorId: UUID
    let userId: UUID
    let favoritedAt: Date
    let notifyNewDeals: Bool
    let visitCount: Int
}

// MARK: - Check In
struct CheckIn: Identifiable, Codable, Hashable {
    let id: UUID
    let vendorId: UUID
    let userId: UUID
    let timestamp: Date
    let location: CLLocationCoordinate2D?
    let isVerified: Bool // GPS matches vendor location
    let photos: [String]
    let notes: String?
    let isPublic: Bool
}

// MARK: - Points Transaction
struct PointsTransaction: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let amount: Int // Positive for earned, negative for spent
    let type: PointsTransactionType
    let description: String
    let relatedId: UUID? // Deal, Review, etc.
    let timestamp: Date
    let balanceAfter: Int
}

enum PointsTransactionType: String, Codable, Hashable {
    case dealRedemption = "Deal Redemption"
    case reviewPosted = "Review Posted"
    case reviewHelpful = "Helpful Review"
    case photoUploaded = "Photo Uploaded"
    case checkIn = "Check In"
    case referral = "Referral"
    case socialShare = "Social Share"
    case dailyLogin = "Daily Login"
    case streakBonus = "Streak Bonus"
    case tierBonus = "Tier Bonus"
    case rewardRedeemed = "Reward Redeemed"
    case expired = "Points Expired"
}

// MARK: - Notification
struct AppNotification: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let type: NotificationType
    let title: String
    let message: String
    let relatedId: UUID? // Deal, Vendor, Review ID
    let imageName: String?
    let isRead: Bool
    let createdAt: Date
    let actionURL: String?
}

enum NotificationType: String, Codable, Hashable {
    case newDeal = "New Deal"
    case dealExpiring = "Deal Expiring Soon"
    case dealRedeemed = "Deal Redeemed"
    case reviewHelpful = "Review Marked Helpful"
    case reviewResponse = "Vendor Responded"
    case tierUpgrade = "Tier Upgraded"
    case badgeEarned = "Badge Earned"
    case nearbyDeal = "Deal Nearby"
    case eventReminder = "Event Reminder"
    case system = "System"
}
