import Foundation
import CoreLocation

// MARK: - Unified Vendor Model (Restaurants + Groceries + Catering + etc.)
struct Vendor: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let vendorType: VendorType
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
    let specialties: [String] // Featured items
    let amenities: [Amenity] // WiFi, Parking, etc.
    let isActive: Bool
    let joinedDate: Date
    
    var fullAddress: String {
        "\(address), \(city), TX"
    }
    
    // Computed property for backward compatibility
    var asRestaurant: Restaurant? {
        guard vendorType == .restaurant else { return nil }
        return Restaurant(
            id: id,
            name: name,
            description: description,
            cuisine: cuisine,
            address: address,
            city: city,
            phone: phone,
            imageName: imageName,
            rating: rating,
            reviewCount: reviewCount,
            priceRange: priceRange,
            coordinates: coordinates,
            hours: hours
        )
    }
}

enum VendorType: String, Codable, CaseIterable, Hashable {
    case restaurant = "Restaurant"
    case groceryStore = "Grocery Store"
    case sweetShop = "Sweet Shop"
    case cateringService = "Catering"
    case foodTruck = "Food Truck"
    case cloudKitchen = "Cloud Kitchen"
    case spiceMarket = "Spice Market"
    case bakery = "Bakery"
    
    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .groceryStore: return "cart.fill"
        case .sweetShop: return "birthday.cake.fill"
        case .cateringService: return "truck.box.fill"
        case .foodTruck: return "car.fill"
        case .cloudKitchen: return "house.fill"
        case .spiceMarket: return "leaf.fill"
        case .bakery: return "cup.and.saucer.fill"
        }
    }
    
    var color: String {
        switch self {
        case .restaurant: return "orange"
        case .groceryStore: return "green"
        case .sweetShop: return "pink"
        case .cateringService: return "blue"
        case .foodTruck: return "red"
        case .cloudKitchen: return "purple"
        case .spiceMarket: return "brown"
        case .bakery: return "yellow"
        }
    }
}

enum Amenity: String, Codable, CaseIterable, Hashable {
    case wifi = "WiFi"
    case parking = "Parking"
    case outdoorSeating = "Outdoor Seating"
    case delivery = "Delivery"
    case takeaway = "Takeaway"
    case reservations = "Reservations"
    case wheelchairAccessible = "Wheelchair Accessible"
    case alcohol = "Alcohol"
    case halal = "Halal"
    case vegetarian = "Vegetarian Options"
    case vegan = "Vegan Options"
    case glutenFree = "Gluten Free"
    case liveMusic = "Live Music"
    case privateDining = "Private Dining"
    
    var icon: String {
        switch self {
        case .wifi: return "wifi"
        case .parking: return "car.fill"
        case .outdoorSeating: return "sun.max.fill"
        case .delivery: return "bicycle"
        case .takeaway: return "bag.fill"
        case .reservations: return "calendar"
        case .wheelchairAccessible: return "figure.roll"
        case .alcohol: return "wineglass.fill"
        case .halal: return "h.circle.fill"
        case .vegetarian: return "leaf.fill"
        case .vegan: return "leaf.circle.fill"
        case .glutenFree: return "g.circle.fill"
        case .liveMusic: return "music.note"
        case .privateDining: return "person.2.fill"
        }
    }
}

// Note: Restaurant, CuisineType, PriceRange, Coordinate, DallasArea are defined in Restaurant.swift
