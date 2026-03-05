import SwiftUI

struct DealsView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var showFilters = false
    @State private var selectedCategoryTab: CategoryTab = .all
    
    enum CategoryTab: String, CaseIterable {
        case all = "All"
        case restaurants = "Food"
        case groceries = "Grocery"
        case services = "Services"
    }
    
    var displayedDeals: [Deal] {
        switch selectedCategoryTab {
        case .all:
            return viewModel.filteredDeals
        case .restaurants:
            return viewModel.restaurantDeals
        case .groceries:
            return viewModel.groceryDeals
        case .services:
            return viewModel.serviceDeals
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        headerView
                        
                        // Search Bar
                        searchBar
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        
                        // Category Tabs
                        categoryTabs
                        
                        // Area Filter
                        areaFilterScroll
                        
                        // Featured Deals Section
                        if !viewModel.featuredDeals.isEmpty && selectedCategoryTab == .all {
                            featuredSection
                        }
                        
                        // Deals List
                        dealsList
                    }
                }
            }
            .navigationTitle("Hot Deals 🔥")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet()
                    .environmentObject(viewModel)
            }
            .navigationDestination(for: Deal.self) { deal in
                DealDetailView(deal: deal)
                    .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Discover Amazing Indian Food Deals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CategoryTab.allCases, id: \.self) { tab in
                    CategoryTabButton(
                        title: tab.rawValue,
                        isSelected: selectedCategoryTab == tab,
                        count: countForTab(tab)
                    ) {
                        withAnimation(.spring()) {
                            selectedCategoryTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
    
    private func countForTab(_ tab: CategoryTab) -> Int {
        switch tab {
        case .all: return viewModel.deals.count
        case .restaurants: return viewModel.deals.filter { $0.category.vendorType == .restaurant }.count
        case .groceries: return viewModel.deals.filter { $0.category.vendorType == .groceryStore }.count
        case .services: return viewModel.deals.filter { [.catering, .delivery, .cookingClass].contains($0.category) }.count
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.title3)
            
            TextField("Search deals, restaurants, groceries...", text: $viewModel.searchText)
                .font(.body)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Area Filter Scroll
    private var areaFilterScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DallasArea.allCases, id: \.self) { area in
                    AreaPill(
                        area: area,
                        isSelected: viewModel.selectedArea == area
                    ) {
                        withAnimation(.spring()) {
                            viewModel.selectedArea = area
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured 🔥")
                    .font(.title2.bold())
                
                Spacer()
                
                Button("See All") {}
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredDeals) { deal in
                        NavigationLink(value: deal) {
                            FeaturedDealCard(deal: deal)
                                .environmentObject(viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Deals List
    private var dealsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(selectedCategoryTab.rawValue) Deals")
                    .font(.title2.bold())
                
                Spacer()
                
                Menu {
                    ForEach(DealSortOption.allCases, id: \.self) { option in
                        Button(action: { viewModel.selectedSortOption = option }) {
                            Label(option.rawValue, systemImage: viewModel.selectedSortOption == option ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
                
                Text("\(displayedDeals.count) found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Veg Only Toggle
            HStack {
                Toggle("Vegetarian Only", isOn: $viewModel.showVegOnly)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                
                Spacer()
            }
            .padding(.horizontal)
            
            if displayedDeals.isEmpty {
                EmptyStateView(message: "No deals found")
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(displayedDeals) { deal in
                        NavigationLink(value: deal) {
                            ElegantDealCard(deal: deal)
                                .environmentObject(viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Category Tab Button
struct CategoryTabButton: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 16)
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

// MARK: - Area Pill
struct AreaPill: View {
    let area: DallasArea
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(area.rawValue)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .padding(.horizontal, 16)
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

// MARK: - Elegant Deal Card
struct ElegantDealCard: View {
    let deal: Deal
    @EnvironmentObject var viewModel: ContentViewModel
    
    var vendor: Vendor? {
        viewModel.getVendor(for: deal.vendorId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area with Deal Badge
            ZStack(alignment: .topLeading) {
                // Image
                Image(deal.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.black.opacity(0.1))
                    )
                
                // Deal Type Badge
                HStack {
                    Text(deal.dealType.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(dealTypeColor)
                        )
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if deal.isVeg {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(12)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Vendor Info
                if let vendor = vendor {
                    HStack(spacing: 4) {
                        Image(systemName: vendor.vendorType.icon)
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(vendor.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        Text("• \(vendor.city)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Title
                Text(deal.title)
                    .font(.title3.bold())
                    .lineLimit(2)
                
                // Description
                Text(deal.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Price Row
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    if let discount = deal.discountPercentage {
                        Text("\(discount)% OFF")
                            .font(.title3.bold())
                            .foregroundColor(.red)
                    } else if let discounted = deal.discountedPrice {
                        Text("$")
                            .font(.caption)
                        + Text(String(format: "%.0f", discounted))
                            .font(.title2.bold())
                    }
                    
                    if let original = deal.originalPrice {
                        Text("$")
                            .font(.caption)
                        + Text(String(format: "%.0f", original))
                            .font(.subheadline)
                            .strikethrough()
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Category Badge
                    HStack(spacing: 4) {
                        Text(deal.category.icon)
                        Text(deal.category.rawValue)
                            .font(.caption)
                    }
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                }
                
                // Validity Info
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(deal.validDays.map(\.rawValue).joined(separator: ", "))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let expiry = deal.validUntil {
                        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
                        
                        if daysLeft <= 3 && daysLeft >= 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                Text(daysLeft == 0 ? "Ends today" : "\(daysLeft) days left")
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    if deal.isLimitedTime {
                        Text("⚡ Limited")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
    }
    
    private var dealTypeColor: Color {
        switch deal.dealType {
        case .bogo: return .green
        case .percentage: return .red
        case .fixedPrice: return .blue
        case .happyHour: return .orange
        case .combo: return .purple
        case .unlimited: return .pink
        case .flashSale: return .yellow
        case .firstVisit: return .cyan
        case .loyalty: return .indigo
        }
    }
}

// MARK: - Featured Deal Card
struct FeaturedDealCard: View {
    let deal: Deal
    @EnvironmentObject var viewModel: ContentViewModel
    
    var vendor: Vendor? {
        viewModel.getVendor(for: deal.vendorId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .bottomLeading) {
                Image(deal.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(0.2))
                    )
                
                // Gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 280, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Info on image
                VStack(alignment: .leading, spacing: 4) {
                    Text(deal.dealType.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    if let expiry = deal.validUntil {
                        Text("Expires \(expiry, style: .date)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(12)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(deal.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let vendor = vendor {
                    Text(vendor.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    if let discount = deal.discountPercentage {
                        Text("\(discount)% OFF")
                            .font(.title3.bold())
                            .foregroundColor(.red)
                    } else if let discounted = deal.discountedPrice {
                        Text("$")
                            .font(.caption)
                        + Text(String(format: "%.0f", discounted))
                            .font(.title3.bold())
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text("\(deal.redemptionCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(12)
        }
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

#Preview {
    DealsView()
        .environmentObject(ContentViewModel())
}
