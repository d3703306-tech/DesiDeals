import SwiftUI
import Combine

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showingAddListing = false
    @State private var showingMapView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Search Header
                    SearchHeader(
                        searchText: $viewModel.searchText,
                        onSearch: { viewModel.performSearch() }
                    )
                    
                    // Category Segmented Picker
                    CategoryPicker(selectedCategory: $viewModel.selectedCategory)
                        .padding(.vertical, 8)
                    
                    // Filter Bar
                    FilterBar(
                        selectedNeighborhood: $viewModel.selectedNeighborhood,
                        priceRange: $viewModel.priceRange
                    )
                    
                    // Listings
                    if viewModel.isLoading {
                        LoadingView()
                    } else if viewModel.listings.isEmpty {
                        EmptyStateView(
                            message: viewModel.searchText.isEmpty 
                                ? "No listings found in this category"
                                : "No results for '\(viewModel.searchText)'"
                        )
                    } else {
                        ListingsList(
                            listings: viewModel.listings,
                            onListingTap: { listing in
                                viewModel.selectedListing = listing
                            },
                            onFlag: { listing in
                                viewModel.flagListing(listing)
                            }
                        )
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddListing = true }) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Desi Hub 🏘️")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingMapView = true }) {
                        Image(systemName: "map.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddListing) {
                AddListingView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingMapView) {
                CommunityMapView(listings: viewModel.listings)
            }
            .navigationDestination(item: $viewModel.selectedListing) { listing in
                CommunityListingDetailView(listing: listing)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Search Header
struct SearchHeader: View {
    @Binding var searchText: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search housing, jobs, services...", text: $searchText)
                .submitLabel(.search)
                .onSubmit(onSearch)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }
}

