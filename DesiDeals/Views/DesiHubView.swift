// MARK: - Main Desi Hub View
import SwiftUI

struct DesiHubView: View {
    @StateObject private var viewModel = DesiHubViewModel()
    @State private var showAddListing = false
    @State private var selectedTab: HubTab = .browse
    
    enum HubTab {
        case browse, map, profile
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                categoryScrollView
                
                // Main Content
                TabView(selection: $selectedTab) {
                    browseView
                        .tag(HubTab.browse)
                    
                    ListingMapView(listings: viewModel.filteredListings)
                        .tag(HubTab.map)
                    
                    DesiHubProfileView()
                        .tag(HubTab.profile)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Desi Hub")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddListing = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .sheet(isPresented: $showAddListing) {
                AddListingView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .accentColor(.orange)
    }
    
    // MARK: - Category Scroll View
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All category
                CategoryPill(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .gray,
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    withAnimation {
                        viewModel.selectedCategory = nil
                    }
                }
                
                ForEach(ListingCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.swiftColor.color,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Browse View
    private var browseView: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            searchAndFilterBar
                .padding()
            
            // Listings List
            listingsList
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search listings...", text: $viewModel.searchText)
                    .autocorrectionDisabled()
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Neighborhood Filter
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.orange)
                
                Picker("Neighborhood", selection: $viewModel.selectedNeighborhood) {
                    Text("All Areas")
                        .tag(nil as DallasNeighborhood?)
                    
                    ForEach(DallasNeighborhood.allCases, id: \.self) { neighborhood in
                        Text(neighborhood.rawValue)
                            .tag(neighborhood as DallasNeighborhood?)
                    }
                }
                .pickerStyle(.menu)
                
                Spacer()
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var listingsList: some View {
        Group {
            if viewModel.isLoading && viewModel.filteredListings.isEmpty {
                ProgressView("Loading listings...")
                    .frame(maxHeight: .infinity)
            } else if viewModel.filteredListings.isEmpty {
                ContentUnavailableView {
                    Label("No Listings", systemImage: "doc.text.magnifyingglass")
                } description: {
                    Text(viewModel.searchText.isEmpty && viewModel.selectedCategory == nil && viewModel.selectedNeighborhood == nil
                         ? "Be the first to post a listing!"
                         : "Try adjusting your filters")
                } actions: {
                    Button("Add Listing") {
                        showAddListing = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredListings) { listing in
                            NavigationLink {
                                ListingDetailView(listing: listing)
                            } label: {
                                ListingCard(
                                    listing: listing,
                                    isFavorite: viewModel.isFavorite(listing.id ?? ""),
                                    onFavoriteToggle: {
                                        viewModel.toggleFavorite(for: listing.id ?? "")
                                    },
                                    onFlag: { reason in
                                        viewModel.flagListing(listing, reason: reason)
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DesiHubView()
}
