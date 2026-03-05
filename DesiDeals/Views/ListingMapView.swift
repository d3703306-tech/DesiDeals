// MARK: - Interactive Map View for Listings
import SwiftUI
import MapKit

struct ListingMapView: View {
    let listings: [Listing]
    @State private var selectedListing: Listing?
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 32.9, longitude: -96.8),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    ))
    
    // Neighborhood coordinates
    private let neighborhoodCoordinates: [DallasNeighborhood: CLLocationCoordinate2D] = [
        .irving: CLLocationCoordinate2D(latitude: 32.8140, longitude: -96.9489),
        .frisco: CLLocationCoordinate2D(latitude: 33.1507, longitude: -96.8236),
        .plano: CLLocationCoordinate2D(latitude: 33.0198, longitude: -96.6989),
        .richardson: CLLocationCoordinate2D(latitude: 32.9482, longitude: -96.7299),
        .carrollton: CLLocationCoordinate2D(latitude: 32.9537, longitude: -96.8903),
        .allen: CLLocationCoordinate2D(latitude: 33.1032, longitude: -96.6706),
        .mckinney: CLLocationCoordinate2D(latitude: 33.1972, longitude: -96.6397)
    ]
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(groupedListings.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { neighborhood in
                    let coordinate = neighborhoodCoordinates[neighborhood] ?? CLLocationCoordinate2D()
                    let count = groupedListings[neighborhood]?.count ?? 0
                    
                    Annotation(
                        neighborhood.rawValue,
                        coordinate: coordinate
                    ) {
                        NeighborhoodAnnotation(
                            neighborhood: neighborhood,
                            count: count,
                            isSelected: selectedListing?.neighborhood == neighborhood
                        )
                        .onTapGesture {
                            withAnimation {
                                if selectedListing?.neighborhood == neighborhood {
                                    selectedListing = nil
                                }
                            }
                        }
                    }
                }
                
                // Show individual listing pins when a neighborhood is selected
                if let selected = selectedListing {
                    Marker(selected.title, coordinate: CLLocationCoordinate2D(
                        latitude: selected.neighborhood.coordinate.latitude + 0.001,
                        longitude: selected.neighborhood.coordinate.longitude + 0.001
                    ))
                }
            }
            .mapStyle(.standard)
            
            // Bottom Sheet with Listings for Selected Area
            if let selected = selectedListing {
                VStack {
                    Spacer()
                    
                    NeighborhoodListingsSheet(
                        neighborhood: selected.neighborhood,
                        listings: groupedListings[selected.neighborhood] ?? []
                    ) {
                        withAnimation(.spring()) {
                            selectedListing = nil
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            
            // Instructions Overlay
            if selectedListing == nil {
                VStack {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.orange)
                        Text("Tap a neighborhood to see listings")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top)
                    
                    Spacer()
                }
            }
        }
    }
    
    // Group listings by neighborhood
    private var groupedListings: [DallasNeighborhood: [Listing]] {
        Dictionary(grouping: listings) { $0.neighborhood }
    }
}

// MARK: - Neighborhood Annotation
struct NeighborhoodAnnotation: View {
    let neighborhood: DallasNeighborhood
    let count: Int
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.orange : Color.white)
                .frame(width: isSelected ? 60 : 50, height: isSelected ? 60 : 50)
                .shadow(radius: 4)
            
            VStack(spacing: 2) {
                Text("\(count)")
                    .font(.system(size: isSelected ? 20 : 16, weight: .bold))
                    .foregroundStyle(isSelected ? .white : .orange)
                
                Text(neighborhood.rawValue.prefix(3))
                    .font(.system(size: 8))
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
            }
        }
    }
}

// MARK: - Neighborhood Listings Sheet
struct NeighborhoodListingsSheet: View {
    let neighborhood: DallasNeighborhood
    let listings: [Listing]
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle Bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(neighborhood.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(listings.count) listing\(listings.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // Listings List
            if listings.isEmpty {
                ContentUnavailableView {
                    Label("No Listings", systemImage: "doc.text")
                } description: {
                    Text("No listings available in this area")
                }
                .frame(height: 150)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(listings) { listing in
                            NavigationLink {
                                ListingDetailView(listing: listing)
                            } label: {
                                CompactListingCard(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
    }
}

// MARK: - Compact Listing Card (for map sheet)
struct CompactListingCard: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            ZStack(alignment: .topLeading) {
                if let firstImage = listing.imageURLs.first {
                    AsyncImage(url: URL(string: firstImage)) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .overlay(Image(systemName: "photo"))
                }
            }
            .frame(width: 140, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Category Badge
            HStack(spacing: 4) {
                Image(systemName: listing.category.icon)
                    .font(.caption2)
                Text(listing.category.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(listing.category.swiftColor.color.opacity(0.15))
            .foregroundStyle(listing.category.swiftColor.color)
            .clipShape(Capsule())
            
            // Title
            Text(listing.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
            
            // Price
            if let price = listing.price {
                Text(formatPrice(price))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
        }
        .frame(width: 140)
    }
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
}

#Preview {
    ListingMapView(listings: [])
}
