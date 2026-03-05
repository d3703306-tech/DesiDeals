import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Community Listing
struct CommunityListing: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var category: ListingCategory
    var subcategory: String?
    var price: Double?
    var priceType: PriceType
    var neighborhood: DallasNeighborhood
    var city: String
    var imageURLs: [String]
    var timestamp: Date
    var contactInfo: ContactInfo
    var authorId: String
    var authorName: String
    var isFeatured: Bool
    var viewCount: Int
    var status: ListingStatus
    var flaggedCount: Int
}

// MARK: - Community-specific enums
enum PriceType: String, Codable, CaseIterable, Hashable {
    case fixed = "Fixed"
    case negotiable = "Negotiable"
    case free = "Free"
    case contact = "Contact"
}

// MARK: - Listing Filter
struct ListingFilter {
    var category: ListingCategory?
    var neighborhood: DallasNeighborhood?
    var minPrice: Double?
    var maxPrice: Double?
    var searchText: String
    
    static let `default` = ListingFilter(
        category: nil,
        neighborhood: nil,
        minPrice: nil,
        maxPrice: nil,
        searchText: ""
    )
}

// MARK: - Report/Flag Model
struct ListingReport: Identifiable, Codable {
    @DocumentID var id: String?
    var listingId: String
    var reporterId: String
    var reason: String
    var timestamp: Date
    var status: ReportStatus
    
    enum ReportStatus: String, Codable {
        case pending = "pending"
        case resolved = "resolved"
        case dismissed = "dismissed"
    }
}
