import Foundation
import CoreLocation

// Note: DallasArea, CuisineType, PriceRange, Coordinate are now defined in CommonTypes.swift

struct Restaurant: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let cuisine: [CuisineType]
    let address: String
    let city: String
    let phone: String
    let imageName: String
    let rating: Double
    let reviewCount: Int
    let priceRange: PriceRange
    let coordinates: Coordinate
    let hours: String
    
    var fullAddress: String {
        "\(address), \(city), TX"
    }
}
