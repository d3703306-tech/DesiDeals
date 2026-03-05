// MARK: - Desi Hub Profile View (My Listings & Favorites)
import SwiftUI
import Combine
import FirebaseAuth

struct DesiHubProfileView: View {
    @StateObject private var viewModel = DesiHubProfileViewModel()
    @State private var selectedTab: ProfileTab = .myListings
    
    enum ProfileTab {
        case myListings, favorites
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Profile Tab", selection: $selectedTab) {
                Text("My Listings")
                    .tag(ProfileTab.myListings)
                Text("Favorites")
                    .tag(ProfileTab.favorites)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            TabView(selection: $selectedTab) {
                myListingsView
                    .tag(ProfileTab.myListings)
                
                favoritesView
                    .tag(ProfileTab.favorites)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
    
    // MARK: - My Listings View
    private var myListingsView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxHeight: .infinity)
            } else if viewModel.myListings.isEmpty {
                ContentUnavailableView {
                    Label("No Listings", systemImage: "doc.text")
                } description: {
                    Text("You haven't posted any listings yet")
                } actions: {
                    Button("Create Listing") {
                        // This would need to trigger the add listing sheet
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.myListings) { listing in
                            MyListingRow(
                                listing: listing,
                                onDelete: {
                                    viewModel.deleteListing(listing)
                                }
                            )
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refreshMyListings()
                }
            }
        }
    }
    
    // MARK: - Favorites View
    private var favoritesView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxHeight: .infinity)
            } else if viewModel.favoriteListings.isEmpty {
                ContentUnavailableView {
                    Label("No Favorites", systemImage: "heart")
                } description: {
                    Text("Save listings you like by tapping the heart icon")
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.favoriteListings) { listing in
                            NavigationLink {
                                ListingDetailView(listing: listing)
                            } label: {
                                FavoriteListingRow(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refreshFavorites()
                }
            }
        }
    }
}

// MARK: - My Listing Row (with delete)
struct MyListingRow: View {
    let listing: Listing
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            listingThumbnail
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: listing.category.icon)
                            .font(.caption2)
                        Text(listing.category.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(listing.category.swiftColor.color.opacity(0.15))
                    .foregroundStyle(listing.category.swiftColor.color)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    if let price = listing.price {
                        Text(formatPrice(price))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
                
                HStack {
                    Image(systemName: "mappin")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(listing.neighborhood.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    ListingStatusBadge(status: listing.status)
                }
            }
            
            // Delete Button
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .alert("Delete Listing?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var listingThumbnail: some View {
        Group {
            if let firstImage = listing.imageURLs.first {
                AsyncImage(url: URL(string: firstImage)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .overlay(Image(systemName: "photo"))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .overlay(Image(systemName: "photo"))
            }
        }
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
}

// MARK: - Favorite Listing Row
struct FavoriteListingRow: View {
    let listing: Listing
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            Group {
                if let firstImage = listing.imageURLs.first {
                    AsyncImage(url: URL(string: firstImage)) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay(Image(systemName: "photo"))
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: listing.category.icon)
                            .font(.caption2)
                        Text(listing.category.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(listing.category.swiftColor.color.opacity(0.15))
                    .foregroundStyle(listing.category.swiftColor.color)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    if let price = listing.price {
                        Text(formatPrice(price))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
                
                HStack {
                    Image(systemName: "mappin")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(listing.neighborhood.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("By \(listing.authorName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
}

// MARK: - Status Badge
struct ListingStatusBadge: View {
    let status: ListingStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .active:
            return .green
        case .pending:
            return .orange
        case .sold:
            return .blue
        case .flagged:
            return .red
        case .featured:
            return .purple
        }
    }
}

// MARK: - Profile ViewModel
@MainActor
class DesiHubProfileViewModel: ObservableObject {
    @Published var myListings: [Listing] = []
    @Published var favoriteListings: [Listing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let listingService = ListingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listingService.startListeningToUserListings(userId: userId)
        listingService.startListeningToUserFavorites(userId: userId)
        
        // Bind to service data
        listingService.$userListings
            .receive(on: DispatchQueue.main)
            .assign(to: &$myListings)
        
        Task {
            await refreshFavorites()
        }
    }
    
    func refreshMyListings() async {
        isLoading = true
        do { isLoading = false }
        
        // The real-time listener handles updates, but we can trigger a refresh here
    }
    
    func refreshFavorites() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            favoriteListings = try await listingService.fetchFavoriteListings()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteListing(_ listing: Listing) {
        Task {
            do {
                try await listingService.deleteListing(listing)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    DesiHubProfileView()
}
