import Foundation
import Combine
import CoreLocation

@MainActor
class ContentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var vendors: [Vendor] = []
    @Published var deals: [Deal] = []
    @Published var events: [Event] = []
    @Published var reviews: [Review] = []
    @Published var currentUser: UserProfile?
    @Published var redemptions: [Redemption] = []
    
    // MARK: - Filter & Search
    @Published var searchText: String = ""
    @Published var selectedArea: DallasArea = .all
    @Published var selectedVendorType: VendorType? = nil
    @Published var selectedCategory: DealCategory? = nil
    @Published var selectedCuisine: CuisineType? = nil
    @Published var selectedSortOption: DealSortOption = .newest
    @Published var showVegOnly: Bool = false
    @Published var showVerifiedReviewsOnly: Bool = false
    
    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasLoadedRealData: Bool = true
    
    // MARK: - Computed Properties
    
    var filteredVendors: [Vendor] {
        vendors.filter { vendor in
            let matchesSearch = searchText.isEmpty ||
                vendor.name.localizedCaseInsensitiveContains(searchText) ||
                vendor.cuisine.contains { $0.rawValue.localizedCaseInsensitiveContains(searchText) } ||
                vendor.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesArea = selectedArea == .all || vendor.city == selectedArea.rawValue
            
            let matchesType = selectedVendorType == nil || vendor.vendorType == selectedVendorType
            
            let matchesCuisine = selectedCuisine == nil || vendor.cuisine.contains(selectedCuisine!)
            
            return matchesSearch && matchesArea && matchesType && matchesCuisine
        }
        .sorted { $0.rating > $1.rating }
    }
    
    var filteredDeals: [Deal] {
        var filtered = deals.filter { deal in
            let matchesSearch = searchText.isEmpty ||
                deal.title.localizedCaseInsensitiveContains(searchText) ||
                deal.description.localizedCaseInsensitiveContains(searchText)
            
            let vendor = getVendor(for: deal.vendorId)
            let matchesArea = selectedArea == .all || vendor?.city == selectedArea.rawValue
            
            let matchesCategory = selectedCategory == nil || deal.category == selectedCategory
            
            let matchesVeg = !showVegOnly || deal.isVeg
            
            return matchesSearch && matchesArea && matchesCategory && matchesVeg
        }
        
        // Sort
        switch selectedSortOption {
        case .newest:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .endingSoon:
            filtered.sort {
                guard let date1 = $0.validUntil else { return false }
                guard let date2 = $1.validUntil else { return true }
                return date1 < date2
            }
        case .popular:
            filtered.sort { $0.redemptionCount > $1.redemptionCount }
        case .highestDiscount:
            filtered.sort {
                let d1 = $0.discountPercentage ?? 0
                let d2 = $1.discountPercentage ?? 0
                return d1 > d2
            }
        case .nearest:
            // Would use actual location in real app
            break
        }
        
        return filtered
    }
    
    var featuredDeals: [Deal] {
        deals
            .filter { $0.featuredUntil != nil && $0.featuredUntil! > Date() }
            .sorted { ($0.featuredUntil ?? Date()) > ($1.featuredUntil ?? Date()) }
    }
    
    var upcomingEvents: [Event] {
        events
            .filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
    }
    
    var filteredEvents: [Event] {
        events.filter { event in
            let matchesSearch = searchText.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText)
            
            let vendor = getVendor(for: event.restaurantId)
            let matchesArea = selectedArea == .all || vendor?.city == selectedArea.rawValue
            
            return matchesSearch && matchesArea
        }
    }
    
    // MARK: - Vendor Type Specific Lists
    var restaurantDeals: [Deal] {
        filteredDeals.filter { $0.category.vendorType == .restaurant }
    }
    
    var groceryDeals: [Deal] {
        filteredDeals.filter { $0.category.vendorType == .groceryStore }
    }
    
    var serviceDeals: [Deal] {
        filteredDeals.filter { [.catering, .delivery, .cookingClass].contains($0.category) }
    }
    
    // MARK: - Init
    init() {
        loadMockData()
    }
    
    // MARK: - Data Loading
    func loadMockData() {
        vendors = MockData.vendors
        deals = MockData.deals
        events = MockData.events
        reviews = MockData.reviews
        currentUser = MockData.currentUser
        redemptions = MockData.redemptions
    }
    
    // MARK: - Helper Methods
    func getVendor(for id: UUID) -> Vendor? {
        vendors.first { $0.id == id }
    }
    
    func getDeals(for vendorId: UUID) -> [Deal] {
        deals.filter { $0.vendorId == vendorId }
    }
    
    func getEvents(for vendorId: UUID) -> [Event] {
        events.filter { $0.restaurantId == vendorId }
    }
    
    func getReviews(for targetId: UUID, type: ReviewTargetType = .vendor) -> [Review] {
        reviews.filter { $0.targetId == targetId && $0.targetType == type }
    }
    
    func getReviewSummary(for targetId: UUID) -> ReviewSummary {
        let targetReviews = getReviews(for: targetId)
        let total = targetReviews.count
        
        guard total > 0 else {
            return ReviewSummary(
                averageRating: 0,
                totalReviews: 0,
                fiveStar: 0,
                fourStar: 0,
                threeStar: 0,
                twoStar: 0,
                oneStar: 0,
                tagCounts: [:]
            )
        }
        
        let ratings = targetReviews.map { $0.rating }
        let average = ratings.reduce(0, +) / Double(total)
        
        var tagCounts: [ReviewTag: Int] = [:]
        for review in targetReviews {
            for tag in review.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return ReviewSummary(
            averageRating: average,
            totalReviews: total,
            fiveStar: targetReviews.filter { $0.rating == 5.0 }.count,
            fourStar: targetReviews.filter { $0.rating >= 4.0 && $0.rating < 5.0 }.count,
            threeStar: targetReviews.filter { $0.rating >= 3.0 && $0.rating < 4.0 }.count,
            twoStar: targetReviews.filter { $0.rating >= 2.0 && $0.rating < 3.0 }.count,
            oneStar: targetReviews.filter { $0.rating >= 1.0 && $0.rating < 2.0 }.count,
            tagCounts: tagCounts
        )
    }
    
    func getRedemptions(for userId: UUID) -> [Redemption] {
        redemptions.filter { $0.userId == userId }
    }
    
    func getActiveRedemptions(for userId: UUID) -> [Redemption] {
        getRedemptions(for: userId).filter { $0.status == .active }
    }
    
    // MARK: - Actions
    func redeemDeal(_ deal: Deal) -> Redemption? {
        guard let userId = currentUser?.id else { return nil }
        
        let redemption = Redemption(
            id: UUID(),
            dealId: deal.id,
            userId: userId,
            vendorId: deal.vendorId,
            code: generateRedemptionCode(),
            status: .active,
            createdAt: Date(),
            expiresAt: deal.validUntil ?? Date().addingTimeInterval(86400 * 7),
            redeemedAt: nil,
            redeemedLocation: nil,
            redeemedByStaffName: nil,
            billAmount: nil,
            savingsAmount: nil,
            reviewPromptedAt: nil,
            reviewCompleted: false
        )
        
        redemptions.append(redemption)
        return redemption
    }
    
    func markReviewHelpful(_ reviewId: UUID) {
        // In real app, would update backend
    }
    
    func saveDeal(_ dealId: UUID) {
        // In real app, would add to saved deals
    }
    
    func favoriteVendor(_ vendorId: UUID) {
        // In real app, would add to favorites
    }
    
    // MARK: - Private Helpers
    private func generateRedemptionCode() -> String {
        let prefix = "DS"
        let random = Int.random(in: 100000...999999)
        return "\(prefix)-\(random)"
    }
}

// MARK: - Formatters
extension ContentViewModel {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}
