import SwiftUI
import MapKit

struct CommunityMapView: View {
    let listings: [CommunityListing]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedListing: CommunityListing?
    @State private var cameraPosition: MapCameraPosition
    
    init(listings: [CommunityListing]) {
        self.listings = listings
        // Center on Dallas
        let dallasRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        _cameraPosition = State(initialValue: .region(dallasRegion))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition, selection: $selectedListing) {
                    ForEach(listings) { listing in
                        Marker(
                            listing.title,
                            systemImage: listing.category.icon,
                            coordinate: CLLocationCoordinate2D(
                                latitude: listing.neighborhood.coordinates.latitude,
                                longitude: listing.neighborhood.coordinates.longitude
                            )
                        )
                        .tint(listing.category.swiftUIColor)
                        .tag(listing)
                    }
                }
                .mapStyle(.standard)
                
                // Listing Preview Card
                if let selected = selectedListing {
                    VStack {
                        Spacer()
                        ListingPreviewCard(listing: selected) {
                            dismiss()
                            // Navigate to detail view
                        }
                        .padding()
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Map View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(DallasNeighborhood.allCases, id: \.self) { neighborhood in
                            Button(neighborhood.rawValue) {
                                withAnimation {
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(
                                            latitude: neighborhood.coordinates.latitude,
                                            longitude: neighborhood.coordinates.longitude
                                        ),
                                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                    ))
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

// MARK: - Listing Preview Card
struct ListingPreviewCard: View {
    let listing: CommunityListing
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Image
                if let firstImage = listing.imageURLs.first {
                    AsyncImage(url: URL(string: firstImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Color(.secondarySystemBackground))
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(listing.title)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if let price = listing.price {
                            Text(formatPrice(price))
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(listing.neighborhood.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: listing.category.icon)
                            .font(.caption)
                            .foregroundColor(listing.category.swiftUIColor)
                        Text(listing.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price == 0 { return "Free" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$$$"
    }
}

#Preview {
    CommunityMapView(listings: MockData.communityListings)
}