// MARK: - Category Picker
struct CategoryPicker: View {
    @Binding var selectedCategory: ListingCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All Categories
                CommunityCategoryPill(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring()) {
                        selectedCategory = nil
                    }
                }
                
                // Individual Categories
                ForEach(ListingCategory.allCases, id: \.self) { category in
                    CommunityCategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CommunityCategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .fontWeight(isSelected ? .semibold : .medium)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.orange : Color(.secondarySystemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Bar
struct FilterBar: View {
    @Binding var selectedNeighborhood: DallasNeighborhood?
    @Binding var priceRange: ClosedRange<Double>?
    @State private var showingFilterSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Neighborhood Filter
            Menu {
                Button("All Neighborhoods") {
                    selectedNeighborhood = nil
                }
                
                ForEach(DallasNeighborhood.allCases, id: \.self) { neighborhood in
                    Button(neighborhood.rawValue) {
                        selectedNeighborhood = neighborhood
                    }
                }
            } label: {
                FilterTag(
                    title: selectedNeighborhood?.rawValue ?? "Neighborhood",
                    icon: "mappin",
                    isActive: selectedNeighborhood != nil
                )
            }
            
            // Price Filter
            Button(action: { showingFilterSheet = true }) {
                FilterTag(
                    title: "Price",
                    icon: "dollarsign.circle",
                    isActive: priceRange != nil
                )
            }
            
            Spacer()
            
            // Clear Filters
            if selectedNeighborhood != nil || priceRange != nil {
                Button(action: {
                    selectedNeighborhood = nil
                    priceRange = nil
                }) {
                    Text("Clear")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FilterTag: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.orange.opacity(0.1) : Color(.secondarySystemBackground))
        .foregroundColor(isActive ? .orange : .primary)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isActive ? Color.orange : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Listings List
struct ListingsList: View {
    let listings: [CommunityListing]
    let onListingTap: (CommunityListing) -> Void
    let onFlag: (CommunityListing) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(listings) { listing in
                    CommunityListingCard(
                        listing: listing,
                        onTap: { onListingTap(listing) },
                        onFlag: { onFlag(listing) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Listing Card
struct CommunityListingCard: View {
    let listing: CommunityListing
    let onTap: () -> Void
    let onFlag: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Image
                ZStack(alignment: .topTrailing) {
                    if let firstImage = listing.imageURLs.first {
                        AsyncImage(url: URL(string: firstImage)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.secondarySystemBackground))
                        }
                    } else {
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                            )
                    }
                    
                    // Featured Badge
                    if listing.isFeatured {
                        Text("Featured")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                    
                    // Category Badge
                    HStack {
                        Image(systemName: listing.category.icon)
                            .font(.caption)
                        Text(listing.category.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(listing.title)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Price
                        if let price = listing.price {
                            Text(formatPrice(price))
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                        } else {
                            Text(listing.priceType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(listing.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        // Location
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.caption)
                            Text(listing.neighborhood.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        
                        // Time
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text(timeAgo(from: listing.timestamp))
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Views
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                                .font(.caption)
                            Text("\(listing.viewCount)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price == 0 {
            return "Free"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$$$"
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Community Listing Detail
struct CommunityListingDetailView: View {
    let listing: CommunityListing
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let firstImage = listing.imageURLs.first,
                   let url = URL(string: firstImage) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                Text(listing.title)
                    .font(.title2.bold())
                
                HStack(spacing: 12) {
                    Label(listing.category.rawValue, systemImage: listing.category.icon)
                    Label(listing.neighborhood.rawValue, systemImage: "mappin.and.ellipse")
                    Label(listing.price.map(formatPrice) ?? listing.priceType.rawValue, systemImage: "tag")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Text(listing.description)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let contact = listing.contactInfo.preferredContact?.rawValue {
                    Label("Preferred Contact: \(contact)", systemImage: "phone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Label("Posted \(listing.timestamp, style: .relative)", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle(listing.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
}

// MARK: - View Model
class CommunityViewModel: ObservableObject {
    @Published var listings: [CommunityListing] = []
    @Published var featuredListings: [CommunityListing] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: ListingCategory?
    @Published var selectedNeighborhood: DallasNeighborhood?
    @Published var priceRange: ClosedRange<Double>?
    @Published var selectedListing: CommunityListing?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let listingService: ListingServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(listingService: ListingServiceProtocol = MockListingService.shared) {
        self.listingService = listingService
        fetchListings()
    }
    
    func fetchListings() {
        isLoading = true
        
        Task {
            do {
                let listings = try await listingService.fetchListings(
                    category: selectedCategory,
                    neighborhood: selectedNeighborhood
                )
                
                await MainActor.run {
                    self.listings = listings
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func performSearch() {
        isLoading = true
        
        Task {
            do {
                let filter = ListingFilter(
                    category: selectedCategory,
                    neighborhood: selectedNeighborhood,
                    minPrice: priceRange?.lowerBound,
                    maxPrice: priceRange?.upperBound,
                    searchText: searchText
                )
                
                let results = try await listingService.searchListings(
                    query: searchText,
                    filters: filter
                )
                
                await MainActor.run {
                    self.listings = results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    func flagListing(_ listing: CommunityListing) {
        Task {
            do {
                try await listingService.flagListing(listingId: listing.id ?? "")
                await MainActor.run {
                    // Show success message
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}

// MARK: - Listing Service Protocol + Mock Implementation
protocol ListingServiceProtocol {
    func fetchListings(
        category: ListingCategory?,
        neighborhood: DallasNeighborhood?
    ) async throws -> [CommunityListing]
    func searchListings(
        query: String,
        filters: ListingFilter
    ) async throws -> [CommunityListing]
    func flagListing(listingId: String) async throws
}

final class MockListingService: ListingServiceProtocol {
    static let shared = MockListingService()
    private init() {}
    
    func fetchListings(
        category: ListingCategory?,
        neighborhood: DallasNeighborhood?
    ) async throws -> [CommunityListing] {
        let filters = ListingFilter(
            category: category,
            neighborhood: neighborhood,
            minPrice: nil,
            maxPrice: nil,
            searchText: ""
        )
        return applyFilters(filters, to: MockData.communityListings)
    }
    
    func searchListings(
        query: String,
        filters: ListingFilter
    ) async throws -> [CommunityListing] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = applyFilters(filters, to: MockData.communityListings)
        guard !trimmedQuery.isEmpty else { return filtered }
        return filtered.filter {
            $0.title.localizedCaseInsensitiveContains(trimmedQuery) ||
            $0.description.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }
    
    func flagListing(listingId: String) async throws {
        // No-op for mock service; real implementation would update backend
    }
    
    private func applyFilters(
        _ filters: ListingFilter,
        to listings: [CommunityListing]
    ) -> [CommunityListing] {
        listings.filter { listing in
            let matchesCategory = filters.category.map { listing.category == $0 } ?? true
            let matchesNeighborhood = filters.neighborhood.map { listing.neighborhood == $0 } ?? true
            let matchesMinPrice = filters.minPrice.map { (listing.price ?? 0) >= $0 } ?? true
            let matchesMaxPrice = filters.maxPrice.map { (listing.price ?? 0) <= $0 } ?? true
            return matchesCategory && matchesNeighborhood && matchesMinPrice && matchesMaxPrice
        }
    }
}

#Preview {
    CommunityView()
}
