// MARK: - Listing Card Component
import SwiftUI

struct ListingCard: View {
    let listing: Listing
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onFlag: (String) -> Void
    
    @State private var showFlagDialog = false
    @State private var flagReason = ""
    @State private var currentImageIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Carousel
            imageCarousel
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Category Badge & Price
                HStack {
                    categoryBadge
                    Spacer()
                    if let price = listing.price {
                        Text(formatPrice(price))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                }
                
                // Title
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                
                // Location
                HStack {
                    Image(systemName: "mappin.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(listing.neighborhood.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Author and Date
                HStack {
                    Text("By \(listing.authorName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(formatDate(listing.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(listing.isFeatured ? 0.5 : 0), lineWidth: 2)
        )
    }
    
    // MARK: - Image Carousel
    private var imageCarousel: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentImageIndex) {
                if listing.imageURLs.isEmpty {
                    // Placeholder
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray5))
                } else {
                    ForEach(Array(listing.imageURLs.enumerated()), id: \.offset) { index, url in
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color(.systemGray5))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: listing.imageURLs.count > 1 ? .always : .never))
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            // Action Buttons
            VStack(spacing: 8) {
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isFavorite ? .red : .white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                // Flag Button
                Button {
                    showFlagDialog = true
                } label: {
                    Image(systemName: "flag")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(12)
        }
        .alert("Report Listing", isPresented: $showFlagDialog) {
            TextField("Reason for reporting...", text: $flagReason)
            Button("Cancel", role: .cancel) {
                flagReason = ""
            }
            Button("Report", role: .destructive) {
                if !flagReason.isEmpty {
                    onFlag(flagReason)
                    flagReason = ""
                }
            }
        } message: {
            Text("Please tell us why you're reporting this listing.")
        }
    }
    
    // MARK: - Category Badge
    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: listing.category.icon)
                .font(.caption2)
            Text(listing.category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(listing.category.swiftColor.color.opacity(0.15))
        .foregroundStyle(listing.category.swiftColor.color)
        .clipShape(Capsule())
    }
    
    // MARK: - Helpers
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ListingCard(
        listing: Listing(
            id: "1",
            title: "2BHK Apartment for Rent near Irving Masjid",
            description: "Spacious apartment",
            category: .housing,
            price: 1200,
            neighborhood: .irving,
            imageURLs: [],
            contactInfo: ContactInfo(phone: "555-0123"),
            authorId: "user1",
            authorName: "Ahmed Khan",
            isFeatured: true
        ),
        isFavorite: false,
        onFavoriteToggle: {},
        onFlag: { _ in }
    )
    .padding()
}
