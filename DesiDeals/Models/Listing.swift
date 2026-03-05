// MARK: - Listing Model for Desi Hub Marketplace
import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

enum ListingCategory: String, CaseIterable, Codable {
    case housing = "Housing"
    case jobs = "Jobs"
    case services = "Services"
    case marketplace = "Marketplace"
    case community = "Community"
    
    var icon: String {
        switch self {
        case .housing: return "house.fill"
        case .jobs: return "briefcase.fill"
        case .services: return "wrench.and.screwdriver.fill"
        case .marketplace: return "cart.fill"
        case .community: return "person.3.fill"
        }
    }
    
    var color: String {
        switch self {
        case .housing: return "blue"
        case .jobs: return "green"
        case .services: return "orange"
        case .marketplace: return "purple"
        case .community: return "pink"
        }
    }
    
    var swiftColor: ColorTheme {
        switch self {
        case .housing: return .blue
        case .jobs: return .green
        case .services: return .orange
        case .marketplace: return .purple
        case .community: return .pink
        }
    }
}

enum ListingStatus: String, Codable, CaseIterable {
    case active = "active"
    case pending = "pending"
    case sold = "sold"
    case flagged = "flagged"
    case featured = "featured"
}

enum DallasNeighborhood: String, CaseIterable, Codable {
    case irving = "Irving"
    case frisco = "Frisco"
    case plano = "Plano"
    case richardson = "Richardson"
    case carrollton = "Carrollton"
    case allen = "Allen"
    case mckinney = "McKinney"
    case farmersBranch = "Farmers Branch"
    case coppell = "Coppell"
    case lewisville = "Lewisville"
    case addison = "Addison"
    case garland = "Garland"
    case mesquite = "Mesquite"
    case dallas = "Dallas"
    
    var coordinate: NeighborhoodCoordinate {
        switch self {
        case .irving:
            return NeighborhoodCoordinate(latitude: 32.8140, longitude: -96.9489)
        case .frisco:
            return NeighborhoodCoordinate(latitude: 33.1507, longitude: -96.8236)
        case .plano:
            return NeighborhoodCoordinate(latitude: 33.0198, longitude: -96.6989)
        case .richardson:
            return NeighborhoodCoordinate(latitude: 32.9482, longitude: -96.7299)
        case .carrollton:
            return NeighborhoodCoordinate(latitude: 32.9537, longitude: -96.8903)
        case .allen:
            return NeighborhoodCoordinate(latitude: 33.1032, longitude: -96.6706)
        case .mckinney:
            return NeighborhoodCoordinate(latitude: 33.1972, longitude: -96.6397)
        case .farmersBranch:
            return NeighborhoodCoordinate(latitude: 32.9266, longitude: -96.8964)
        case .coppell:
            return NeighborhoodCoordinate(latitude: 32.9630, longitude: -97.0150)
        case .lewisville:
            return NeighborhoodCoordinate(latitude: 33.0462, longitude: -96.9942)
        case .addison:
            return NeighborhoodCoordinate(latitude: 32.9612, longitude: -96.8292)
        case .garland:
            return NeighborhoodCoordinate(latitude: 32.9126, longitude: -96.6389)
        case .mesquite:
            return NeighborhoodCoordinate(latitude: 32.7668, longitude: -96.5992)
        case .dallas:
            return NeighborhoodCoordinate(latitude: 32.7767, longitude: -96.7970)
        }
    }
    
    /// Alias used by map views for readability
    var coordinates: NeighborhoodCoordinate { coordinate }
}

struct NeighborhoodCoordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct ContactInfo: Codable, Hashable {
    var phone: String?
    var whatsapp: String?
    var email: String?
    var preferredContact: ContactMethod? = nil
    
    enum ContactMethod: String, Codable, CaseIterable, Hashable {
        case phone = "Phone"
        case whatsapp = "WhatsApp"
        case email = "Email"
    }
}

struct Listing: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var category: ListingCategory
    var price: Double?
    var neighborhood: DallasNeighborhood
    var imageURLs: [String]
    var timestamp: Date
    var contactInfo: ContactInfo
    var authorId: String
    var authorName: String
    var isFeatured: Bool
    var flagCount: Int
    var status: ListingStatus
    
    init(
        id: String? = nil,
        title: String,
        description: String,
        category: ListingCategory,
        price: Double? = nil,
        neighborhood: DallasNeighborhood,
        imageURLs: [String] = [],
        timestamp: Date = Date(),
        contactInfo: ContactInfo,
        authorId: String,
        authorName: String,
        isFeatured: Bool = false,
        flagCount: Int = 0,
        status: ListingStatus = .active
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.price = price
        self.neighborhood = neighborhood
        self.imageURLs = imageURLs
        self.timestamp = timestamp
        self.contactInfo = contactInfo
        self.authorId = authorId
        self.authorName = authorName
        self.isFeatured = isFeatured
        self.flagCount = flagCount
        self.status = status
    }
}

// MARK: - Color Theme Helper
enum ColorTheme: String {
    case blue, green, orange, purple, pink
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        }
    }
}

// MARK: - SwiftUI helpers
extension ListingCategory {
    var swiftUIColor: Color {
        switch self {
        case .housing: return .blue
        case .jobs: return .green
        case .services: return .orange
        case .marketplace: return .purple
        case .community: return .pink
        }
    }
}
