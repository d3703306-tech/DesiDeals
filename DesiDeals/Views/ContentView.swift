import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                DealsView()
            }
            .tabItem {
                Label("Deals", systemImage: "tag.fill")
            }
            
            NavigationStack {
                EventsView()
            }
            .tabItem {
                Label("Events", systemImage: "party.popper.fill")
            }
            
            NavigationStack {
                VendorsView()
            }
            .tabItem {
                Label("Vendors", systemImage: "storefront.fill")
            }
            
            NavigationStack {
                DesiHubView()
            }
            .tabItem {
                Label("Desi Hub", systemImage: "person.3.fill")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .environmentObject(viewModel)
        .tint(.orange)
    }
}

// MARK: - Vendors View (formerly RestaurantsView)
struct VendorsView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var showFilters = false
    @State private var selectedVendorType: VendorType? = nil
    
    var filteredVendors: [Vendor] {
        viewModel.vendors.filter { vendor in
            let matchesSearch = viewModel.searchText.isEmpty ||
                vendor.name.localizedCaseInsensitiveContains(viewModel.searchText) ||
                vendor.cuisine.contains { $0.rawValue.localizedCaseInsensitiveContains(viewModel.searchText) }
            
            let matchesArea = viewModel.selectedArea == .all || vendor.city == viewModel.selectedArea.rawValue
            
            let matchesType = selectedVendorType == nil || vendor.vendorType == selectedVendorType
            
            return matchesSearch && matchesArea && matchesType
        }
        .sorted { $0.rating > $1.rating }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search
                searchBar
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                
                // Vendor Type Filter
                vendorTypeFilter
                
                // Area Filter
                areaFilterScroll
                
                // Vendors List
                vendorsList
            }
        }
        .navigationTitle("Vendors 🏪")
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
        .navigationDestination(for: Vendor.self) { vendor in
            VendorDetailView(vendor: vendor)
                .environmentObject(viewModel)
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            // Convert legacy Restaurant to Vendor view
            if let vendor = viewModel.vendors.first(where: { $0.id == restaurant.id }) {
                VendorDetailView(vendor: vendor)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Discover the Best Indian Businesses in DFW")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.title3)
            
            TextField("Search restaurants, groceries, catering...", text: $viewModel.searchText)
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
    
    private var vendorTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                TypePill(
                    title: "All",
                    icon: "storefront",
                    isSelected: selectedVendorType == nil
                ) {
                    selectedVendorType = nil
                }
                
                ForEach(VendorType.allCases, id: \.self) { type in
                    TypePill(
                        title: type.rawValue,
                        icon: type.icon,
                        isSelected: selectedVendorType == type
                    ) {
                        selectedVendorType = type
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
    
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
    
    private var vendorsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.selectedArea == .all ? "All Vendors" : viewModel.selectedArea.rawValue)
                    .font(.title2.bold())
                
                Spacer()
                
                Text("\(filteredVendors.count) places")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if filteredVendors.isEmpty {
                EmptyStateView(message: "No vendors found")
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filteredVendors) { vendor in
                        NavigationLink(value: vendor) {
                            ElegantVendorCard(vendor: vendor)
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

// MARK: - Type Pill
struct TypePill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
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

// MARK: - Elegant Vendor Card
struct ElegantVendorCard: View {
    let vendor: Vendor
    @EnvironmentObject var viewModel: ContentViewModel
    
    var dealCount: Int {
        viewModel.getDeals(for: vendor.id).count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            ZStack {
                Image(vendor.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
                
                // Rating Badge
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text(String(format: "%.1f", vendor.rating))
                        .font(.caption2.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.orange)
                .clipShape(Capsule())
                .offset(x: 30, y: -35)
                
                // Vendor Type Icon
                Image(systemName: vendor.vendorType.icon)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .offset(x: -30, y: 35)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Name & Price
                HStack {
                    Text(vendor.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(vendor.priceRange.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Type & Cuisine
                HStack(spacing: 4) {
                    Text(vendor.vendorType.rawValue)
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if !vendor.cuisine.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(vendor.cuisine.prefix(2).map { $0.icon }.joined(separator: " "))
                            .font(.caption)
                    }
                }
                
                // Address
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(vendor.city), TX")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Deals & Reviews Count
                HStack(spacing: 12) {
                    if dealCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(dealCount) deals")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("\(vendor.reviewCount) reviews")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 8)
        )
    }
}

#Preview {
    ContentView()
}
